from asyncdispatch import waitFor
from strformat import `&`
from strutils import `%`
from sequtils import mapIt
from terminal import ForegroundColor, TerminalCmd, styledWriteLine

from ./client import fetch
from ./parser import parseProblems, parseProblem
from ./fs import createContestDir
from ./test import doTest

const
  problemsUrl = "https://atcoder.jp/contests/$1/tasks"
  problemUrl = problemsUrl & "/$2"

proc newCmd*(dir: string = "./", contestId: seq[string]): int =
  if contestId.len == 0:
    styledWriteLine stderr, fgRed, "error: missing required argument 'contestId'"
    return 1

  let contestId = contestId[0]
  try:
    let
      problemsBody = waitFor fetch(problemsUrl % [contestId])
      partialProblems = problemsBody.parseProblems()
      problems = partialProblems.mapIt(parseProblem(waitFor fetch(problemUrl % [
          contestId, it.problem]), it))

    createContestDir dir, contestId, problems
  except:
    styledWriteLine stderr, fgRed, &"failed for '{contestId}'"

proc testCmd*(dir: string = "./", gnuTime: string = "/usr/bin/time", problem: seq[string]): int =
  if problem.len < 1:
    styledWriteLine stderr, fgRed, "error: missing required argument 'contestId problem'"
    return 1

  doTest(dir, problem[0], problem[1], gnuTime)
