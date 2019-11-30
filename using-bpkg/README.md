# Using bpkg

Install bpkg with `curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | bash`

Check the [packages](http://www.bpkg.sh/packages/name/)

`bpkg list` to see officially registered packages

- list is via https://github.com/bpkg/bpkg/wiki/index
- cached locally at `~/.bpkg/index/github.com/index.txt`
- updated via `bpkg update`
— you are not limited to this list when installing: all github repos are also accessible
- (maybe you can register other package repositories?)

`bpkg install <pacakge-name>@<version>` to install a specific package

- where package-name can be
  - a Github shorthand like `danilocgsilva/uget`
  - an official `bpkg/…` package without  prefix (like `nman`)
- `@<version>` is optional, where `version` refers to a git ref (tag, branch, commit)
  - if no version is passed then it defaults to the `master`
- packages need a package.json file which conforms to http://www.bpkg.sh/guidelines/
  - the `name` is used as the folder name under `deps/<name>`
  - the `scripts` will be downloaded into `deps/<name>/<script>` and symlinked in `deps/bin/<script>`
  - the `files` will be downloaded into `deps/<name>/<file>` (but not symlinked)
- packages are installed in the current working directory in a folder called `deps`
- each package installs itself it's scripts in `deps/bin` like `deps/bin/nman`
- a `-g` or `--global` flag can optionally be added to install a location like `/usr/local/bin`
  (this is merely convention seen in many Makefiles where PREFIX can be updated to
  something other than `/usr/local`)
  - a Makefile is required when installing globally

`bpkg getdeps` to install dependencies in a local `package.json`

For example:

```json
{
  "name": "using-bpkg",
  "version": "0.0.1",
  "dependencies": {
    "term": "0.0.1"
  }
}
```
