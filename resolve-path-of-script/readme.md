# Resolve path of script

One of the fuzzier problems when authoring shell-scripts is resolving the directory
where  the currently running script resides.

### The primacy of interactive usage

When running a shell-script the **current directory context is the path where the
script is ran from**, not the directory where the shell- script resides. This applies
to all subsequent shell code executed (including when it's exec'd or source'd).

While this is probably intuitively obvious if you've written more than few shell
scripts it's a critical point to anchor on because Bash doesn't give us a simple
way to know where the _shell-script being executed_ is located, making it hard to build
portable scripts that are composed of multiple files.

### Modules are hard

Shells unfortunately (but understandably) lack a standard way to import/require code as
"modules" in a simple and portable way because shells are designed with interactive usage
in mind.

For example this code will only work when **running** this script in a directory
which contains a file called `some-other-code.sh`:

```sh
#!/usr/bin/env bash
source 'some-other-code.sh'
function_from_other_code
```

`source` is a useful tool for breaking up your shell-scripts into reusable chunks,
but it expects standard unix paths, which means to make this script portable, we'll
need to determine the path of the script at runtime, roughly like:

```sh
#!/usr/bin/env bash
script_dir=$(…)
source "$script_dir/some-other-code.sh"
function_from_other_code
```

Bash gives some tools which can allow us to solve this problem ourselves, leading
to a profusion of similar approaches with subtly different consequences.

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

**Standard Bash tools at our disposable**

- $0
- $BASH_SOURCE
- dirname
- cd
- pwd
- readlink (and greadlink)

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
$ echo 'echo "$0"' > echo-zero.sh

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
$ echo 'echo "$0"' > path/to/file.sh
$ bash path/to/file.sh
path/to/file.sh
```

If `path/to/file.sh` had a shebang and an executable bit the results would be
similar when executing via a direct path or a PATH lookup:

```sh
$ ./path/to/file.sh
./path/to/file.sh
$ PATH+=:./path/to
$ file.sh
./path/to/file.sh
```

When a file that is sourced contains `$0` it's value will reflect the context
of the shell-script which started the bash process:

```sh
$ echo 'echo "$0"' > source-this.sh
$ echo 'source source-this.sh' > path/to/file.sh
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
$ echo 'declare -p BASH_SOURCE' > source-this.sh
$ source source-this.sh
declare -a BASH_SOURCE=([0]="source-this.sh")
```

This reveals the interesting feature of _BASH\_SOURCE_: it contains the chain of
sourced files (from least recently sourced to most):

```sh
$ echo 'declare -p BASH_SOURCE' > print-bash-source.sh
$ echo 'source print-bash-source.sh' > file/sourced/first.sh
$ source file/sourced/first.sh
declare -a BASH_SOURCE=([0]="print-bash-source.sh" [1]="file/sourced/first.sh")
```

**$BASH_SOURE in the shell-script context**

In the shell-script context `$BASH_SOURCE` is an array with a single item which
is identical to `$0`:

```sh
$ echo 'echo "${#BASH_SOURCE[@]}"' > shell-script.sh
$ echo 'echo "${BASH_SOURCE[0]}"' >> shell-script.sh
$ echo 'echo "$0"' >> shell-script.sh
$ bash shell-script.sh
1
shell-script.sh
shell-script.sh
```

When a file that contains `$BASH_SOURCE` is sourced it's value will be an array
with two items, the first will be the path to the file being sourced and the second
will be the path to the file being executed (i.e. same as `$0`):

```sh
$ echo 'echo "$0"' > loop-through.sh
$ echo 'for item in "${BASH_SOURCE[@]}"; do echo " • $item"; done' >> loop-through.sh
$ echo 'source loop-through.sh' >> sources-loop-through.sh
$ bash sources-loop-through.sh
sources-loop-through.sh
 • loop-through.sh
 • sources-loop-through.sh
```

Each time a file is sourced it adds an item to the _BASH\_SOURCE_ array, with the
shell-script being executed always being the last member.


## In the wild

- https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
- http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in?answertab=votes
- https://bosker.wordpress.com/2012/02/12/bash-scripters-beware-of-the-cdpath/

