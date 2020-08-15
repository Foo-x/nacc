from sequtils import map, mapIt, filter, filterIt
from strutils import split, endsWith, replace, parseFloat, parseInt, strip, contains
from xmltree import XmlNode, attr, innerText

from nimquery import querySelector, querySelectorAll, parseHtmlQuery, exec

from ./fs import ProblemInfo, newProblemInfo

const
  aQuery = parseHtmlQuery "a"
  h3SectionPreQuery = parseHtmlQuery "h3 + section > pre:first-child"
  h3PreQuery = parseHtmlQuery "h3 + pre"

type
  PartialProblemInfo* = ref object
    problem*: string
    timeLimit: Natural
    memoryLimit: Natural

proc parsePartialProblemInfo(row: XmlNode): PartialProblemInfo =
  new(result)
  result.problem = aQuery.exec(row, true)[0].attr("href").split("/")[^1]

  let
    timeLimitStr = row.querySelector("td:nth-of-type(3)").innerText
    timeLimit =
      if timeLimitStr.endsWith(" msec"):
        timeLimitStr.replace(" msec", "").parseFloat
      else:
        timeLimitStr.replace(" sec", "").parseFloat * 1000
  result.timeLimit = timeLimit.toInt

  let
    memoryLimitStr = row.querySelector("td:nth-of-type(4)").innerText
    memoryLimit = memoryLimitStr.replace(" MB", "").parseInt
  result.memoryLimit = memoryLimit

proc parseProblems*(tree: XmlNode): seq[PartialProblemInfo] =
  let rows = tree.querySelector("tbody").querySelectorAll("tr")
  return rows.map(parsePartialProblemInfo)

proc containsSample(node: XmlNode): bool =
  node.innerText.contains("入力例") or node.innerText.contains("出力例")

proc parse1(tree: XmlNode): seq[XmlNode] =
  let sampleSection = tree.querySelectorAll(".section").filter(containsSample)[0]
  result = sampleSection.querySelectorAll("p + pre.literal-block")

proc parse2(tree: XmlNode): seq[XmlNode] =
  tree.querySelectorAll(".part").filter(containsSample).mapIt(
      h3SectionPreQuery.exec(it, true)).filterIt(it.len == 1).mapIt(it[0])

proc parse3(tree: XmlNode): seq[XmlNode] =
  tree.querySelectorAll(".part").filter(containsSample).mapIt(
      h3PreQuery.exec(it, true)).filterIt(it.len == 1).mapIt(it[0])

proc parseProblem*(tree: XmlNode, partialProblemInfo: PartialProblemInfo): ProblemInfo =
  var
    inputs, outputs = newSeq[string]()

  var parsed = parse3 tree
  if parsed.len == 0:
    parsed = parse2 tree
  if parsed.len == 0:
    parsed = parse1 tree

  for i, pre in parsed.pairs:
    if i mod 2 == 0:
      inputs.add pre.innerText.strip
    else:
      outputs.add pre.innerText.strip

  return newProblemInfo(partialProblemInfo.problem, inputs, outputs,
      partialProblemInfo.timeLimit, partialProblemInfo.memoryLimit)
