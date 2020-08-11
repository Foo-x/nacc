# Package

version       = "0.1.0"
author        = "Foo-x"
description   = "A Nim AtCoder command line tools"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
installExt    = @["nim"]
bin           = @["nacc"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.6"
requires "nimquery >= 1.2.2"
requires "cligen >= 1.1.0"
