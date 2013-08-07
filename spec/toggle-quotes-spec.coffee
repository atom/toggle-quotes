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

    describe "when the cursor is inside a single quoted string", ->
      it "switches the quotes to double", ->
        editSession.setCursorBufferPosition([1, 16])
        toggleQuotes(editSession)
        expect(buffer.lineForRow(1)).toBe 'console.log("Hello World");'
