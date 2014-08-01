{WorkspaceView} = require 'atom'
LanguageMetaScript = require '../lib/language-meta-script'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "LanguageMetaScript", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('language-meta-script')

  describe "when the language-meta-script:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.language-meta-script')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'language-meta-script:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.language-meta-script')).toExist()
        atom.workspaceView.trigger 'language-meta-script:toggle'
        expect(atom.workspaceView.find('.language-meta-script')).not.toExist()
