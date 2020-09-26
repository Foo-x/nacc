from asyncdispatch import waitFor
from strformat import `&`
from strutils import `%`
from sequtils import mapIt
from terminal import ForegroundColor, TerminalCmd, styledWriteLine, readPasswordFromStdin

from ./browser import openProblems, openProblem, openAnswer
from ./client import fetch, login, isLoggedIn
from ./parser import parseProblems, parseProblem
from ./fs import createContestDir
from ./test import doTest

const
  problemsUrl = "https://atcoder.jp/contests/$1/tasks"
  problemUrl = problemsUrl & "/$2"

proc loginCmd*(): int =
  if waitFor isLoggedIn():
    echo "Already logged in."
    return

  let
    username = readPasswordFromStdin("username: ")
    password = readPasswordFromStdin("password: ")
  try:
    waitFor login(username, password)
  except:
    stderr.styledWriteLine fgRed, &"Login failed: {getCurrentExceptionMsg()}"
    return 1

proc newCmd*(dir: string = "./", contestId: seq[string]): int =
  if contestId.len == 0:
    stderr.styledWriteLine fgRed, "Missing required argument."
    stderr.styledWriteLine fgRed, "Usage: nacc new <contestId>"
    return 1

  if not waitFor isLoggedIn():
    let code = loginCmd()
    if code != 0:
      return code

  let contestId = contestId[0]
  try:
    let
      problemsBody = waitFor fetch(problemsUrl % [contestId])
      partialProblems = problemsBody.parseProblems()
      problems = partialProblems.mapIt(parseProblem(waitFor fetch(problemUrl % [
          contestId, it.problem]), it))

    createContestDir dir, contestId, problems
  except:
    stderr.styledWriteLine fgRed, &"Failed with contestId: {contestId}"

proc testCmd*(dir: string = "./", gnuTime: string = "/usr/bin/time", problem: seq[string]): int =
  if problem.len < 2:
    stderr.styledWriteLine fgRed, "Missing required arguments."
    stderr.styledWriteLine fgRed, "Usage: nacc test <contestId> <problem>"
    return 1

  doTest(dir, problem[0], problem[1], gnuTime)

proc openCmd*(problem: seq[string]): int =
  if problem.len == 0:
    stderr.styledWriteLine fgRed, "Missing required arguments."
    stderr.styledWriteLine fgRed, "Usage:"
    stderr.styledWriteLine fgRed, "nacc open <contestId>"
    stderr.styledWriteLine fgRed, "nacc open <contestId> <problem>"
    stderr.styledWriteLine fgRed, "nacc open <contestId> answer"
    return 1

  if problem.len == 1:
    openProblems(problem[0])
    return

  if problem[1] == "answer":
    openAnswer(problem[0])
    return

  openProblem(problem[0], problem[1])
