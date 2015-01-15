{toggleQuotes} = require '../lib/toggle-quotes'

describe "ToggleQuotes", ->
  beforeEach ->
    atom.config.set('toggle-quotes.quoteCharacters', '\'"')

  describe "toggleQuotes(editor) js", ->
    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-javascript')

      waitsForPromise ->
        atom.packages.activatePackage('language-json')

      waitsForPromise ->
        atom.workspace.open()

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setText """
          console.log("Hello World");
          console.log('Hello World');
          console.log("Hello 'World'");
          console.log('Hello "World"');
          console.log('');
        """
        editor.setGrammar(atom.grammars.selectGrammar('test.js'))

    describe "when the cursor is not inside a quoted string", ->
      it "does nothing", ->
        expect(-> toggleQuotes(editor)).not.toThrow()

    describe "when the cursor is inside an empty single quoted string", ->
      it "switches the quotes to double", ->
        editor.setCursorBufferPosition([4, 13])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(4)).toBe 'console.log("");'
        expect(editor.getCursorBufferPosition()).toEqual [4, 13]

    describe "when the cursor is inside a double quoted string", ->
      describe "when using default config", ->
        it "switches the double quotes to single quotes", ->
          editor.setCursorBufferPosition([0, 16])
          toggleQuotes(editor)
          expect(editor.lineTextForBufferRow(0)).toBe "console.log('Hello World');"
          expect(editor.getCursorBufferPosition()).toEqual [0, 16]

      describe "when using custom config of backticks", ->
        it "switches the double quotes to backticks", ->
          atom.config.set('toggle-quotes.quoteCharacters', '\'"`')
          editor.setCursorBufferPosition([0, 16])
          toggleQuotes(editor)
          expect(editor.lineTextForBufferRow(0)).toBe "console.log(`Hello World`);"
          expect(editor.getCursorBufferPosition()).toEqual [0, 16]

    describe "when the cursor is inside a single quoted string", ->
      it "switches the quotes to double", ->
        editor.setCursorBufferPosition([1, 16])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(1)).toBe 'console.log("Hello World");'
        expect(editor.getCursorBufferPosition()).toEqual [1, 16]

    describe "when the cursor is inside a single-quoted string that is nested within a double quoted string", ->
      it "switches the outer quotes to single and escapes the inner quotes", ->
        editor.setCursorBufferPosition([2, 22])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(2)).toBe "console.log('Hello \\'World\\'');"
        expect(editor.getCursorBufferPosition()).toEqual [2, 22]

        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(2)).toBe 'console.log("Hello \'World\'");'

    describe "when the cursor is inside a double-quoted string that is nested within a single quoted string", ->
      it "switches the outer quotes to double and escapes the inner quotes", ->
        editor.setCursorBufferPosition([3, 22])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(3)).toBe 'console.log("Hello \\"World\\"");'
        expect(editor.getCursorBufferPosition()).toEqual [3, 22]

        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(3)).toBe "console.log('Hello \"World\"');"

    describe "when the cursor is inside multiple quoted strings", ->
      it "switches the quotes of both quoted strings separately and leaves the cursors where they were, and does so atomically", ->
        editor.setCursorBufferPosition([0, 16])
        editor.addCursorAtBufferPosition([1, 16])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(0)).toBe "console.log('Hello World');"
        expect(editor.lineTextForBufferRow(1)).toBe 'console.log("Hello World");'
        expect(editor.getCursors()[0].getBufferPosition()).toEqual [0, 16]
        expect(editor.getCursors()[1].getBufferPosition()).toEqual [1, 16]

        editor.undo()
        expect(editor.lineTextForBufferRow(0)).toBe 'console.log("Hello World");'
        expect(editor.lineTextForBufferRow(1)).toBe "console.log('Hello World');"
        expect(editor.getCursors()[0].getBufferPosition()).toEqual [0, 16]
        expect(editor.getCursors()[1].getBufferPosition()).toEqual [1, 16]

    describe "when the cursor is on an invalid region", ->
      describe "when it is quoted", ->
        it "toggles the quotes", ->
          editor.setGrammar(atom.grammars.selectGrammar('test.json'))
          editor.setText("{'invalid': true}")
          editor.setCursorBufferPosition([0, 4])
          toggleQuotes(editor)
          expect(editor.getText()).toBe '{"invalid": true}'

      describe "when it is not quoted", ->
        it "does not toggle the quotes", ->
          editor.setGrammar(atom.grammars.selectGrammar('test.json'))
          editor.setText("{invalid: true}")
          editor.setCursorBufferPosition([0, 4])
          toggleQuotes(editor)
          expect(editor.getText()).toBe '{invalid: true}'

  describe "toggleQuotes(editor) python", ->
    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-python')

      waitsForPromise ->
        atom.workspace.open()

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setText """
          print(u"Hello World")
          print(r'')
        """
        editor.setGrammar(atom.grammars.selectGrammar('test.py'))

    describe "when cursor is inside a double quoted unicode string", ->
      it "switches quotes to single excluding unicode character", ->
        editor.setCursorBufferPosition([0, 16])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(0)).toBe "print(u'Hello World')"
        expect(editor.getCursorBufferPosition()).toEqual [0, 16]

    describe "when cursor is inside an empty single quoted raw string", ->
      it "switches quotes to double", ->
        editor.setCursorBufferPosition([1, 8])
        toggleQuotes(editor)
        expect(editor.lineTextForBufferRow(1)).toBe 'print(r"")'
        expect(editor.getCursorBufferPosition()).toEqual [1, 8]

  it "activates when a command is triggered", ->
    activatePromise = atom.packages.activatePackage('toggle-quotes')

    waitsForPromise ->
      atom.workspace.open()

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      atom.commands.dispatch(atom.views.getView(editor), 'toggle-quotes:toggle')

    waitsForPromise -> activatePromise
