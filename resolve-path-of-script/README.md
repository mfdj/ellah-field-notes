# Resolve path of script

One of the fuzzier problems when authoring shell-scripts is resolving the directory
where  the currently running script resides.

### The primacy of interactive usage

When running a shell-script the **current directory context is the path where the
script is ran from**, not the directory where the shell-script resides. This applies
to all subsequent shell code executed (including when it's exec'd or source'd).

While it's probably intuitively obvious after you've written a few shell scripts
it's a critical to anchor on that shell scripts are optimized for automating interactive
usage. As such Bash lacks a module import system. As a result single file shell-script
programs are quite common. While embracing this limitation isn't always a bad thing,
strictly speaking it's not necessary.

### The source problem

We can use the `source` builtin to include code from one file into another, but
it's constrained by what feels like the simplest interactive use case.

 The following shell-script will work but _only_ when executed in a directory which
 contains a file called `some-other-code.sh`:

```sh
#!/usr/bin/env bash
source 'some-other-code.sh'
function_from_other_code
```

This is because `source` expects standard unix paths. If we want to bundle our main
shell-script with a `some-other-code.sh` and allow it to be executed from *any*
directory we'll need to determine the (absolute) path at runtime, roughly like:

```sh
#!/usr/bin/env bash
script_dir=$(…)
source "$script_dir/some-other-code.sh"
function_from_other_code
```

Obviously the ellipsis `…` are hiding an actual technique for finding the `script_dir`.
This is because Bash doesn't give us a simple way to know where the _shell-script
being executed_ is located, making it hard to build portable scripts that are composed
of multiple files.

Hard, but still very possible.

## Basics

Let's define our terms:

- **interactive usage** refers to code typed in a shell prompt
- **string-argument** evaluation refers to code passed directly to to the bash
  binary as an argument or via stdin (rare in practice but useful in certain situations)
  - as an argument `bash -c "<bash code>"`
  - or piped `echo "<bash code>" | bash`
- **shell-script** refers to shell code executed via a file; this includes
  - files passed as arguments to bash binary `bash path/to/file.sh`
  - scripts (with correct executable permissions) executed via a shebang, including
    as commands found via a PATH lookup
  - aka code that runs run in a Bash sub-process
- **sourced script** refers to shell code sourced via a file; this is a special
  case that can happen in all the other contexts — i.e. `source path/to/file.sh`
  — and has a few quirks of it's own

**Standard shell tools at our disposable**

- $0
- $BASH_SOURCE
- string substitution
- cd - shell builtin and macOS binary /usr/bin/cd
- pwd - shell builtin and macOS binary /bin/pwd
- dirname - macOS binary /usr/bin/dirname
- readlink - macOS binary /usr/bin/readlink which acts a wrapper of /usr/bin/stat
  - there is a useful GNU alternative available on Homebrew via coreutils package
- realapth a useful GNU command available on Homebrew via coreutils package

\* all macOS binaries above are via the BSD ecosystem

### Getting your bearings with $0 and $BASH\_SOURCE

In order to figure out where a script is you can start with two special parameters
created by Bash: `$0` and `$BASH_SOURCE`. The Bash manual defines them somewhat
tersely:

- **$0** expands to the name of the shell or shell script. ([manual](https://www.gnu.org/software/bash/manual/bash.html#index-0))
- **$BASH_SOURCE** is an array variable whose members are the source filenames where
  the corresponding shell function names in the FUNCNAME array variable are defined.
  ([manual](https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fSOURCE))

**$0 in the interactive and string-argument contexts**

In the interactive and string-argument contexts `$0` is the name of the shell (bash!)
with a subtle difference being that the interactive shell name leads with a dash:

```sh
$ echo "$0"
-bash

$ bash -c 'echo "$0"'
bash

$ echo 'echo "$0"' | bash
bash
```

same results when sourcing:

```sh
# echo-zero.sh
echo "$0"

# interactive-shell
$ source echo-zero.sh
-bash

$ bash -c 'source echo-zero.sh'
bash

$ echo 'source echo-zero.sh' | bash
bash
```

**$0 in the shell-script context**

In the shell-script context `$0` is the path required to execute the script. In
other words it represents the path of to file being executed from the current
directory context. Easy to visualize as:

```sh
# path/to/echo-zero.sh
echo "$0"

# interactive-shell
$ bash path/to/echo-zero.sh
path/to/echo-zero.sh
```

If `path/to/echo-zero.sh` had a shebang and an executable bit the results would be
similar when executing via a direct path or a PATH lookup:

```sh
$ ./path/to/echo-zero.sh
./path/to/echo-zero.sh
$ PATH+=:./path/to
$ echo-zero.sh
./path/to/echo-zero.sh
```

When a file that is sourced contains `$0` it's value will reflect the context
of the shell-script which started the bash process:

```sh
# source-this.sh
echo "$0"

# path/to/file.sh
source source-this.sh

# interactive-shell
$ bash path/to/file.sh
path/to/file.sh
```

**$BASH_SOURE in the interactive and string-argument contexts**

In the interactive and string-argument contexts `$BASH_SOURCE` is an empty array:

```sh
$ declare -p BASH_SOURCE
declare -a BASH_SOURCE=()

$ bash -c "declare -p BASH_SOURCE"
declare -a BASH_SOURCE=()
```

When a file that contains `$BASH_SOURCE` is sourced it's value will be an array
with a single item which contains the path to the sourced file:

```sh
# source-this.sh
declare -p BASH_SOURCE

# interactive-shell
$ source source-this.sh
declare -a BASH_SOURCE=([0]="source-this.sh")
```

This reveals the interesting feature of _BASH\_SOURCE_: it contains the chain of
sourced files (from least recently sourced to most):

```sh
# print-bash-source.sh
declare -p BASH_SOURCE

# file/sourced/first.sh
source print-bash-source.sh

# interactive-shell
$ source file/sourced/first.sh
declare -a BASH_SOURCE=([0]="print-bash-source.sh" [1]="file/sourced/first.sh")
```

**$BASH_SOURE in the shell-script context**

In the shell-script context `$BASH_SOURCE` is an array with a single item which
is identical to `$0`:

```sh
# bash_source_and_0.sh
echo "${#BASH_SOURCE[@]}" # array length
echo "${BASH_SOURCE[0]}"  # first item
echo "$0"

# interactive-shell
$ bash bash_source_and_0.sh
1
bash_source_and_0.sh
bash_source_and_0.sh
```

When a file that contains `$BASH_SOURCE` is sourced it's value will be an array
with two items, the first will be the path to the file being sourced and the second
will be the path to the file being executed (i.e. same as `$0`):

```sh
# sources-loop-through.sh
echo "$0"
for item in "${BASH_SOURCE[@]}"; do echo " • $item"; done
source loop-through.sh

# interactive-shell
$ bash sources-loop-through.sh
sources-loop-through.sh
 • loop-through.sh
 • sources-loop-through.sh
```

Each time a file is sourced it adds an item to the _BASH\_SOURCE_ array, with the
shell-script being executed always being the last member.

### dirname

Is a string utility which will find the directory of a given path - it does this by
doing something close to or exactly like:

- striping all trailing slashes, meaning one or more slashes at the end of a string;
  if the string ends in any non-slash character, including a space, it will not
  remove any slashes
- returning everything before the last slash in the string
  - one exception: if the string contains a single slash (after stripping slashes)
    and the string starts with this single slash character then a single slash
    character will be returned

The effect is to return the parent directory of a given file/folder. It does not
do any validation to check if the path actually exists - it's just a string utility.

```
$ dirname .
.
$ dirname ./
.
$ dirname /asdf
/
$ dirname /asdf/\ /
/
$ dirname /asdf///
/
$ dirname asdf/ghjk
asdf
$ dirname ./asdf/ghjk
./asdf
```

### cd, pwd, $PWD, and symlinks

The `cd` builtin in the command which changes the current directory context. It
accepts normal unix paths. When passed nothing it changes into `$HOME`.

When passed `-P` then symbolic links are resolved while cd is traversing the path
before processing an instance of `..` in directory.

The `pwd` builtin prints the current working directory and has a similar behavior
with and without a `-P` flag.

I have yet to contrive an example where `cd -P <path>; pwd` and `cd <path>; pwd -P`
create different results; it's pretty safe to say they are interchangeable path
resolvers.

One thing to consider is that `pwd` builtin should return the same value as `$PWD`
so we can add `cd -P <path>; echo "$PWD"` to our set of equivalent path resolvers.

It's worth underlining that `cd <path>; echo "$PWD"` is discluded from the set
because symlinks will not be resolved.

### readlink (and greadlink)

…

## In the wild

- https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
- http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in?answertab=votes
- https://bosker.wordpress.com/2012/02/12/bash-scripters-beware-of-the-cdpath/
- http://mywiki.wooledge.org/BashFAQ/028
- https://unix.stackexchange.com/questions/136494/whats-the-difference-between-realpath-and-readlink-f
