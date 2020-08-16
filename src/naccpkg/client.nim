import asyncdispatch
from httpclient import AsyncResponse, HttpRequestError, get, post, body, newAsyncHttpClient, code
from httpcore import `[]`, `$`, `==`, HttpCode, contains, is4xx, is5xx
from htmlparser import parseHtml
from strformat import `&`
from uri import `$`, `?`, parseUri
from terminal import ForegroundColor, styledWriteLine, styledEcho
from xmltree import XmlNode

from ./parser import parseCsrfToken
from ./session import loadSession, saveSession

const
  baseUrl = "https://atcoder.jp/"
  loginUrl = &"{baseUrl}login"
  submitUrl = &"{baseUrl}contests/abc001/submit"

let client = newAsyncHttpClient(maxRedirects = 0)
client.headers = loadSession()

proc fetch*(url: string): Future[XmlNode] {.async.} =
  let response = await client.get url
  return parseHtml await response.body

proc isLoggedIn*(): Future[bool] {.async.} =
  let response = await client.get(submitUrl)
  return response.code != HttpCode(302)

proc validate(response: AsyncResponse) =
  if response.code.is4xx or response.code.is5xx:
    raise newException(HttpRequestError, $response.code)

proc getCsrfToken(): Future[string] {.async.} =
  let response = await client.get(loginUrl)
  response.validate()

  saveSession response.headers
  return parseCsrfToken parseHtml await response.body

proc login*(username, password: string): Future[void] {.async.} =
  let
    csrfToken = await getCsrfToken()
    params = {"username": username, "password": password, "csrf_token": csrfToken}

  client.headers = loadSession()

  let response = await client.post($(parseUri(loginUrl) ? params), "")
  response.validate()

  if response.headers["location"].contains("/home"):
    saveSession response.headers
    styledEcho fgGreen, "Login successful."
  else:
    raise newException(HttpRequestError, "invalid username or password")
