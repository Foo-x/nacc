import naccpkg/cli

when isMainModule:
  import cligen
  dispatchMulti([newCmd, cmdName = "new",
      usage = "$command [optional-params] contestId\n${doc}Options:\n$options"])
