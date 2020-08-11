import asyncdispatch
from httpclient import getContent, newAsyncHttpClient
from htmlparser import parseHtml
from xmltree import XmlNode

let client = newAsyncHttpClient()

proc fetch*(url: string): Future[XmlNode] {.async.} =
  let content = await client.getContent url
  return parseHtml content
