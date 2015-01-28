toggleQuotes = (editor) ->
  editor.transact ->
    for cursor in editor.getCursors()
      position = cursor.getBufferPosition()
      toggleQuoteAtPosition(editor, position)
      cursor.setBufferPosition(position)

toggleQuoteAtPosition = (editor, position) ->
  quoteChars = atom.config.get('toggle-quotes.quoteCharacters')
  range = editor.displayBuffer.bufferRangeForScopeAtPosition('.string.quoted', position)

  unless range?
    # Attempt to match the current invalid region if it is wrapped in quotes
    # This is useful for languages where changing the quotes makes the range
    # invalid and so toggling again should properly restore the valid quotes
    if range = editor.displayBuffer.bufferRangeForScopeAtPosition('.invalid.illegal', position)
      inner = quoteChars.split('').map((character) -> "#{character}.*#{character}").join('|')
      return unless ///^(#{inner})$///g.test(editor.getTextInBufferRange(range))

  return unless range?

  text = editor.getTextInBufferRange(range)
  [quoteCharacter] = text

  # In Python a string can have a prefix specifying its format. The Python
  # grammar includes this prefix in the string, and thus we need to exclude
  # it when toggling quotes
  prefix = ''
  [prefix, quoteCharacter] = text if /[uUr]/.test(quoteCharacter)

  nextQuoteCharacter = getNextQuoteCharacter(quoteCharacter, quoteChars)
  return unless nextQuoteCharacter
  quoteRegex = new RegExp(quoteCharacter, 'g')
  escapedQuoteRegex = new RegExp("\\\\#{quoteCharacter}", 'g')
  nextQuoteRegex = new RegExp(nextQuoteCharacter, 'g')

  newText = text
    .replace(nextQuoteRegex, "\\#{nextQuoteCharacter}")
    .replace(escapedQuoteRegex, quoteCharacter)
  newText = prefix + nextQuoteCharacter + newText[(1+prefix.length)...-1] + nextQuoteCharacter

  editor.setTextInBufferRange(range, newText)

getNextQuoteCharacter = (quoteCharacter, allQuoteCharacters) ->
  index = allQuoteCharacters.indexOf(quoteCharacter)
  if index is -1
    null
  else
    allQuoteCharacters[(index + 1) % allQuoteCharacters.length]

module.exports =
  config:
    quoteCharacters:
      type: 'string'
      default: '"\''

  activate: ->
    atom.commands.add 'atom-text-editor', 'toggle-quotes:toggle', ->
      if editor = atom.workspace.getActiveTextEditor()
        toggleQuotes(editor)

  toggleQuotes: toggleQuotes
