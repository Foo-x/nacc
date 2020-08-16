from browsers import openDefaultBrowser
from strformat import `&`
from strutils import `%`

const
  baseUrl = "https://atcoder.jp/"
  contestUrl = &"{baseUrl}contests/$1"
  problemsUrl = &"{contestUrl}/tasks"
  problemUrl = &"{problemsUrl}/$2"
  explanationUrl = &"{contestUrl}/editorial"

proc openProblems*(contestId: string) =
  openDefaultBrowser(problemsUrl % [contestId])

proc openProblem*(contestId, problem: string) =
  openDefaultBrowser(problemUrl % [contestId, problem])

proc openAnswer*(contestId: string) =
  openDefaultBrowser(explanationUrl % [contestId])
