# InspectorUI

describe 'ContentTools.InspectorUI', () ->

    div = null
    editor = null

    beforeEach ->
        # Create an editable region
        div = document.createElement('div')
        div.setAttribute('class', 'editable')
        div.setAttribute('id', 'foo')
        document.body.appendChild(div)

        div.innerHTML = '''
            <p>bar</p>
            <ul>
                <li>zee</li>
            </ul>
            '''

        # Initialize the editor
        editor = ContentTools.EditorApp.get()
        editor.init('.editable')

    afterEach ->
        # Shutdown the editor
        editor.destroy()

        # Remove the editable region
        document.body.removeChild(div)


    describe 'ContentTools.InspectorUI()', () ->

        it 'should return an instance of a InspectorUI', () ->

            inspector = new ContentTools.InspectorUI()
            expect(inspector instanceof ContentTools.InspectorUI).toBe true


    describe 'ContentTools.InspectorUI.mount()', () ->

        it 'should mount the component', () ->

            inspector = new ContentTools.InspectorUI()
            editor.attach(inspector)
            inspector.mount()
            expect(inspector.isMounted()).toBe true


    describe 'ContentTools.InspectorUI.unmount()', () ->

        it 'should unmount the component', () ->

            inspector = new ContentTools.InspectorUI()
            editor.attach(inspector)
            inspector.mount()
            inspector.unmount()
            expect(inspector.isMounted()).toBe false


    describe 'ContentTools.InspectorUI.updateTags()', () ->

        it 'should update the tags displayed to reflect the path to the current
                element', () ->

            # Start the editor so the document is editable
            editor.start()

            inspector = editor._inspector
            region = editor.regions()['foo']
            elements = region.children

            # NOTE: Changing the focus of an element triggers the updateTags
            # method.

            # Select the first editable element (a <p> tag) and check the tag
            # path.
            elements[0].focus()
            expect(inspector._tagUIs.length).toEqual 1
            expect(inspector._tagUIs[0].element.tagName()).toEqual 'p'

            # Select the second editable element (a <li> tag) and check the tag
            # path.
            elements[1].children[0].children[0].focus()
            expect(inspector._tagUIs.length).toEqual 2
            expect(inspector._tagUIs[0].element.tagName()).toEqual 'ul'
            expect(inspector._tagUIs[1].element.tagName()).toEqual 'li'

            editor.stop()

# TagUI

describe 'ContentTools.TagUI', () ->

    div = null
    editor = null

    beforeEach ->
        # Create an editable region
        div = document.createElement('div')
        div.setAttribute('class', 'editable')
        div.setAttribute('id', 'foo')
        document.body.appendChild(div)

        div.innerHTML = '''
            <p>bar</p>
            <ul>
                <li>zee</li>
            </ul>
            '''

        # Initialize the editor
        editor = ContentTools.EditorApp.get()
        editor.init('.editable')

    afterEach ->
        # Shutdown the editor
        editor.destroy()

        # Remove the editable region
        document.body.removeChild(div)


    describe 'ContentTools.TagUI()', () ->

        it 'should return an instance of a TagUI', () ->

            tag = new ContentTools.TagUI()
            expect(tag instanceof ContentTools.TagUI).toBe true


    describe 'ContentTools.TagUI.mount()', () ->

        it 'should mount the component', () ->

            # Start the editor so the document is editable
            editor.start()
            inspector = editor._inspector
            region = editor.regions()['foo']
            elements = region.children

            # Manually mout the element on to the inspector bar
            tag = new ContentTools.TagUI(elements[0])
            tag.mount(inspector._domTags)
            expect(tag.isMounted()).toBe true


    describe 'ContentTools.TagUI > Interaction', () ->

        it 'should allow the properties dialog to be used', () ->

            # Start the editor so the document is editable
            editor.start()

            inspector = editor._inspector
            region = editor.regions()['foo']
            element = region.children[0]
            element.focus()
            tag = inspector._tagUIs[0]

            # Click the tag and check if a properties dialog is opened
            mouseDownEvent = document.createEvent('CustomEvent')
            mouseDownEvent.initCustomEvent('mousedown', false, false, null)
            tag.domElement().dispatchEvent(mouseDownEvent)

            # Check a properties dialog was opened
            app = ContentTools.EditorApp.get()
            dialog = app.children()[app.children().length - 1]
            expect(dialog instanceof ContentTools.PropertiesDialog).toBe true

            # Trigger a save event against the dialog and test that the changes
            # are applied correctly.
            dialog.dispatchEvent(
                dialog.createEvent('save', {
                    changedAttributes: {title: 'bar'},
                    changedStyles: {'zee': true},
                    innerHTML: 'foo'
                    })
                )
            expect(element.attr('title')).toBe 'bar'
            expect(element.hasCSSClass('zee')).toBe true
            expect(element.content.html()).toBe 'foo'

            # Test the changes can be reverted
            tag.domElement().dispatchEvent(mouseDownEvent)
            dialog = app.children()[app.children().length - 1]

            dialog.dispatchEvent(
                dialog.createEvent('save', {
                    changedAttributes: {title: null},
                    changedStyles: {'zee': false},
                    innerHTML: 'bar'
                    })
                )
            expect(element.attr('title')).toBe undefined
            expect(element.hasCSSClass('zee')).toBe false
            expect(element.content.html()).toBe 'bar'