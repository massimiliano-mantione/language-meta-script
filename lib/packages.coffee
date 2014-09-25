{dirname, join} = require 'path'
{existsSync} = require 'fs'

packageRootOf = (filename) ->
  prev = undefined
  cur = dir = dirname filename
  while cur != prev
    if (existsSync(join(cur, 'package.json')))
      return cur
    prev = cur
    cur = dirname cur
  dir

module.exports =
  getActivePackage: ->
    editorPath = atom.workspace.getActiveTextEditor()?.getBuffer().getPath()
    if editorPath
      packageRootOf editorPath
    else
      undefined
