
stackTracePatterns = [
  # node stack traces
  /\bat\s+.+?\s+\((.+?)\:(\d+):(\d+)\)/g
  /\bat ([^\n(]+?)\:(\d+):(\d+)/g
  # phantomjs stack traces
  /\bat\s+.+?\s+\(file\:\/\/(.+?)\:(\d+)\)/g
  /\bat\s+file\:\/\/(.+?)\:(\d+)/g
]

addLinksForPattern = (text, pattern) ->
  text.replace pattern, (whole, fname, line, column) ->
    "<a data-file='#{fname}' data-line='#{line}' data-column='#{column}'>#{whole}</a>"

module.exports =
addLinks: (text) ->
  stackTracePatterns.reduce addLinksForPattern, text

onClickStackTrace: (e) ->
  {file, line, column} = e.currentTarget?.dataset
  if file
    atom.workspace.open(file).then (editor) =>
      editor.setCursorBufferPosition [line - 1, column - 1]
