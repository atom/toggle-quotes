EditSession = require 'edit-session'

toggleQuotes = (editSession) ->
  previousCursorPosition = editSession.getCursorBufferPosition()
  range = editSession.bufferRangeForScopeAtCursor('.string.quoted')
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

module.exports =
  activate: ->
    rootView.command 'toggle-quotes:toggle', ->
      paneItem = rootView.getActivePaneItem()
      toggleQuotes(paneItem) if paneItem instanceof EditSession

  toggleQuotes: toggleQuotes
