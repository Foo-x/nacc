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
    styledWriteLine stderr, fgRed, "Missing required argument."
    styledWriteLine stderr, fgRed, "Usage: nacc new contestId"
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
    styledWriteLine stderr, fgRed, &"Failed for contestId: {contestId}"

proc testCmd*(dir: string = "./", gnuTime: string = "/usr/bin/time", problem: seq[string]): int =
  if problem.len < 2:
    styledWriteLine stderr, fgRed, "Missing required arguments."
    styledWriteLine stderr, fgRed, "Usage: nacc test contestId problem"
    return 1

  doTest(dir, problem[0], problem[1], gnuTime)
