# Custom interpreter in a shebang proof of concept

- supposition: the runner will be a child process of the customer-interpreter (i.e. from the perspective of the process model tree)
- functions and variables defined in the interpreter can be exported as expected
- when executing the runner it's important to specify bash, otherwise the shebang will kick off an endless loop
- passing flags to shebang interpreters is not portable, though it works in macOS; see: [SC2096](https://github.com/koalaman/shellcheck/wiki/Sc2096)
