# Custom interpreter in a shebang basics

You can specify any executable as a shebang (caveats for "any" discussed later)

```
#!/usr/bin/env custom-interpreter
```

This works if `custom-interpreter` is available in the `$PATH`.

## Using shell-scripts as the interpreter

Linux allows shell scripts to be used directly as an interpreter but Darwin based
systems (like macOS) do not allow this. Thus if `custom-interpreter` is a shell
script the following will script is actually silently forwarded to the current
shell as the interpreter.

```
#!/usr/path/to/custom-interpreter

echo hello
```

However it's simple to resolve this: just rely on `/usr/bin/env` to act as a proxy.

## What the interpreter sees when being proxied with env

Since I'm working in a Darwin system I can comment on how shell-script interpreters 
proxied via env behave.

- `$0` is the relative path to the interpreter (relative to the path where the command
  is being invoked).
- `$1` is the relative path to the file using the interpreter as a shebang
- `stdin` is the contents of the file located at the path `$1`

----

References:

1. [Shebang (Unix) - Wikipedia](https://en.m.wikipedia.org/wiki/Shebang_(Unix))
2. [Shebang pointing to script (also having shebang) is effectively ignored - StackOverflow](https://stackoverflow.com/questions/9988125/shebang-pointing-to-script-also-having-shebang-is-effectively-ignored)
3. [interpreter itself as #! script](https://www.in-ulm.de/~mascheck/various/shebang/#interpreter-script)
