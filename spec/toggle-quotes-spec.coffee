{toggleQuotes} = require '../lib/toggle-quotes'

describe "ToggleQuotes", ->
  describe "toggleQuotes(editor) js", ->
    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-javascript')

      waitsForPromise ->
        atom.packages.activatePackage('language-json')

      runs ->
        editor = atom.project.openSync()
        editor.setText """
          console.log("Hello World");
          console.log('Hello World');
          console.log("Hello 'World'");
          console.log('Hello "World"');
          console.log('');
        """
        editor.setGrammar(atom.syntax.selectGrammar('test.js'))

    describe "when the cursor is not inside a quoted string", ->
      it "does nothing", ->
        expect(-> toggleQuotes(editor)).not.toThrow()

    describe "when the cursor is inside an empty single quoted string", ->
      it "switches the quotes to double", ->
        editor.setCursorBufferPosition([4, 13])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(4)).toBe 'console.log("");'
        expect(editor.getCursorBufferPosition()).toEqual [4, 13]

    describe "when the cursor is inside a double quoted string", ->
      it "switches the quotes to single", ->
        editor.setCursorBufferPosition([0, 16])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(0)).toBe "console.log('Hello World');"
        expect(editor.getCursorBufferPosition()).toEqual [0, 16]

    describe "when the cursor is inside a single quoted string", ->
      it "switches the quotes to double", ->
        editor.setCursorBufferPosition([1, 16])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(1)).toBe 'console.log("Hello World");'
        expect(editor.getCursorBufferPosition()).toEqual [1, 16]

    describe "when the cursor is inside a single-quoted string that is nested within a double quoted string", ->
      it "switches the outer quotes to single and escapes the inner quotes", ->
        editor.setCursorBufferPosition([2, 22])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(2)).toBe "console.log('Hello \\'World\\'');"
        expect(editor.getCursorBufferPosition()).toEqual [2, 22]

        toggleQuotes(editor)
        expect(editor.lineForBufferRow(2)).toBe 'console.log("Hello \'World\'");'

    describe "when the cursor is inside a double-quoted string that is nested within a single quoted string", ->
      it "switches the outer quotes to double and escapes the inner quotes", ->
        editor.setCursorBufferPosition([3, 22])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(3)).toBe 'console.log("Hello \\"World\\"");'
        expect(editor.getCursorBufferPosition()).toEqual [3, 22]

        toggleQuotes(editor)
        expect(editor.lineForBufferRow(3)).toBe "console.log('Hello \"World\"');"

    describe "when the cursor is inside multiple quoted strings", ->
      it "switches the quotes of both quoted strings separately and leaves the cursors where they were, and does so atomically", ->
        editor.setCursorBufferPosition([0, 16])
        editor.addCursorAtBufferPosition([1, 16])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(0)).toBe "console.log('Hello World');"
        expect(editor.lineForBufferRow(1)).toBe 'console.log("Hello World");'
        expect(editor.getCursors()[0].getBufferPosition()).toEqual [0, 16]
        expect(editor.getCursors()[1].getBufferPosition()).toEqual [1, 16]

        editor.undo()
        expect(editor.lineForBufferRow(0)).toBe 'console.log("Hello World");'
        expect(editor.lineForBufferRow(1)).toBe "console.log('Hello World');"
        expect(editor.getCursors()[0].getBufferPosition()).toEqual [0, 16]
        expect(editor.getCursors()[1].getBufferPosition()).toEqual [1, 16]

    describe "when the cursor is on an invalid region", ->
      describe "when it is quoted", ->
        it "toggles the quotes", ->
          editor.setGrammar(atom.syntax.selectGrammar('test.json'))
          editor.setText("{'invalid': true}")
          editor.setCursorBufferPosition([0, 4])
          toggleQuotes(editor)
          expect(editor.getText()).toBe '{"invalid": true}'

      describe "when it is not quoted", ->
        it "does not toggle the quotes", ->
          editor.setGrammar(atom.syntax.selectGrammar('test.json'))
          editor.setText("{invalid: true}")
          editor.setCursorBufferPosition([0, 4])
          toggleQuotes(editor)
          expect(editor.getText()).toBe '{invalid: true}'

  describe "toggleQuotes(editor) python", ->
    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-python')

      runs ->
        editor = atom.project.openSync()
        editor.setText """
          print(u"Hello World")
          print(r'')
          print(u'''Hello there''')
        """
        editor.setGrammar(atom.syntax.selectGrammar('test.py'))

    describe "when cursor is inside a double quoted unicode string", ->
      it "switches quotes to single excluding unicode character", ->
        editor.setCursorBufferPosition([0, 16])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(0)).toBe "print(u'Hello World')"
        expect(editor.getCursorBufferPosition()).toEqual [0, 16]

    describe "when cursor is inside an empty single quoted raw string", ->
      it "switches quotes to double", ->
        editor.setCursorBufferPosition([1, 8])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(1)).toBe 'print(r"")'
        expect(editor.getCursorBufferPosition()).toEqual [1, 8]

    describe "when cursor is inside a single quoted unicode multiline string", ->
      it "switches quotes to double excluding unicode character", ->
        editor.setCursorBufferPosition([2, 16])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(2)).toBe '''print(u"""Hello there""")'''
        expect(editor.getCursorBufferPosition()).toEqual [2, 16]

  describe "toggleQuotes(editor) coffeescript", ->
    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      runs ->
        editor = atom.project.openSync()
        editor.setGrammar(atom.syntax.selectGrammar('test.coffee'))

    describe "when cursor is inside a double quoted block single line string", ->
      beforeEach ->
        editor.setText '''
          console.log("""Hello World""")
          console.log("""Hello 'World'""")
          console.log("""Hello \'\'\'World\'\'\'""")
          console.log("""""")
        '''

      it "switches quotes to single", ->
        editor.setCursorBufferPosition([0, 14])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(0)).toBe """console.log('''Hello World''')"""
        expect(editor.getCursorBufferPosition()).toEqual [0, 14]

      it "switches quotes to single but does not escape single single quotes", ->
        editor.setCursorBufferPosition([1, 14])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(1)).toBe """console.log('''Hello 'World'''')"""
        expect(editor.getCursorBufferPosition()).toEqual [1, 14]

      it "switches quotes to single and escapes three single quotes", ->
        editor.setCursorBufferPosition([2, 14])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(2)).toBe """console.log('''Hello \\'\\'\\'World\\'\\'\\'''')"""
        expect(editor.getCursorBufferPosition()).toEqual [2, 14]

      describe "which is empty", ->
        it "switches quotes to single when cursor is inside string", ->
          editor.setCursorBufferPosition([3, 15])
          toggleQuotes(editor)
          expect(editor.lineForBufferRow(3)).toBe """console.log('''''')"""
          expect(editor.getCursorBufferPosition()).toEqual [3, 15]

        it "switches quotes to single when cursor is inside start quotes", ->
          editor.setCursorBufferPosition([3, 13])
          toggleQuotes(editor)
          expect(editor.lineForBufferRow(3)).toBe """console.log('''''')"""
          expect(editor.getCursorBufferPosition()).toEqual [3, 13]

        it "switches quotes to single when cursor is inside end quotes", ->
          editor.setCursorBufferPosition([3, 16])
          toggleQuotes(editor)
          expect(editor.lineForBufferRow(3)).toBe """console.log('''''')"""
          expect(editor.getCursorBufferPosition()).toEqual [3, 16]

    describe "when cursor is inside a single quoted block single line string", ->
      beforeEach ->
        editor.setText """
          console.log('''Hello World''')
          console.log('''Hello "World"''')
          console.log('''Hello \"\"\"World\"\"\"''')
        """

      it "switches quotes to double", ->
        editor.setCursorBufferPosition([0, 14])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(0)).toBe '''console.log("""Hello World""")'''
        expect(editor.getCursorBufferPosition()).toEqual [0, 14]

      it "switches quotes to double but does not escape double single quotes", ->
        editor.setCursorBufferPosition([1, 14])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(1)).toBe '''console.log("""Hello "World"""")'''
        expect(editor.getCursorBufferPosition()).toEqual [1, 14]

      it "switches quotes to double and escapes three double quotes", ->
        editor.setCursorBufferPosition([2, 14])
        toggleQuotes(editor)
        expect(editor.lineForBufferRow(2)).toBe '''console.log("""Hello \\"\\"\\"World\\"\\"\\"""")'''
        expect(editor.getCursorBufferPosition()).toEqual [2, 14]

    describe "when cursor is inside a double quoted multiline block string", ->
      describe "with one line of text", ->
        beforeEach ->
          editor.setText '''
            console.log("""
              Hello World
            """)
          '''
        it "switches quotes to single", ->
          editor.setCursorBufferPosition([1, 8])
          toggleQuotes(editor)
          expect(editor.getText()).toBe """
            console.log('''
              Hello World
            ''')
          """
          expect(editor.getCursorBufferPosition()).toEqual [1, 8]

      describe "with no lines", ->
        beforeEach ->
          editor.setText '''
            console.log("""
            """)
          '''
        it "switches quotes to single", ->
          editor.setCursorBufferPosition([1, 1])
          toggleQuotes(editor)
          expect(editor.getText()).toBe """
            console.log('''
            ''')
          """
          expect(editor.getCursorBufferPosition()).toEqual [1, 1]

      describe "with multiple empty lines", ->
        beforeEach ->
          editor.setText '''
            console.log("""


            """)
          '''
        it "switches quotes to single", ->
          editor.setCursorBufferPosition([1, 0])
          toggleQuotes(editor)
          expect(editor.getText()).toBe """
            console.log('''


            ''')
          """
          expect(editor.getCursorBufferPosition()).toEqual [1, 0]

      describe "with multiple lines of content", ->
        beforeEach ->
          editor.setText '''
            console.log("""
              Hello there,

              'World!'
              "this is the real life"

            """)
          '''
        it "switches quotes to single", ->
          editor.setCursorBufferPosition([1, 3])
          toggleQuotes(editor)
          expect(editor.getText()).toBe """
            console.log('''
              Hello there,

              'World!'
              "this is the real life"

            ''')
          """
          expect(editor.getCursorBufferPosition()).toEqual [1, 3]

    describe "when cursor is inside a double quoted multiline string", ->
      describe "with one line of text", ->
        beforeEach ->
          editor.setText '''
            console.log("
              Hello World
            ")
          '''
        it "switches quotes to single", ->
          editor.setCursorBufferPosition([1, 8])
          toggleQuotes(editor)
          expect(editor.getText()).toBe """
            console.log('
              Hello World
            ')
          """
          expect(editor.getCursorBufferPosition()).toEqual [1, 8]

      describe "with no lines", ->
        beforeEach ->
          editor.setText '''
            console.log("
            ")
          '''
        it "switches quotes to single", ->
          editor.setCursorBufferPosition([1, 0])
          toggleQuotes(editor)
          expect(editor.getText()).toBe """
            console.log('
            ')
          """
          expect(editor.getCursorBufferPosition()).toEqual [1, 0]

  describe "toggleQuotes(editor) html", ->
    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-html')
      waitsForPromise ->
        atom.packages.activatePackage('language-javascript')

      runs ->
        editor = atom.project.openSync()
        editor.setText """
          <script type="test/javascript">
          var x = "asdfasdf";
          </script>
        """
        editor.setGrammar(atom.syntax.selectGrammar('test.html'))

    describe "when cursor is inside a double quoted html string", ->
      it "switches quotes to single", ->
        editor.setCursorBufferPosition([0, 16])
        toggleQuotes(editor)
        expect(editor.getText()).toBe """
          <script type='test/javascript'>
          var x = "asdfasdf";
          </script>
        """
        expect(editor.getCursorBufferPosition()).toEqual [0, 16]

    describe "when cursor is inside a double quoted embedded javascript string", ->
      it "switches quotes to single", ->
        editor.setCursorBufferPosition([1, 10])
        toggleQuotes(editor)
        expect(editor.getText()).toBe """
          <script type="test/javascript">
          var x = 'asdfasdf';
          </script>
        """
        expect(editor.getCursorBufferPosition()).toEqual [1, 10]
