{View} = require 'atom'
{getActivePackage} = require './packages'
{addLinks, onClickStackTrace} = require './stack-trace-links'

module.exports =
class LanguageMetaScriptView extends View
  @content: ->
    @div class: 'language-meta-script tool-panel panel-bottom', =>
      @div class: 'tile panel-heading', =>
        @span class: 'icon-x', click: 'toggle'
        @span 'Ready', outlet: 'title'
      @div class: 'panel-body padded', =>
        @pre '', class: 'build-output', outlet: 'output'

  initialize: (serializeState) ->
    atom.workspaceView.command "meta-script-test-view:toggle", => @toggle()
    atom.workspaceView.command "meta-script-test-view:run-tests-for-active-package", => @runTests()
    @subscribe @output, 'click', 'a', onClickStackTrace

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
    @title.removeClass('text-success text-error')
    @output.text ''

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspace.addBottomPanel(item: this)

  onOutputData: (data) ->
    @output.append addLinks data
    @output.scrollToBottom()

  onBuildFinished: (success) ->
    @title.text(if success then 'Test succeeded' else 'Test failed')
    @title.addClass(if success then 'text-success' else 'text-error')

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
