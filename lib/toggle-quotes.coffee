module.exports =
  activate: ->

  deactivate: ->

  serialize: ->

  toggleQuotes: (editSession) ->
    range = editSession.bufferRangeForScopeAtCursor(".string.quoted")
    text = editSession.getTextInBufferRange(range)
    quoteCharacter = text[0]
    oppositeQuoteCharacter = getOppositeQuote(quoteCharacter)
    quoteRegex = new RegExp(quoteCharacter, 'g')
    oppositeQuoteRegex = new RegExp(oppositeQuoteCharacter, 'g')
    newText = text
      .replace(oppositeQuoteRegex, "\\#{oppositeQuoteCharacter}")
      .replace(quoteRegex, oppositeQuoteCharacter)
    editSession.setTextInBufferRange(range, newText)

getOppositeQuote = (quoteCharacter) ->
  if quoteCharacter is '"'
    "'"
  else
    '"'
