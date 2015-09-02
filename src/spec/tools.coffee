# ToolShelf

describe 'ContentTools.ToolShelf.stow()', () ->

    it 'should store a `ContentTools.Tool` instance against a name', () ->
        tool = ContentTools.Tool
        ContentTools.ToolShelf.stow(tool, 'tool')
        expect(ContentTools.ToolShelf.fetch('tool')).toEqual tool


describe 'ContentTools.ToolShelf.fetch()', () ->

    it 'should return a `ContentTools.Tool` instance by name', () ->
        tool = ContentTools.Tools.Bold
        expect(ContentTools.ToolShelf.fetch('bold')).toEqual tool


# Tools

# Bold

describe 'ContentTools.Tools.Bold.apply()', () ->

    it 'should wrap the selected content in a bold tag if the bold tag is
            not applied to all of the selection', () ->

        region = new ContentEdit.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 4)
        tool = ContentTools.Tools.Bold

        # Bold applied to none of the selection
        element = new ContentEdit.Text('p', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<b>test</b>'

        # Bold applied to only part of the selection
        element = new ContentEdit.Text('p', {}, '<b>te</b>st')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<b>test</b>'

    it 'should remove the bold tag from the selected content if the bold tag is
            applied to all of the selection', () ->

        element = new ContentEdit.Text('p', {}, '<b>test</b>')
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(element)

        selection = new ContentSelect.Range(0, 4)
        tool = ContentTools.Tools.Bold

        # Check for selected content within bold tag
        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe 'test'


describe 'ContentTools.Tools.Bold.canApply()', () ->

    it 'should return true if the element supports content and the selection is
            not collapsed', () ->

        element = new ContentEdit.Text('p', {}, 'test')
        tool = ContentTools.Tools.Bold

        # Check for content element with expanded selection
        selection = new ContentSelect.Range(0, 2)
        expect(tool.canApply(element, selection)).toBe true

        # Check for content element with collapsed selection
        selection = new ContentSelect.Range(0, 0)
        expect(tool.canApply(element, selection)).toBe false

        # Check for non-content element
        element = new ContentEdit.Image()
        expect(tool.canApply(element, selection)).toBe false


describe 'ContentTools.Tools.Bold.isApplied()', () ->

    it 'should return true if the selected content is wrapped in a bold
            tag', () ->

        element = new ContentEdit.Text('p', {}, '<b>te</b>st')
        tool = ContentTools.Tools.Bold

        # Check true if entire selection is bold
        selection = new ContentSelect.Range(0, 2)
        expect(tool.isApplied(element, selection)).toBe true

        # Check false if only part of the selection is bold
        selection = new ContentSelect.Range(0, 4)
        expect(tool.isApplied(element, selection)).toBe false

        # Check false if none of the selection is bold
        selection = new ContentSelect.Range(2, 4)
        expect(tool.isApplied(element, selection)).toBe false


# Italic

describe 'ContentTools.Tools.Italic.apply()', () ->

    it 'should wrap the selected content in a italic tag if the italic tag is
            not applied to all of the selection', () ->

        region = new ContentEdit.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 4)
        tool = ContentTools.Tools.Italic

        # Italic applied to none of the selection
        element = new ContentEdit.Text('p', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<i>test</i>'

        # Italic applied to only part of the selection
        element = new ContentEdit.Text('p', {}, '<i>te</i>st')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<i>test</i>'

    it 'should remove the italic tag from the selected content if the italic tag
            is applied to all of the selection', () ->

        element = new ContentEdit.Text('p', {}, '<i>test</i>')
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(element)

        selection = new ContentSelect.Range(0, 4)
        tool = ContentTools.Tools.Italic

        # Check for selected content within italic tag
        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe 'test'


describe 'ContentTools.Tools.Italic.canApply()', () ->

    it 'should return true if the element supports content and the selection is
            not collapsed', () ->

        element = new ContentEdit.Text('p', {}, 'test')
        tool = ContentTools.Tools.Italic

        # Check for content element with expanded selection
        selection = new ContentSelect.Range(0, 2)
        expect(tool.canApply(element, selection)).toBe true

        # Check for content element with collapsed selection
        selection = new ContentSelect.Range(0, 0)
        expect(tool.canApply(element, selection)).toBe false

        # Check for non-content element
        element = new ContentEdit.Image()
        expect(tool.canApply(element, selection)).toBe false


describe 'ContentTools.Tools.Italic.isApplied()', () ->

    it 'should return true if the selected content is wrapped in a italic
            tag', () ->

        element = new ContentEdit.Text('p', {}, '<i>te</i>st')
        tool = ContentTools.Tools.Italic

        # Check true if entire selection is italic
        selection = new ContentSelect.Range(0, 2)
        expect(tool.isApplied(element, selection)).toBe true

        # Check false if only part of the selection is italic
        selection = new ContentSelect.Range(0, 4)
        expect(tool.isApplied(element, selection)).toBe false

        # Check false if none of the selection is italic
        selection = new ContentSelect.Range(2, 4)
        expect(tool.isApplied(element, selection)).toBe false


# Link

# TODO: Establish how to test more complex interactions that required an
# editable document and application. Possibly via selenium or through automating
# the creation of an editable enviroment to test against (would still be limited
# with jasmine).
#
# Anthony Blackshaw <ant@getme.co.uk> - 2015-05-25 11:44

describe 'ContentTools.Tools.Link.canApply()', () ->

    it 'should return true if the element supports content and the selection is
            not collapsed or if the element is an image', () ->

        element = new ContentEdit.Text('p', {}, 'test')
        tool = ContentTools.Tools.Link

        # Check for content element with expanded selection
        selection = new ContentSelect.Range(0, 2)
        expect(tool.canApply(element, selection)).toBe true

        # Check for content element with collapsed selection
        selection = new ContentSelect.Range(0, 0)
        expect(tool.canApply(element, selection)).toBe false

        # Check for image element
        element = new ContentEdit.Image()
        expect(tool.canApply(element, selection)).toBe true

describe 'ContentTools.Tools.Link.getHref()', () ->

    it 'should return the href for the first anchor tag found in a selection or
            if the element is an image then for the anchor tag associated with
            image', () ->

        element = new ContentEdit.Text(
            'p',
            {},
            '<a href="#test">te</a><a href="#test2">st</a>'
            )
        tool = ContentTools.Tools.Link

        selection = new ContentSelect.Range(0, 2)
        expect(tool.getHref(element, selection)).toBe '#test'

        selection = new ContentSelect.Range(2, 4)
        expect(tool.getHref(element, selection)).toBe '#test2'

        # Check that if multiple links are spanned the href attribute of the
        # first one is returned.
        selection = new ContentSelect.Range(1, 4)
        expect(tool.getHref(element, selection)).toBe '#test'


describe 'ContentTools.Tools.Link.isApplied()', () ->

    it 'should return true if the selected content is wrapped in an anchor
            tag or is an image with an associated anchor tag', () ->

        element = new ContentEdit.Text('p', {}, '<a href="#test">te</a>st')
        tool = ContentTools.Tools.Link

        # Check true if entire selection is a link
        selection = new ContentSelect.Range(0, 2)
        expect(tool.isApplied(element, selection)).toBe true

        # Check false if only part of the selection is a link
        selection = new ContentSelect.Range(0, 4)
        expect(tool.isApplied(element, selection)).toBe false

        # Check false if none of the selection is a link
        selection = new ContentSelect.Range(2, 4)
        expect(tool.isApplied(element, selection)).toBe false


#