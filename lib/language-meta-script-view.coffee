{View} = require 'atom'
{dirname, join} = require 'path'
{existsSync} = require 'fs'

stackTracePatterns = [
  /\bat\s+.+?\s+\((.+?)\:(\d+):(\d+)\)/g
  /\bat ([^\n(]+?)\:(\d+):(\d+)/g
]

addLinksForPattern = (text, pattern) ->
  text.replace pattern, (whole, fname, line, column) ->
    "<a data-file='#{fname}' data-line='#{line}' data-column='#{column}'>#{whole}</a>"

addLinks = (text) ->
  stackTracePatterns.reduce addLinksForPattern, text

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
class LanguageMetaScriptView extends View
  @content: ->
    @div class: 'language-meta-script tool-panel panel-bottom', =>
      @div class: 'panel-heading', =>
        @span 'Ready', outlet: 'title'
      @div class: 'panel-body padded', =>
        @pre '', class: 'build-output', outlet: 'output'

  initialize: (serializeState) ->
    atom.workspaceView.command "language-meta-script:toggle", => @toggle()
    atom.workspaceView.command "language-meta-script:run-tests", => @runTests()
    @subscribe @output, 'click', 'a', @onOutputClick

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  runTests: ->
    editorPath = atom.workspace.getActiveTextEditor()?.getBuffer().getPath()
    return unless editorPath

    @reset()
    @toggle() unless @hasParent()
    {spawn} = require('child_process')
    ansi = require('ansi-html-stream')
    npm = spawn 'npm', ['test'], {
      cwd: packageRootOf editorPath
    }
    npm.on 'close', (exitCode) =>
      @buildFinished(0 == exitCode)
    stream = ansi({ chunked: false })
    npm.stdout.pipe stream
    npm.stderr.pipe stream
    stream.on 'data', (data) =>
      @output.append addLinks data
      @output.scrollToBottom()

  reset: ->
    @title.text 'Ready'
    @title.removeClass('success error warning')
    @output.text ''

  buildFinished: (success) ->
    @title.text(if success then 'Test succeeded.' else 'Test failed.')
    @title.addClass(if success then 'success' else 'error')

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.prependToBottom(this)

  onOutputClick: (e) ->
    {file, line, column} = e.currentTarget?.dataset
    if file
      atom.workspace.open(file).then (editor) =>
        editor.setCursorBufferPosition [line - 1, column - 1]
