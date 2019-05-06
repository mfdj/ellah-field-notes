# Resolve path of script

One of the trickiest jobs in shell scripting is to resolve the directory the
currently running script resides.

## Basics

### Current directory context

When running a shell script the current directory context is where the script is
ran from. This applies to all subsequent shell code executed.

In a sense this should not be surprising, but it's critical point to anchor on.

### $0 and $BASH_SOURCE

`$0` expands to the name of the shell or shell script. ([manual](https://www.gnu.org/software/bash/manual/bash.html#index-0))

You will get the name of the shell when executing shell code as a string or as part
of an interactive shell session `$0`, where the name of an interactive shell
leads with a dash

```
→ echo "$0"
-bash
→ bash -c 'echo "$0"'
bash
```

`$BASH_SOURCE` is an array variable whose members are the source filenames where the corresponding shell function names in the FUNCNAME array variable are defined. ([manual](https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fSOURCE))

```
→ echo "«${BASH_SOURCE[0]}»"
«»
```

## Tools

- $0
- dirname
- cd
- readlink / greadlink

## In the wild

- https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
- http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in?answertab=votes
- https://bosker.wordpress.com/2012/02/12/bash-scripters-beware-of-the-cdpath/
