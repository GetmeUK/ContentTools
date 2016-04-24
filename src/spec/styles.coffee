# StylePalette

describe 'ContentTools.StylePalette.add()', () ->

    afterEach ->
        ContentTools.StylePalette._styles = []

    it 'should return a `ContentTools.Style` instance', () ->
        style = new ContentTools.Style('test', 'test', ['p'])
        ContentTools.StylePalette.add(style)
        p = new ContentEdit.Text('p', {}, 'foo')
        expect(ContentTools.StylePalette.styles(p)).toEqual [style]


describe 'ContentTools.StylePalette.styles()', () ->

    afterEach ->
        ContentTools.StylePalette._styles = []

    it 'should return a list of `ContentTools.Style` instances by tag
            name', () ->

        # Add a set of styles for by different tags
        test1 = new ContentTools.Style('Test 1', 'test-1', ['p'])
        test2 = new ContentTools.Style('Test 2', 'test-2', ['h1', 'p'])
        test3 = new ContentTools.Style('Test 3', 'test-3', ['h1', 'h2'])
        ContentTools.StylePalette.add(test1)
        ContentTools.StylePalette.add(test2)
        ContentTools.StylePalette.add(test3)

        p = new ContentEdit.Text('p', {}, 'foo')
        h1 = new ContentEdit.Text('h1', {}, 'foo')
        h2 = new ContentEdit.Text('h2', {}, 'foo')

        expect(ContentTools.StylePalette.styles(p)).toEqual [test1, test2]
        expect(ContentTools.StylePalette.styles(h1)).toEqual [test2, test3]
        expect(ContentTools.StylePalette.styles(h2)).toEqual [test3]


# Styles

describe 'ContentTools.Style()', () ->

    it 'should create `ContentTools.Style` instance', () ->
        style = new ContentTools.Style('Test', 'test', ['p'])
        expect(style instanceof ContentTools.Style).toBe true


describe 'ContentTools.Style.applicableTo()', () ->

    it 'should return a list of tag names the style is applicable to', () ->
        tagNames = ['p', 'img', 'table']
        style = new ContentTools.Style('Test', 'test', tagNames)
        expect(style.applicableTo()).toBe tagNames


describe 'ContentTools.Style.cssClass()', () ->

    it 'should return the CSS class name for the style', () ->
        cssClassName = 'test'
        style = new ContentTools.Style('Test', cssClassName, 'p')
        expect(style.cssClass()).toBe cssClassName


describe 'ContentTools.Style.name()', () ->

    it 'should return the name of the style', () ->
        name = 'Test'
        style = new ContentTools.Style(name, 'test', 'p')
        expect(style.name()).toBe name