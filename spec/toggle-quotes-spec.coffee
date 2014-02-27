{toggleQuotes} = require '../lib/toggle-quotes'

describe "ToggleQuotes", ->
  describe "toggleQuotes(editor)", ->
    [editor, buffer] = []

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-javascript')

      runs ->
        editor = atom.project.openSync()
        buffer = editor.getBuffer()
        editor.setText """
          console.log("Hello World");
          console.log('Hello World');
          console.log("Hello 'World'");
          console.log('Hello "World"');
        """
        editor.setGrammar(atom.syntax.selectGrammar('test.js'))

    describe "when the cursor is not inside a quoted string", ->
      it "does nothing", ->
        expect(-> toggleQuotes(editor)).not.toThrow()

    describe "when the cursor is inside a double quoted string", ->
      it "switches the quotes to single", ->
        editor.setCursorBufferPosition([0, 16])
        toggleQuotes(editor)
        expect(buffer.lineForRow(0)).toBe "console.log('Hello World');"
        expect(editor.getCursorBufferPosition()).toEqual [0, 16]

    describe "when the cursor is inside a single quoted string", ->
      it "switches the quotes to double", ->
        editor.setCursorBufferPosition([1, 16])
        toggleQuotes(editor)
        expect(buffer.lineForRow(1)).toBe 'console.log("Hello World");'
        expect(editor.getCursorBufferPosition()).toEqual [1, 16]

    describe "when the cursor is inside a single-quoted string that is nested within a double quoted string", ->
      it "switches the outer quotes to single and escapes the inner quotes", ->
        editor.setCursorBufferPosition([2, 22])
        toggleQuotes(editor)
        expect(buffer.lineForRow(2)).toBe "console.log('Hello \\'World\\'');"
        expect(editor.getCursorBufferPosition()).toEqual [2, 22]

        toggleQuotes(editor)
        expect(buffer.lineForRow(2)).toBe 'console.log("Hello \'World\'");'

    describe "when the cursor is inside a double-quoted string that is nested within a single quoted string", ->
      it "switches the outer quotes to double and escapes the inner quotes", ->
        editor.setCursorBufferPosition([3, 22])
        toggleQuotes(editor)
        expect(buffer.lineForRow(3)).toBe 'console.log("Hello \\"World\\"");'
        expect(editor.getCursorBufferPosition()).toEqual [3, 22]

        toggleQuotes(editor)
        expect(buffer.lineForRow(3)).toBe "console.log('Hello \"World\"');"
