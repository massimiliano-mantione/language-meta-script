LanguageMetaScriptView = require './language-meta-script-view'
MetaScriptReplView = require './meta-script-repl-view'

module.exports =
  languageMetaScriptView: null
  replView: null

  configDefaults:
    mjsishExecutablePath: 'mjsish'

  activate: (state) ->
    @languageMetaScriptView = new LanguageMetaScriptView(state.languageMetaScriptViewState)
    @replView = new MetaScriptReplView(state.replViewState)

  deactivate: ->
    @languageMetaScriptView.destroy()
    @replView?.destroy()

  serialize: ->
    languageMetaScriptViewState: @languageMetaScriptView.serialize()
    replViewState: @replView?.serialize()
