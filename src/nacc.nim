import naccpkg/cli

when isMainModule:
  import cligen
  dispatchMulti(
      [loginCmd, cmdName = "login"],
      [newCmd, cmdName = "new",
          usage = "$command [optional-params] contestId\n${doc}Options:\n$options"],
      [testCmd, cmdName = "test",
          usage = "$command [optional-params] contestId problem\n${doc}Options:\n$options"],
      [openCmd, cmdName = "open",
          usage = "$command [optional-params] <contestId> [<problem>|answer]\n${doc}Options:\n$options\nSet Environment variable BROWSER for WSL."])
