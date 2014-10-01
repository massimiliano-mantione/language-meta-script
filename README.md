# language-meta-script

Metascript support for the atom editor.

## Installation

1. Install the editor-grammar-scope package using the atom package manager
2. git clone language-metascript
3. cd language-metascript && npm install
4. ln -s \`pwd\` ~/.atom/packages/

You might also want to install the [linter-metascript](../linter-metascript) package for on-the-fly error checking.

## Keyboard shortcuts

Keyboard shortcut                    | Description
-------------------------------------|-------------------------------
<kbd>ctrl-alt-,</kbd> | Run the tests for the current package.
<kbd>ctrl-alt-x</kbd> | Evaluate selected region.
<kbd>ctrl-alt-m t</kbd> | Toggle test view.
<kbd>ctrl-alt-m r</kbd> | Toggle REPL view.
<kbd>alt-=</kbd> | Toggle folding at current indent level.
