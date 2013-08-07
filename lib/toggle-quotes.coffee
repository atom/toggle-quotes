module.exports =
  activate: ->

  deactivate: ->

  serialize: ->

  toggleQuotes: (editSession) ->
    range = editSession.bufferRangeForScopeAtCursor(".string.quoted")
    text = editSession.getTextInBufferRange(range)
    quoteCharacter = text[0]
    oppositeQuoteCharacter = getOppositeQuote(quoteCharacter)
    newText = text.replace(new RegExp(quoteCharacter, 'g'), oppositeQuoteCharacter)
    editSession.setTextInBufferRange(range, newText)

getOppositeQuote = (quoteCharacter) ->
  if quoteCharacter is '"'
    "'"
  else
    '"'
