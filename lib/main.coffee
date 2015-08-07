{toggleQuotes} = require './toggle-quotes'

module.exports =
  config:
    quoteCharacters:
      type: 'string'
      default: '"\''

  activate: ->
    @subscription = atom.commands.add 'atom-text-editor', 'toggle-quotes:toggle', ->
      if editor = atom.workspace.getActiveTextEditor()
        toggleQuotes(editor)

  deactivate: ->
    @subscription.dispose()
