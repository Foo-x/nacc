from httpcore import HttpHeaders, `[]=`, newHttpHeaders
from options import Option, some, isSome, get
from os import `/`, getHomeDir, existsFile
from strutils import join
from tables import `[]`

const
  sessionFilePath = getHomeDir() / ".nacc_session"

var cookie: Option[string]

proc loadSession*(): HttpHeaders =
  result = newHttpHeaders()
  if cookie.isSome:
    result["cookie"] = cookie.get
    return result

  if not sessionFilePath.existsFile:
    return result

  cookie = readFile(sessionFilePath).some
  result["cookie"] = cookie.get

proc saveSession*(headers: HttpHeaders) =
  cookie = headers.table["set-cookie"].join("; ").some
  writeFile(sessionFilePath, cookie.get)
