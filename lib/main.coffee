{toggleQuotes} = require 'toggle-quotes'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    quoteCharacters:
      type: 'string'
      default: '"\''

  activate: ->
    @subscriptions.add atom.commands.add 'atom-text-editor', 'toggle-quotes:toggle', ->
      if editor = atom.workspace.getActiveTextEditor()
        toggleQuotes(editor)

  deactivate: ->
    @subscriptions.dispose()
