# TODO: compile snippet with correct file so relative #metaimports can be resolved correctly
# TODO: ship mjsish with plugin
# TODO: open separate repls for different packages and eval on correct one
# TODO: show javascript code in a separate pane

{View} = require 'atom'
{packageRootOf} = require './packages'
{inspect} = require 'util'
{addLinks, onClickStackTrace} = require './stack-trace-links'

module.exports =
class MetaScriptReplView extends View
  @content: ->
    @div class: 'language-meta-script tool-panel panel-bottom', =>
      @div class: 'title panel-heading', =>
        @span class: 'icon-x', click: 'toggle'
        @span 'Ready', outlet: 'title'
      @div class: 'panel-body padded', =>
        @pre '', class: 'mjsish-output', outlet: 'output'

  initialize: (serializeState) ->
    atom.workspaceView.command "meta-script-repl:toggle", => @toggle()
    atom.workspaceView.command "meta-script-repl:eval", => @eval()
    @subscribe @output, 'click', 'a', onClickStackTrace

  serialize: ->

  destroy: ->
    @killRepl()
    @detach()

  reset: ->
    @title.text 'Ready'
    @clearStatusClasses @title
    @output.text ''

  clearStatusClasses: (node) ->
    node.removeClass('success error warning')

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspace.addBottomPanel(item: this)

  onOutputData: (data) ->
    @output.append data
    @output.scrollToBottom()

  repl: null

  eval: ->
    @toggle() unless @hasParent()
    activeEditor = atom.workspace.getActiveTextEditor()
    return unless activeEditor
    code = activeEditor.getSelectedText()
    filename = activeEditor.getBuffer().getPath()
    request = {code, filename}
    if @repl
      @send request
    else
      activePackage = packageRootOf filename
      @repl = @spawnReplForPackage activePackage, =>
        packageName = (require 'path').basename activePackage
        @title.text "mjsish on package *#{packageName}*"
        @repl.on 'message', (message) =>
          @onReplMessage message
        process.nextTick =>
          @send request
          request = null

  send: (message) ->
    console.log "mjsish request:", message
    @repl.send message

  onReplMessage: (message) ->
    console.log 'mjsish message:', message
    @clearStatusClasses @output
    switch message.intent
      when 'evaluation-result'
        @output.text message.result
      when 'evaluation-error'
        @output.text ''
        @output.append addLinks message.error
        @output.addClass 'error'
      else
        @output.text inspect message
        @output.addClass 'warning'

  killRepl: ->
    return unless @repl
    @repl.kill 'SIGKILL'

  onProcessClose: (exitCode) ->
    console.log 'repl exited with %d code', exitCode
    @repl = null
    success = exitCode == 0
    @title.text(if success then 'process finished' else 'process error')
    @title.addClass(if success then 'success' else 'error')

  mjsishPath: ->
    atom.config.get 'language-metascript.mjsishExecutablePath'

  spawnReplForPackage: (packageDir, onProcess) ->
    {spawn} = require('child_process')
    ansi = require('ansi-html-stream')
    executable = @mjsishPath()
    console.log "spawning `%s' for package `%s'", executable, packageDir
    mjsish = spawn executable, ['--ipc'], {cwd: packageDir, stdio: [undefined, undefined, undefined, 'ipc']}
    mjsish.on 'error', (err) =>
      console.warn 'mjsish error:', err
    mjsish.on 'close', (exitCode) =>
      @onProcessClose exitCode
    stream = ansi({ chunked: false })
    mjsish.stdout.pipe stream
    mjsish.stderr.pipe stream
    callback = (data) =>
      callback = (data) =>
        @onOutputData data
      callback(data)
      onProcess()
      onProcess = null
    stream.on 'data', (data) =>
      callback data
    mjsish
