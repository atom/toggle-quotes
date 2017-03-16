'use babel'

import configSchema from './config-schema'
import {toggleQuotes} from './toggle-quotes'

export default {
  config: configSchema,

  activate () {
    this.subscription = atom.commands.add('atom-text-editor', 'toggle-quotes:toggle', () => {
      let editor = atom.workspace.getActiveTextEditor()
      if (editor) {
        toggleQuotes(editor)
      }
    })
  },

  deactivate () {
    this.subscription.dispose()
  }
}
