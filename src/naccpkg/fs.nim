from os import createDir, `/`
from strutils import replace
from strformat import `&`
from sequtils import toSeq

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

    let samplesDir = problemDir / "samples"
    createDir samplesDir
    for i in 0..<p.inputs.len:
      writeFile samplesDir / &"{i+1}.in", p.inputs[i]
      writeFile samplesDir / &"{i+1}.out", p.outputs[i]
