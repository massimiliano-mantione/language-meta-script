{View} = require 'atom'

module.exports =
class LanguageMetaScriptView extends View
  @content: ->
    @div class: 'language-meta-script overlay from-top', =>
      @div "The LanguageMetaScript package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "language-meta-script:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "LanguageMetaScriptView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
