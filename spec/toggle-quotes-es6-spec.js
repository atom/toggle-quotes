'use babel';

import {toggleQuotes} from '../lib/toggle-quotes-es6';
import {raw as r} from '../lib/string-helper';

describe("ToggleQuotes", () => {
  beforeEach(() => {
    atom.config.set('toggle-quotes.quoteCharacters', '\'"');
  });

  describe("toggleQuotes(editor) js", () => {
    let editor = null;

    beforeEach(() => {
      waitsForPromise(() => {
        return atom.packages.activatePackage('language-javascript');
      });

      waitsForPromise(() => {
        return atom.packages.activatePackage('language-json');
      });

      waitsForPromise(() => {
        return atom.workspace.open();
      });

      runs(() => {
        editor = atom.workspace.getActiveTextEditor();
        editor.setText(
          r`console.log("Hello World");
          console.log('Hello World');
          console.log("Hello 'World'");
          console.log('Hello "World"');
          console.log('');`
        );
        editor.setGrammar(atom.grammars.selectGrammar('test.js'));
      });
    });

    describe("when the cursor is not inside a quoted string", () => {
      it("does nothing", () => {
        expect(() => toggleQuotes(editor)).not.toThrow();
      });
    });

    describe("when the cursor is inside an empty single quoted string", () => {
      it("switches the quotes to double", () => {
        editor.setCursorBufferPosition([4, 13]);
        toggleQuotes(editor);
        expect(editor.lineTextForBufferRow(4)).toBe('console.log("");');
        expect(editor.getCursorBufferPosition()).toEqual([4, 13]);
      });
    });
  });
});
