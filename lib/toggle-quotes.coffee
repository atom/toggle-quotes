module.exports =
  activate: ->

  deactivate: ->

  serialize: ->

  toggleQuotes: (editSession) ->
    previousCursorPosition = editSession.getCursorBufferPosition()
    range = editSession.bufferRangeForScopeAtCursor(".string.quoted")
    text = editSession.getTextInBufferRange(range)
    quoteCharacter = text[0]
    oppositeQuoteCharacter = getOppositeQuote(quoteCharacter)
    quoteRegex = new RegExp(quoteCharacter, 'g')
    escapedQuoteRegex = new RegExp("\\\\#{quoteCharacter}", 'g')
    oppositeQuoteRegex = new RegExp(oppositeQuoteCharacter, 'g')

    newText = text
      .replace(oppositeQuoteRegex, "\\#{oppositeQuoteCharacter}")
      .replace(escapedQuoteRegex, quoteCharacter)
    newText = oppositeQuoteCharacter + newText[1...-1] + oppositeQuoteCharacter

    editSession.setTextInBufferRange(range, newText)
    editSession.setCursorBufferPosition(previousCursorPosition)

getOppositeQuote = (quoteCharacter) ->
  if quoteCharacter is '"'
    "'"
  else
    '"'
