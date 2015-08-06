{toggleQuotes} = require 'toggle-quotes'

module.exports =
  config:
    quoteCharacters:
      type: 'string'
      default: '"\''

  activate: ->
    atom.commands.add 'atom-text-editor', 'toggle-quotes:toggle', ->
      if editor = atom.workspace.getActiveTextEditor()
        toggleQuotes(editor)
