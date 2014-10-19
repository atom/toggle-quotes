toggleQuotes = (editor) ->
  editor.transact ->
    lineTokens = tokenizeLines(editor)
    stringLimitTokens = findQuotedStringStartAndEndTokens(lineTokens)

    for cursor in editor.getCursors()
      position = cursor.getBufferPosition()
      toggleQuoteAtPosition(editor, position, stringLimitTokens)
      cursor.setBufferPosition(position)

toggleQuoteAtPosition = (editor, position, stringLimitTokens) ->
  quotedStringRangeTokens = findQuotedStringRangeTokens(stringLimitTokens, position)

  if quotedStringRangeTokens
    start = [quotedStringRangeTokens[0].row, quotedStringRangeTokens[0].column]
    end = [quotedStringRangeTokens[1].row, quotedStringRangeTokens[1].column + quotedStringRangeTokens[1].bufferDelta]
    range = [start, end]

    # In Python a string can have a prefix specifying its format. The Python
    # grammar includes this prefix in the string, and thus we need to exclude
    # it when toggling quotes
    startRegex = new RegExp("""^([uUr]?)(["']+)""")
    matches = quotedStringRangeTokens[0].value.match(startRegex)
    if matches
      text = editor.getTextInBufferRange(range)
      prefix = matches[1] or ""
      quoteString = matches[2]
      quoteCharacter = quoteString[0]
    else
      # Will only happen if the string doesn't start with " or '
      range = null

  if not range?
    # Attempt to match the current invalid region if it is wrapped in quotes
    # This is useful for languages where changing the quotes makes the range
    # invalid and so toggling again should properly restore the valid quotes
    if range = editor.displayBuffer.bufferRangeForScopeAtPosition('.invalid.illegal', position)
      return unless /^(".*"|'.*')$/.test(editor.getTextInBufferRange(range))

      text = editor.getTextInBufferRange(range)
      prefix = ''
      [quoteCharacter] = text
      quoteString = quoteCharacter

  return unless range?

  quoteRegex = new RegExp(quoteCharacter, 'g')
  oppositeQuoteCharacter = getOppositeQuote(quoteCharacter)
  oppositeQuoteString = quoteString.replace(quoteRegex, oppositeQuoteCharacter)

  innerText = text[(prefix.length + oppositeQuoteString.length)...-(oppositeQuoteString.length)]

  # If quoteString is " (and oppositeQuoteString is '), we want to replace
  # all ' in the text with \' (we must escape it now), and all \" with "
  # (no need to escape any more)

  # Likewise, if quoteString is """ (and oppositeQuoteString is '''), we want to replace all '''
  # in the text with \'\'\' (we must escape it), and all \"\"\" with """ (no need to escape any
  # more). We can ignore Single or double " and '

  escapedQuoteRegex = new RegExp(("\\\\#{c}" for c in quoteString).join(''), 'g')
  oppositeQuoteRegex = new RegExp(oppositeQuoteString, 'g')
  escapedOppositeQuoteString = ("\\#{c}" for c in oppositeQuoteString).join('')

  innerText = innerText
    .replace(oppositeQuoteRegex, escapedOppositeQuoteString)
    .replace(escapedQuoteRegex, quoteString)

  newText = prefix + oppositeQuoteString + innerText + oppositeQuoteString

  editor.setTextInBufferRange(range, newText)

tokenizeLines = (editor) ->
  grammar = editor.getGrammar()
  lineTokens = grammar.tokenizeLines(editor.getText())

  # Mark each token with its position in the buffer
  row = 0
  for line in lineTokens
    column = 0
    for token in line
      token.row = row
      token.column = column
      column += token.bufferDelta
    row += 1

  lineTokens

findQuotedStringStartAndEndTokens = (lineTokens) ->
  return [] if not lineTokens

  # Find and categorize all quoted string start and end tokens
  stringLimitTokens = []
  for line in lineTokens
    for token in line
      for scope in token.scopeDescriptor
        if scope.indexOf(".string.begin") != -1
          token.stringLimitType = 'start'
          stringLimitTokens.push token
        if scope.indexOf(".string.end") != -1
          token.stringLimitType = 'end'
          stringLimitTokens.push token

  return stringLimitTokens

findQuotedStringRangeTokens = (stringLimitTokens, position) ->
  # If there aren't any string tokens, there isn't a valid range
  if not stringLimitTokens
    return null

  prePositionTokens = stringLimitTokens.filter (token) ->
    if token.row < position.row or (token.row == position.row and (token.column + token.bufferDelta) < position.column)
      # The token is cleary before the position
      return true
    if token.row == position.row and token.column < position.column
      # The position is *on the token*
      return token.stringLimitType == 'start'
    return false

  postPositionTokens = stringLimitTokens.filter (token) ->
    if token.row > position.row or (token.row == position.row and token.column >= position.column)
      # The token is cleary after the position
      return true
    if token.row == position.row and token.column < position.column and (token.column + token.bufferDelta) > position.column
      # The position is *on the token*
      return token.stringLimitType == 'end'
    return false

  [..., lastPrePositionToken] = prePositionTokens
  if not lastPrePositionToken or lastPrePositionToken.stringLimitType != 'start'
    # The string limit token closest before the position must be a start token
    # for the position to be in the range of a quoted string
    return null

  [firstPostPositionToken] = postPositionTokens
  if not firstPostPositionToken or firstPostPositionToken.stringLimitType != 'end'
    # The string limit token closest after the position must be an end token
    # for the position to be in the range of a quoted string
    return null

  [lastPrePositionToken, firstPostPositionToken]

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
