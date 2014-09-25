{View} = require 'atom'
{getActivePackage} = require './packages'

stackTracePatterns = [
  /\bat\s+.+?\s+\((.+?)\:(\d+):(\d+)\)/g
  /\bat ([^\n(]+?)\:(\d+):(\d+)/g
]

addLinksForPattern = (text, pattern) ->
  text.replace pattern, (whole, fname, line, column) ->
    "<a data-file='#{fname}' data-line='#{line}' data-column='#{column}'>#{whole}</a>"

addLinks = (text) ->
  stackTracePatterns.reduce addLinksForPattern, text

module.exports =
class LanguageMetaScriptView extends View
  @content: ->
    @div class: 'language-meta-script tool-panel panel-bottom', =>
      @div class: 'panel-heading', =>
        @span 'Ready', outlet: 'title'
      @div class: 'panel-body padded', =>
        @pre '', class: 'build-output', outlet: 'output'

  initialize: (serializeState) ->
    atom.workspaceView.command "meta-script-test-view:toggle", => @toggle()
    atom.workspaceView.command "meta-script-test-view:run-tests-for-active-package", => @runTests()
    @subscribe @output, 'click', 'a', @onOutputClick

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  runTests: ->
    activePackage = getActivePackage()
    return unless activePackage
    @reset()
    @toggle() unless @hasParent()
    @npmTest activePackage

  reset: ->
    @title.text 'Ready'
    @title.removeClass('success error warning')
    @output.text ''

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.prependToBottom(this)

  onOutputData: (data) ->
    @output.append addLinks data
    @output.scrollToBottom()

  onBuildFinished: (success) ->
    @title.text(if success then 'Test succeeded.' else 'Test failed.')
    @title.addClass(if success then 'success' else 'error')

  onOutputClick: (e) ->
    {file, line, column} = e.currentTarget?.dataset
    if file
      atom.workspace.open(file).then (editor) =>
        editor.setCursorBufferPosition [line - 1, column - 1]

  npmTest: (packageDir) ->
    {spawn} = require('child_process')
    ansi = require('ansi-html-stream')
    npm = spawn 'npm', ['test'], {cwd: packageDir}
    npm.on 'close', (exitCode) =>
      @onBuildFinished(0 == exitCode)
    stream = ansi({ chunked: false })
    npm.stdout.pipe stream
    npm.stderr.pipe stream
    stream.on 'data', (data) =>
      @onOutputData data
