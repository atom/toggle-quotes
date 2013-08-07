{toggleQuotes} = require '../lib/toggle-quotes'

describe "ToggleQuotes", ->
  describe "toggleQuotes(editSession)", ->
    [editSession, buffer] = []

    beforeEach ->
      atom.activatePackage('javascript-tmbundle', sync: true)

      editSession = project.open()
      buffer = editSession.getBuffer()
      buffer.setText """
        console.log("Hello World");
        console.log('Hello World');
        console.log("Hello 'World'");
        console.log('Hello "World"');
      """
      editSession.setGrammar(syntax.selectGrammar('test.js'))

    describe "when the cursor is inside a double quoted string", ->
      it "switches the quotes to single", ->
        editSession.setCursorBufferPosition([0, 16])
        toggleQuotes(editSession)
        expect(buffer.lineForRow(0)).toBe "console.log('Hello World');"
        expect(editSession.getCursorBufferPosition()).toEqual [0, 16]

    describe "when the cursor is inside a single quoted string", ->
      it "switches the quotes to double", ->
        editSession.setCursorBufferPosition([1, 16])
        toggleQuotes(editSession)
        expect(buffer.lineForRow(1)).toBe 'console.log("Hello World");'
        expect(editSession.getCursorBufferPosition()).toEqual [1, 16]

    describe "when the cursor is inside a single-quoted string that is nested within a double quoted string", ->
      it "switches the outer quotes to single and escapes the inner quotes", ->
        editSession.setCursorBufferPosition([2, 22])
        toggleQuotes(editSession)
        expect(buffer.lineForRow(2)).toBe "console.log('Hello \\'World\\'');"
        expect(editSession.getCursorBufferPosition()).toEqual [2, 22]

    describe "when the cursor is inside a double-quoted string that is nested within a single quoted string", ->
      it "switches the outer quotes to double and escapes the inner quotes", ->
        editSession.setCursorBufferPosition([3, 22])
        toggleQuotes(editSession)
        expect(buffer.lineForRow(3)).toBe 'console.log("Hello \\"World\\"");'
        expect(editSession.getCursorBufferPosition()).toEqual [3, 22]
