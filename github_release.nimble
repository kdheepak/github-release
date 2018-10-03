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

