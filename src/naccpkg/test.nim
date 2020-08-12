from options import Option, isSome, get, some, none
from os import PathComponent, `/`, existsFile, walkDir, splitFile
from osproc import execCmd, execCmdEx
from sequtils import mapIt
from strformat import `&`
from strutils import `%`, strip, parseFloat, splitLines, join, split, parseInt
from terminal import ForegroundColor, styledWriteLine, resetStyle

from ./fs import readConfig

const
  compileCmd = "nim cpp -o:$1 -d:release -d:debug --hints:off -w:off --verbosity:0 $2"

proc hasGnuTime(gnuTime: string): bool =
  execCmdEx(gnuTime & """ -f "%M,%e" true""")[1] == 0

proc createTempDir(): string =
  execCmdEx("mktemp -d")[0].strip

proc outputTestResult(index: int, actual, expected: string, elapsed,
    usedMem: Option[string], config: Option[tuple[timeLimit,
    memoryLimit: float]]): bool =
  stdout.write &"{index}. "

  let
    actual = actual.strip
    expected = expected.strip

  var detail = ""
  if actual != expected:
    stdout.styledWriteLine fgRed, "[WA]"
    detail = "Expected:\n" & expected & "\n\nActual:\n" & actual & "\n"
  elif elapsed.isSome and config.isSome and elapsed.get.parseFloat * 1000 >
      config.get[0]:
    stdout.styledWriteLine fgYellow, "[TLE]"
    detail = "Time limit: " & $(config.get[0] / 1000) & " sec\n"
  elif usedMem.isSome and config.isSome and usedMem.get.parseFloat / 1000 >
      config.get[1]:
    stdout.styledWriteLine fgYellow, "[MLE]"
    detail = "Memory limit: " & $config.get[1] & " MB\n"
  else:
    stdout.styledWriteLine fgGreen, "[AC]"
    result = true

  if elapsed.isSome:
    echo &"Elapsed: {elapsed.get} sec"
  if usedMem.isSome:
    echo &"Memory used: {usedMem.get.parseFloat / 1000} MB"

  echo detail

proc doTest*(dir, contestId, problem, gnuTime: string) =
  let
    targetDir = dir / contestId / problem
    target = targetDir / "main.nim"
  if not existsFile target:
    stderr.styledWriteLine fgRed, &"{contestId}-{problem}: not found"
    return

  let
    tempDir = createTempDir()
    outBin = tempDir / "a.out"

  discard execCmd(compileCmd % [outBin, target])

  var
    inputs, outputs = newSeq[string]()
  for kind, path in walkDir(targetDir / "samples"):
    if kind != pcFile:
      continue

    let ext = path.splitFile.ext
    if ext == ".in":
      inputs.add path
    elif ext == ".out":
      outputs.add path

  let
    isValidGnuTime = hasGnuTime gnuTime
    timeCmd = if isValidGnuTime: gnuTime & """ -f "%e,%M"""" else: ""
    config = readConfig(dir, contestId, problem)

  if not isValidGnuTime:
    stderr.styledWriteLine fgYellow, "No GNU time found."

  var failedSamples = newSeq[int]()
  for i in 0..<inputs.len:
    let
      result = execCmdEx(&"{timeCmd} {outBin} < {inputs[i]}")[0].strip
      resultLines = result.splitLines()
      expected = readFile outputs[i]

    if isValidGnuTime:
      let
        actual = resultLines[0..^2].join("\n")
        splittedTime = resultLines[^1].split(",")
        elapsed = splittedTime[0]
        usedMem = splittedTime[1]
      if not outputTestResult(i+1, actual, expected, elapsed.some, usedMem.some, config):
        failedSamples.add i+1
    else:
      if not outputTestResult(i+1, resultLines.join("\n"), expected,
          string.none, string.none, config):
        failedSamples.add i+1

  if failedSamples.len != 0:
    stdout.styledWriteLine fgRed, "Failed samples: ", resetStyle,
        failedSamples.mapIt($it).join(", ")
  else:
    stdout.styledWriteLine fgGreen, "All samples passed."
