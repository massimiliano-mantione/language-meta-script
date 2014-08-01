LanguageMetaScriptView = require './language-meta-script-view'

module.exports =
  languageMetaScriptView: null

  activate: (state) ->
    @languageMetaScriptView = new LanguageMetaScriptView(state.languageMetaScriptViewState)

  deactivate: ->
    @languageMetaScriptView.destroy()

  serialize: ->
    languageMetaScriptViewState: @languageMetaScriptView.serialize()
