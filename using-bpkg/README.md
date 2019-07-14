# Using bpkg

Install bpkg with `curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | bash`

Check the [packages](http://www.bpkg.sh/packages/name/)

`bpkg list` to see officially registered packages

- list is via https://github.com/bpkg/bpkg/wiki/index
- cached locally at `~/.bpkg/index/github.com/index.txt`
- updated via `bpkg update`
- you can register other repositories
— you are not limited to this list when installing

`bpkg install <packge-name>` to install a specific package

- where package-name can be
  - a Github shorthand like `danilocgsilva/uget`
  - an official `bpkg/…` package without  prefix (like `nman`)
- packages are installed in the current working directory in a folder called `deps`
- each package installs itself it's scripts in `deps/bin` like `deps/bin/nman`
- a `-g` or `--global` flag can optionally be added to install in `/usr/local/bin`
  (or not, this is merely convention seen in many Makefiles, which can be customized
  by setting PREFIX to something other than `/usr/local`)
- packages needs a packge.json file (to be installed locally) or if they only contain
  a Makefile they can be installed globally

`bpkg getdeps` to install dependencies in a local `package.json`

For example:

```
{
  "name": "using-bpkg",
  "version": "0.0.1",
  "dependencies": {
    "term": "0.0.1"
  }
}
```
