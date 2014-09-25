{View} = require 'atom'
{getActivePackage} = require './packages'

module.exports =
class MetaScriptReplView extends View
  @content: ->
    @div class: 'language-meta-script tool-panel panel-bottom', =>
      @div class: 'panel-heading', =>
        @span 'Ready', outlet: 'title'
      @div class: 'panel-body padded', =>
        @pre '', class: 'mjsish-output', outlet: 'output'

  initialize: (serializeState) ->
    atom.workspaceView.command "meta-script-repl:toggle", => @toggle()
    atom.workspaceView.command "meta-script-repl:eval", => @eval()

  serialize: ->

  destroy: ->
    @killRepl()
    @detach()

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
    @output.append data
    @output.scrollToBottom()

  repl: null

  socket: null

  eval: ->
    @toggle() unless @hasParent()
    activeEditor = atom.workspace.getActiveTextEditor()
    return unless activeEditor
    code = activeEditor.getSelectedText()
    if @repl
      @socket.write code
    else
      activePackage = getActivePackage()
      @repl = @spawnReplForPackage activePackage, =>
        packageName = (require 'path').basename activePackage
        @title.text "mjsish on package *#{packageName}*"
        {connect} = require 'net'
        @socket = connect 15542, =>
          console.log 'mjsish socket connected'
          @socket.write code
          code = null
        @socket.on 'error', (err) =>
          console.log 'mjsish socket error:', err
        @socket.on 'data', (data) =>
          @output.text data
        @socket.on 'close', =>
          console.log 'mjsish socket closed'

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
    mjsish = spawn executable, ['--port', '15542'], {cwd: packageDir}
    mjsish.on 'error', (err) =>
      console.warn 'mjsish error:', err
    mjsish.on 'close', (exitCode) =>
      @onProcessClose exitCode
    stream = ansi({ chunked: false })
    mjsish.stdout.pipe stream
    mjsish.stderr.pipe stream
    stream.on 'data', (data) =>
      cb = onProcess
      if cb
        onProcess = null
        cb()
      @onOutputData data
    mjsish
