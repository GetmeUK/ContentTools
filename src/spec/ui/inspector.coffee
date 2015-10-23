# IgnitionUI

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