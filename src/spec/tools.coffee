# ToolShelf

# Initialize the editor
editor = ContentTools.EditorApp.get()
editor.init()
editor.start()
CEFactory = editor.CEFactory
toolShelf = editor._toolbox._toolShelf

describe 'ContentTools.ToolShelf.stow()', () ->

    it 'should store a `ContentTools.Tool` instance against a name', () ->
        tool = ContentTools.Tool
        ContentTools.ToolShelf.stow(tool, 'tool')
        expect(ContentTools.ToolShelf._tools['tool']).toEqual tool


describe 'ContentTools.ToolShelf.fetch()', () ->

    it 'should return a `ContentTools.Tool` instance by name', () ->
        tool = ContentTools.Tools.Bold
        expect(ContentTools.ToolShelf._tools['bold']).toEqual tool


# Tools

# TODO
# link # Incomplete
# align-left
# align-center
# align-right
# unordered-list
# ordered-list
# table
# indent
# unindent
# line-break
# image
# video
# preformatted
# undo
# redo
# remove

# Bold

describe 'ContentTools.Tools.Bold.apply()', () ->

    it 'should wrap the selected content in a bold tag if the bold tag is
            not applied to all of the selection', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 4)
        tool = toolShelf.get("bold")

        # Bold applied to none of the selection
        element = new CEFactory.Text('p', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<b>test</b>'

        # Bold applied to only part of the selection
        element = new CEFactory.Text('p', {}, '<b>te</b>st')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<b>test</b>'

    it 'should remove the bold tag from the selected content if the bold tag is
            applied to all of the selection', () ->

        element = new CEFactory.Text('p', {}, '<b>test</b>')
        region = new CEFactory.Region(document.createElement('div'))
        region.attach(element)

        selection = new ContentSelect.Range(0, 4)
        tool = toolShelf.get("bold")

        # Check for selected content within bold tag
        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe 'test'


describe 'ContentTools.Tools.Bold.canApply()', () ->

    it 'should return true if the element supports content and the selection is
            not collapsed', () ->

        element = new CEFactory.Text('p', {}, 'test')
        tool = toolShelf.get("bold")

        # Check true for content element with expanded selection
        selection = new ContentSelect.Range(0, 2)
        expect(tool.canApply(element, selection)).toBe true

        # Check false for content element with collapsed selection
        selection = new ContentSelect.Range(0, 0)
        expect(tool.canApply(element, selection)).toBe false

        # Check false for non-content element
        element = new CEFactory.Image()
        expect(tool.canApply(element, selection)).toBe false


describe 'ContentTools.Tools.Bold.isApplied()', () ->

    it 'should return true if the selected content is wrapped in a bold
            tag', () ->

        element = new CEFactory.Text('p', {}, '<b>te</b>st')
        tool = toolShelf.get("bold")

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

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 4)
        tool = toolShelf.get("italic")

        # Italic applied to none of the selection
        element = new CEFactory.Text('p', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<i>test</i>'

        # Italic applied to only part of the selection
        element = new CEFactory.Text('p', {}, '<i>te</i>st')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe '<i>test</i>'

    it 'should remove the italic tag from the selected content if the italic tag
            is applied to all of the selection', () ->

        element = new CEFactory.Text('p', {}, '<i>test</i>')
        region = new CEFactory.Region(document.createElement('div'))
        region.attach(element)

        selection = new ContentSelect.Range(0, 4)
        tool = toolShelf.get("italic")

        # Check for selected content within italic tag
        tool.apply(element, selection, () =>)
        expect(element.content.html()).toBe 'test'


describe 'ContentTools.Tools.Italic.canApply()', () ->

    it 'should return true if the element supports content and the selection is
            not collapsed', () ->

        element = new CEFactory.Text('p', {}, 'test')
        tool = toolShelf.get("italic")

        # Check true for content element with expanded selection
        selection = new ContentSelect.Range(0, 2)
        expect(tool.canApply(element, selection)).toBe true

        # Check false for content element with collapsed selection
        selection = new ContentSelect.Range(0, 0)
        expect(tool.canApply(element, selection)).toBe false

        # Check false for non-content element
        element = new CEFactory.Image()
        expect(tool.canApply(element, selection)).toBe false


describe 'ContentTools.Tools.Italic.isApplied()', () ->

    it 'should return true if the selected content is wrapped in a italic
            tag', () ->

        element = new CEFactory.Text('p', {}, '<i>te</i>st')
        tool = toolShelf.get("italic")

        # Check true if entire selection is italic
        selection = new ContentSelect.Range(0, 2)
        expect(tool.isApplied(element, selection)).toBe true

        # Check false if only part of the selection is italic
        selection = new ContentSelect.Range(0, 4)
        expect(tool.isApplied(element, selection)).toBe false

        # Check false if none of the selection is italic
        selection = new ContentSelect.Range(2, 4)
        expect(tool.isApplied(element, selection)).toBe false


# Link (TODO: add tests for apply)

describe 'ContentTools.Tools.Link.canApply()', () ->

    it 'should return true if the element supports content and the selection is
            not collapsed or if the element is an image', () ->

        element = new CEFactory.Text('p', {}, 'test')
        tool = toolShelf.get("link")

        # Check for content element with expanded selection
        selection = new ContentSelect.Range(0, 2)
        expect(tool.canApply(element, selection)).toBe true

        # Check for content element with collapsed selection
        selection = new ContentSelect.Range(0, 0)
        expect(tool.canApply(element, selection)).toBe false

        # Check for image element
        element = new CEFactory.Image()
        expect(tool.canApply(element, selection)).toBe true


describe 'ContentTools.Tools.Link.getAttr()', () ->

    it 'should return an attribute by name for the first anchor tag found in a
            selection or if the element is an image then for the anchor tag
            associated with image', () ->

        element = new CEFactory.Text(
            'p',
            {},
            '<a href="#test" target="_blank">te</a><a href="#test2">st</a>'
            )
        tool = toolShelf.get("link")

        # Check we can get the href attribute
        selection = new ContentSelect.Range(0, 2)
        expect(tool.getAttr('href', element, selection)).toBe '#test'

        selection = new ContentSelect.Range(2, 4)
        expect(tool.getAttr('href', element, selection)).toBe '#test2'

        # Check we can get the target attribute
        selection = new ContentSelect.Range(0, 2)
        expect(tool.getAttr('target', element, selection)).toBe '_blank'

        selection = new ContentSelect.Range(2, 4)
        expect(tool.getAttr('target', element, selection)).toBe undefined

        # Check that if multiple links are spanned the href attribute of the
        # first one is returned.
        selection = new ContentSelect.Range(1, 4)
        expect(tool.getAttr('href', element, selection)).toBe '#test'

describe 'ContentTools.Tools.Link.isApplied()', () ->

    it 'should return true if the selected content is wrapped in an anchor
            tag or is an image with an associated anchor tag', () ->

        element = new CEFactory.Text('p', {}, '<a href="#test">te</a>st')
        tool = toolShelf.get("link")

        # Check true if entire selection is a link
        selection = new ContentSelect.Range(0, 2)
        expect(tool.isApplied(element, selection)).toBe true

        # Check false if only part of the selection is a link
        selection = new ContentSelect.Range(0, 4)
        expect(tool.isApplied(element, selection)).toBe false

        # Check false if none of the selection is a link
        selection = new ContentSelect.Range(2, 4)
        expect(tool.isApplied(element, selection)).toBe false


# Align left

describe 'ContentTools.Tools.AlignLeft.apply()', () ->

    it 'should apply the `align-left` class to an element or its parent if it
            does not directly support the class attribute itself', () ->


describe 'ContentTools.Tools.AlignLeft.canApply()', () ->

    it 'should return true if the element supports content', () ->


describe 'ContentTools.Tools.AlignLeft.isApplied()', () ->

    it 'should return true if the element (or relevant parent) has the
            `align-left` class applied', () ->


# Heading

describe 'ContentTools.Tools.Heading.apply()', () ->

    it 'should change the tag name of a top level element supporting content to
            h1', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("heading")

        # Apply heading tool
        element = new CEFactory.Text('p', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.tagName()).toBe 'h1'


describe 'ContentTools.Tools.Heading.canApply()', () ->

    it 'should return true if the element is a top-level element that supports
            content', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("heading")

        element = new CEFactory.Text('p', {}, 'test')
        region.attach(element)

        # Check true for content top-level content element
        expect(tool.canApply(element, selection)).toBe true

        # Check false for image element
        image = new CEFactory.Image()
        region.attach(image)
        expect(tool.canApply(image, selection)).toBe false

        # Check for content element that is not top level
        list = new CEFactory.List('ul')
        listItem = new CEFactory.ListItem()
        listItemText= new CEFactory.ListItemText('test')
        listItem.attach(listItemText)
        list.attach(listItem)
        region.attach(list)
        expect(tool.canApply(list, selection)).toBe false


describe 'ContentTools.Tools.Heading.isApplied()', () ->

    it 'should return true if the selected element is a h1', () ->

        tool = toolShelf.get("heading")

        # H1 selected
        element = new CEFactory.Text('h1', {}, 'test')
        selection = new ContentSelect.Range(0, 0)
        expect(tool.isApplied(element, selection)).toBe true

        # Not a H1 selected
        element = new CEFactory.Text('p', {}, 'test')
        expect(tool.isApplied(element, selection)).toBe false


# Sub-heading

describe 'ContentTools.Tools.Subheading.apply()', () ->

    it 'should change the tag name of a top level element supporting content to
            h2', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("subheading")

        # Apply heading tool
        element = new CEFactory.Text('p', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.tagName()).toBe 'h2'


describe 'ContentTools.Tools.Subheading.canApply()', () ->

    it 'should return true if the element is a top-level element that supports
            content', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("subheading")

        element = new CEFactory.Text('p', {}, 'test')
        region.attach(element)

        # Check true for content top-level content element
        expect(tool.canApply(element, selection)).toBe true

        # Check false for image element
        image = new CEFactory.Image()
        region.attach(image)
        expect(tool.canApply(image, selection)).toBe false

        # Check for content element that is not top level
        list = new CEFactory.List('ul')
        listItem = new CEFactory.ListItem()
        listItemText= new CEFactory.ListItemText('test')
        listItem.attach(listItemText)
        list.attach(listItem)
        region.attach(list)
        expect(tool.canApply(list, selection)).toBe false


describe 'ContentTools.Tools.Subheading.isApplied()', () ->

    it 'should return true if the selected element is a h2', () ->

        tool = toolShelf.get("subheading")

        # H2 selected
        element = new CEFactory.Text('h2', {}, 'test')
        selection = new ContentSelect.Range(0, 0)
        expect(tool.isApplied(element, selection)).toBe true

        # Not a H1 selected
        element = new CEFactory.Text('p', {}, 'test')
        expect(tool.isApplied(element, selection)).toBe false


# Paragraph

describe 'ContentTools.Tools.Paragraph.apply()', () ->

    it 'should change text/pre-text elements to paragraphs', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("paragraph")

        # Apply paragraph tool to text element
        element = new CEFactory.Text('h1', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.tagName()).toBe 'p'

        # Apply paragraph tool to pre-text element
        element = new CEFactory.Text('pre', {}, 'test')
        region.attach(element)

        tool.apply(element, selection, () =>)
        expect(element.tagName()).toBe 'p'

    it 'should add a paragraph after elements non-text/pre-text elements', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("paragraph")

        # Apply paragraph tool to non-text element
        image = new CEFactory.Image()
        region.attach(image)

        tool.apply(image, selection, () =>)
        expect(region.children.length).toBe 2
        expect(region.children[1].tagName()).toBe 'p'


describe 'ContentTools.Tools.Paragraph.canApply()', () ->

    it 'should return true if the element is not fixed', () ->

        region = new CEFactory.Region(document.createElement('div'))
        selection = new ContentSelect.Range(0, 0)
        tool = toolShelf.get("paragraph")

        # Text elements
        heading = new CEFactory.Text('h1', {}, 'test')
        region.attach(heading)
        expect(tool.canApply(heading, selection)).toBe true

        # Non-text elements
        image = new CEFactory.Image()
        region.attach(image)
        expect(tool.canApply(image, selection)).toBe true

        # Fixed elements
        fixture_anchor = document.createElement('div')
        fixed_heading = document.createElement('h1')
        fixed_heading.innerHTML = 'test'
        fixture_anchor.appendChild(fixed_heading)
        fixture = new CEFactory.Fixture(fixed_heading)
        expect(tool.canApply(fixture.children[0], selection)).toBe false


describe 'ContentTools.Tools.Paragraph.apply()', () ->

    it 'should return true if the selected element is a paragraph', () ->

        tool = toolShelf.get("paragraph")

        # P selected
        element = new CEFactory.Text('p', {}, 'test')
        selection = new ContentSelect.Range(0, 0)
        expect(tool.isApplied(element, selection)).toBe true

        # Not a P selected
        element = new CEFactory.Text('h1', {}, 'test')
        expect(tool.isApplied(element, selection)).toBe false
