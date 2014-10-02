# language-meta-script

Metascript support for the atom editor.

## Installation

1. Install the editor-grammar-scope package using the atom package manager
2. git clone language-metascript
3. cd language-metascript && npm install
4. ln -s \`pwd\` ~/.atom/packages/

You might also want to install the [linter-metascript](https://github.com/massimiliano-mantione/linter-metascript) package for on-the-fly error checking.

## Keyboard shortcuts

Keyboard shortcut                    | Description
-------------------------------------|-------------------------------
<kbd>ctrl-alt-,</kbd> | Run the tests for the current package.
<kbd>ctrl-alt-x</kbd> | Evaluate selected region.
<kbd>ctrl-alt-m t</kbd> | Toggle test view.
<kbd>ctrl-alt-m r</kbd> | Toggle REPL view.
<kbd>alt-=</kbd> | Toggle folding at current indent level.

## Snippets

Insert a snippet by typing the prefix below followed by tab.

Prefix | Expansion
-------------------------------------|-------------------------------
<kbd>v</kbd> | var _v_
<kbd>v=</kbd> | var _v_ = _42_
<kbd>c</kbd> | const _c_ = _42_
<kbd>f</kbd> | fun _f_ () -> _42_
<kbd>if</kbd> | if _true_ _true_
<kbd>ife</kbd> | if _true_ _true_ else _false_
<kbd>#e</kbd> | #external _symbol_
<kbd>#m</kbd> | #metaimport _module_
<kbd>#r</kbd> | #require _module_
<kbd>d</kbd> | describe '_given_' #->
<kbd>it</kbd> | it '_should_' #->
<kbd>ita</kbd> | it '_should_' done ->
<kbd>be</kbd> | before-each #->
<kbd>bea</kbd> | before-each done ->
<kbd>log</kbd> | console.log '_42_'
