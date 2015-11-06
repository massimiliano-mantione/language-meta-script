LanguageMetaScriptView = require './language-meta-script-view'
MetaScriptReplView = require './meta-script-repl-view'

foldAtIndentLevel = ->
  editor = atom.workspace.getActiveTextEditor()
  if editor
    if editor.isFoldedAtCursorRow()
      editor.unfoldAll()
    else
      pos = editor.getCursorBufferPosition()
      editor.foldAllAtIndentLevel(editor.indentationForBufferRow pos.row)

module.exports =
  languageMetaScriptView: null
  replView: null

  configDefaults:
    mjsishExecutablePath: 'mjsish'

  activate: (state) ->
    @languageMetaScriptView = new LanguageMetaScriptView(state.languageMetaScriptViewState)
    @replView = new MetaScriptReplView(state.replViewState)
    atom.commands.add "atom-text-editor", "editor:fold-at-indent-level", foldAtIndentLevel

  deactivate: ->
    @languageMetaScriptView.destroy()
    @replView?.destroy()

  serialize: ->
    languageMetaScriptViewState: @languageMetaScriptView.serialize()
    replViewState: @replView?.serialize()
