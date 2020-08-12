from options import Option, none, some
from os import createDir, `/`, existsFile
from parsecfg import newConfig, setSectionKey, writeConfig, loadConfig, getSectionValue
from strutils import replace, parseFloat
from strformat import `&`
from sequtils import toSeq
from terminal import ForegroundColor, styledWriteLine

const
  configFileName = "problem.cfg"

type
  ProblemInfo* = ref object
    problem: string
    inputs: seq[string]
    outputs: seq[string]
    timeLimit: Natural
    memoryLimit: Natural

proc newProblemInfo*(problem: string, inputs: openArray[string],
    outputs: openArray[string], timeLimit: Natural,
    memoryLimit: Natural): ProblemInfo =
  ProblemInfo(problem: problem, inputs: inputs.toSeq, outputs: outputs.toSeq,
      timeLimit: timeLimit, memoryLimit: memoryLimit)

proc createContestDir*(dir: string, contestId: string, problemInfos: openArray[ProblemInfo]) =
  let contestDir = dir / contestId
  createDir contestDir
  for p in problemInfos:
    let problemDir = contestDir / p.problem.replace(&"{contestId}_", "")
    createDir problemDir
    writeFile problemDir / "main.nim", ""

    var config = newConfig()
    config.setSectionKey "", "timeLimit", $p.timeLimit
    config.setSectionKey "", "memoryLimit", $p.memoryLimit
    config.writeConfig problemDir / configFileName

    let samplesDir = problemDir / "samples"
    createDir samplesDir
    for i in 0..<p.inputs.len:
      writeFile samplesDir / &"{i+1}.in", p.inputs[i]
      writeFile samplesDir / &"{i+1}.out", p.outputs[i]

proc readConfig*(dir, contestId, problem: string): Option[tuple[timeLimit,
    memoryLimit: float]] =
  let fileName = dir / contestId / problem / configFileName
  if not existsFile fileName:
    stderr.styledWriteLine fgYellow, "No config found."
    return none(tuple[timeLimit, memoryLimit: float])

  let
    config = loadConfig fileName
    timeLimit = config.getSectionValue("", "timeLimit")
    memoryLimit = config.getSectionValue("", "memoryLimit")

  try:
    return (timeLimit.parseFloat, memoryLimit.parseFloat).some
  except ValueError:
    stderr.styledWriteLine fgYellow, "Config format is invalid."
    return none(tuple[timeLimit, memoryLimit: float])
