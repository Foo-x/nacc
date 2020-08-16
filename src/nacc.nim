import naccpkg/cli

when isMainModule:
  import cligen
  dispatchMulti(
      [loginCmd, cmdName = "login"],
      [newCmd, cmdName = "new",
          usage = "$command [optional-params] contestId\n${doc}Options:\n$options"],
      [testCmd, cmdName = "test",
          usage = "$command [optional-params] contestId problem\n${doc}Options:\n$options"])
