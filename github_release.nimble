# Package

version       = "0.1.0"
author        = "Dheepak Krishnamurthy"
description   = "github-release package"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["github_release"]
skipExt       = @["nim"]

# Dependencies

requires "nim >= 0.19.0", "cligen#head"

when defined(nimdistros):
    import distros
    if detectOs(Ubuntu):
        foreignDep "libssl-dev"
    else:
        foreignDep "openssl"

task run, "run":

    exec("nimble build")
    exec("./bin/github_release --version")

