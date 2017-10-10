'use babel'

import {toggleQuotes} from '../lib/toggle-quotes'
import {raw as r} from '../lib/string-helper'

describe('ToggleQuotes', () => {
  beforeEach(() => {
    atom.config.set('toggle-quotes.quoteCharacters', '\'"`')
  })

  describe('toggleQuotes(editor) typescript', () => {
    let editor = null

    beforeEach(() => {
      waitsForPromise(() => {
        return atom.packages.activatePackage('atom-typescript')
      })

      waitsForPromise(() => {
        return atom.workspace.open()
      })

      runs(() => {
        editor = atom.workspace.getActiveTextEditor()
        editor.setText(
          r`let foo = "foo"
          let bar = 'bar'
          let baz = \`baz\``
        )
        editor.setGrammar(atom.grammars.selectGrammar('test.ts'))
      })
    })

    describe('when cursor is inside a double quoted string', () => {
      it('switches quotes to backtick character', () => {
        editor.setCursorBufferPosition([0, 16])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(0)).toBe("let foo = `foo`")
        expect(editor.getCursorBufferPosition()).toEqual([0, 16])
      })
    })
  })

})
