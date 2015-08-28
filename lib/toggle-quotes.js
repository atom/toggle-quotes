'use babel'

export const toggleQuotes = (editor) => {
  editor.transact(() => {
    for (let cursor of editor.getCursors()) {
      let position = cursor.getBufferPosition()
      toggleQuoteAtPosition(editor, position)
      cursor.setBufferPosition(position)
    }
  })
}

const getNextQuoteCharacter = (quoteCharacter, allQuoteCharacters) => {
  let index = allQuoteCharacters.indexOf(quoteCharacter)
  if (index === -1) {
    return null
  } else {
    return allQuoteCharacters[(index + 1) % allQuoteCharacters.length]
  }
}

const toggleQuoteAtPosition = (editor, position) => {
  let quoteChars = atom.config.get('toggle-quotes.quoteCharacters')
  let range = editor.displayBuffer.bufferRangeForScopeAtPosition('.string.quoted', position)

  if (range == null) {
    // Attempt to match the current invalid region if it is wrapped in quotes
    // This is useful for languages where changing the quotes makes the range
    // invalid and so toggling again should properly restore the valid quotes

    range = editor.displayBuffer.bufferRangeForScopeAtPosition('.invalid.illegal', position)
    if (range) {
      let inner = quoteChars.split('').map(character => `${character}.*${character}`).join('|')

      if (!RegExp(`^(${inner})$`, 'g').test(editor.getTextInBufferRange(range))) {
        return
      }
    }
  }

  if (range == null) {
    return
  }

  let text = editor.getTextInBufferRange(range)
  let [quoteCharacter] = text

  // In Python a string can have a prefix specifying its format. The Python
  // grammar includes this prefix in the string, and thus we need to exclude
  // it when toggling quotes
  let prefix = ''
  if (/[uUr]/.test(quoteCharacter)) {
    [prefix, quoteCharacter] = text
  }

  let nextQuoteCharacter = getNextQuoteCharacter(quoteCharacter, quoteChars)

  if (!nextQuoteCharacter) {
    return
  }

  // let quoteRegex = new RegExp(quoteCharacter, 'g')
  let escapedQuoteRegex = new RegExp(`\\\\${quoteCharacter}`, 'g')
  let nextQuoteRegex = new RegExp(nextQuoteCharacter, 'g')

  let newText = text
    .replace(nextQuoteRegex, `\\${nextQuoteCharacter}`)
    .replace(escapedQuoteRegex, quoteCharacter)

  newText = prefix + nextQuoteCharacter + newText.slice(1 + prefix.length, -1) + nextQuoteCharacter

  editor.setTextInBufferRange(range, newText)
}
