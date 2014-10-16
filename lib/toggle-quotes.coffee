toggleQuotes = (editor) ->
  editor.transact ->
    for cursor in editor.getCursors()
      position = cursor.getBufferPosition()
      toggleQuoteAtPosition(editor, position)
      cursor.setBufferPosition(position)

toggleQuoteAtPosition = (editor, position) ->
  range = editor.displayBuffer.bufferRangeForScopeAtPosition('.string.quoted', position)

  unless range?
    # Attempt to match the current invalid region if it is wrapped in quotes
    # This is useful for languages where changing the quotes makes the range
    # invalid and so toggling again should properly restore the valid quotes
    if range = editor.displayBuffer.bufferRangeForScopeAtPosition('.invalid.illegal', position)
      return unless /^(".*"|'.*')$/.test(editor.getTextInBufferRange(range))

  return unless range?

  text = editor.getTextInBufferRange(range)
  [quoteCharacter] = text

  # In Python a string can have a prefix specifying its format. The Python
  # grammar includes this prefix in the string, and thus we need to exclude
  # it when toggling quotes
  prefix = ''
  [prefix, quoteCharacter] = text if /[uUr]/.test(quoteCharacter)

  oppositeQuoteCharacter = getOppositeQuote(quoteCharacter)
  quoteRegex = new RegExp(quoteCharacter, 'g')
  escapedQuoteRegex = new RegExp("\\\\#{quoteCharacter}", 'g')
  oppositeQuoteRegex = new RegExp(oppositeQuoteCharacter, 'g')

  newText = text
    .replace(oppositeQuoteRegex, "\\#{oppositeQuoteCharacter}")
    .replace(escapedQuoteRegex, quoteCharacter)
  newText = prefix + oppositeQuoteCharacter + newText[(1+prefix.length)...-1] + oppositeQuoteCharacter

  editor.setTextInBufferRange(range, newText)

getOppositeQuote = (quoteCharacter) ->
  if quoteCharacter is '"'
    "'"
  else
    '"'

module.exports =
  activate: ->
    atom.workspaceView.command 'toggle-quotes:toggle', '.editor', ->
      editor = atom.workspace.getActiveEditor()
      toggleQuotes(editor)

  toggleQuotes: toggleQuotes
