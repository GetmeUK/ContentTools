# ToolboxUI

describe 'ContentTools.ToolboxUI', () ->

    div = null
    editor = null

    beforeEach ->
        # Create an editable region
        div = document.createElement('div')
        div.setAttribute('class', 'editable')
        div.setAttribute('id', 'foo')
        div.innerHTML = '<p>bar</p><img scr="test.png">'
        document.body.appendChild(div)

        # Initialize the editor
        editor = ContentTools.EditorApp.get()
        editor.init('.editable')
        editor.start()

    afterEach ->
        # Shutdown the editor
        editor.stop()
        editor.destroy()

        # Remove the editable region
        document.body.removeChild(div)


    describe 'ContentTools.ToolboxUI()', () ->

        it 'should return an instance of a ToolboxUI', () ->

            toolbox = new ContentTools.ToolboxUI([])
            expect(toolbox instanceof ContentTools.ToolboxUI).toBe true


    describe 'ContentTools.ToolboxUI.isDragging()', () ->

        it 'should return true if the ToolboxUI is currently being
                dragged', () ->

            toolbox = editor._toolbox

            # By default the editor is not being dragged
            expect(toolbox.isDragging()).toBe false

            # Trigger a drag event
            mouseDownEvent = document.createEvent('CustomEvent')
            mouseDownEvent.initCustomEvent('mousedown', false, false, null)
            toolbox._domGrip.dispatchEvent(mouseDownEvent)

            expect(toolbox.isDragging()).toBe true

            # Stop dragging
            mouseUpEvent = document.createEvent('CustomEvent')
            mouseUpEvent.initCustomEvent('mouseup', false, false, null)
            document.dispatchEvent(mouseUpEvent)

            expect(toolbox.isDragging()).toBe false


    describe 'ContentTools.ToolboxUI.hide()', () ->

        it 'should remove all event bindings before the toolbox is
                hidden', () ->

            toolbox = editor._toolbox
            spyOn(toolbox, '_removeDOMEventListeners')
            toolbox.hide()

            expect(toolbox._removeDOMEventListeners).toHaveBeenCalled()


    describe 'ContentTools.ToolboxUI.tools()', () ->

        it 'should return the list of tools that populate the toolbox', () ->

            # By default we expect the list of tools in the toolbox to match the
            # those in the `DEFAULT_TOOLS` setting.
            toolbox = editor._toolbox
            expect(toolbox.tools()).toEqual ContentTools.DEFAULT_TOOLS

        it 'should set the list of tools that populate the toolbox', () ->

            # Set a custom tool layout
            toolbox = editor._toolbox
            customTools = [['bold', 'italic', 'link']]
            toolbox.tools(customTools)

            # Check the toolbox reflects the change
            expect(toolbox.tools()).toEqual customTools


    describe 'ContentTools.ToolboxUI.mount()', () ->

        it 'should mount the component', () ->

            # Start the editor so the document is editable
            toolbox = new ContentTools.ToolboxUI([])
            editor.attach(toolbox)
            toolbox.mount()

            expect(toolbox.isMounted()).toBe true

        it 'should restore the position of the component to any previously
                saved state', () ->

            # Manually set a restore point
            window.localStorage.setItem('ct-toolbox-position', '7,7')
            toolbox = new ContentTools.ToolboxUI([])
            editor.attach(toolbox)
            toolbox.mount()

            # Check the restore position was respected
            expect(toolbox.domElement().style.left).toBe '7px'
            expect(toolbox.domElement().style.top).toBe '7px'

        it 'should always be contained within the viewport', () ->

            # Manually set a restore point outside of the viewport
            window.localStorage.setItem('ct-toolbox-position', '-7,-7')
            toolbox = new ContentTools.ToolboxUI([])
            editor.attach(toolbox)
            toolbox.mount()

            # Check the restore position was respected
            expect(toolbox.domElement().style.left).toBe ''
            expect(toolbox.domElement().style.top).toBe ''


    describe 'ContentTools.ToolboxUI.updateTools()', () ->

        it 'should refresh all tool UIs in the toolbox', (done) ->

            # The `updateTools` method is called whenever the focused element
            # and/or content selection is changed.
            toolbox = editor._toolbox
            region = editor.regions()['foo']
            element = region.children[0]

            # With no elements select the heading tool should be disabled
            expect(toolbox._toolUIs['heading'].disabled()).toBe true

            # Test that if we select an element the tools update
            element.focus()

            checkUpdated = () ->
                expect(toolbox._toolUIs['heading'].disabled()).toBe false
                done()

            setTimeout(checkUpdated, 500)


    # Interactions

    describe 'ContentTools.ToolboxUI > Keyboard short-cuts', () ->

        it 'should allow a non-content element to be removed with the delete key
                short-cut', () ->

            # Select an element and delete it with the short-cut
            toolbox = editor._toolbox
            region = editor.regions()['foo']
            element = region.children[1]
            element.focus()

            # Trigger the remove short-cut event
            keyDownEvent = document.createEvent('CustomEvent')
            keyDownEvent.initCustomEvent('keydown', false, false, null)
            keyDownEvent.keyCode = 46
            window.dispatchEvent(keyDownEvent)

            expect(region.children.length).toBe 1

        it 'should allow a undo to be triggered with Ctrl-z key
                short-cut', () ->

            # Select an element and delete it with the short-cut
            toolbox = editor._toolbox
            region = editor.regions()['foo']
            element = region.children[1]

            # Spy on the `canApply` class method called if the short-cut is used
            spyOn(ContentTools.Tools.Undo, 'canApply')

            # Trigger the undo short-cut event
            keyDownEvent = document.createEvent('CustomEvent')
            keyDownEvent.initCustomEvent('keydown', false, false, null)
            keyDownEvent.keyCode = 90
            keyDownEvent.ctrlKey = true
            window.dispatchEvent(keyDownEvent)

            # Check the undo short-cut was called
            expect(ContentTools.Tools.Undo.canApply).toHaveBeenCalled()

        it 'should allow a redo to be triggered with Ctrl-Shift-z key
                short-cut', () ->

            # Select an element and delete it with the short-cut
            toolbox = editor._toolbox
            region = editor.regions()['foo']
            element = region.children[1]
            element.focus()

            # Spy on the `canApply` class method called if the short-cut is used
            spyOn(ContentTools.Tools.Redo, 'canApply')

            # Trigger the redo short-cut event
            keyDownEvent = document.createEvent('CustomEvent')
            keyDownEvent.initCustomEvent('keydown', false, false, null)
            keyDownEvent.keyCode = 90
            keyDownEvent.ctrlKey = true
            keyDownEvent.shiftKey = true
            window.dispatchEvent(keyDownEvent)

            # Check the redo short-cut was called
            expect(ContentTools.Tools.Redo.canApply).toHaveBeenCalled()


# ToolsUI

describe 'ContentTools.ToolboxUI', () ->

    div = null
    editor = null

    beforeEach ->
        # Create an editable region
        div = document.createElement('div')
        div.setAttribute('class', 'editable')
        div.setAttribute('id', 'foo')
        div.innerHTML = '<p>bar</p><img scr="test.png">'
        document.body.appendChild(div)

        # Initialize the editor
        editor = ContentTools.EditorApp.get()
        editor.init('.editable')

    afterEach ->
        # Shutdown the editor
        editor.destroy()

        # Remove the editable region
        document.body.removeChild(div)


    describe 'ContentTools.ToolUI()', () ->

        it 'should return an instance of a ToolUI', () ->

            tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('bold'))
            expect(tool instanceof ContentTools.ToolUI).toBe true


    describe 'ContentTools.ToolUI.disabled()', () ->

        it 'should set/get the disabled state for the tool', () ->

            tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('bold'))

            # Check that the default ignition disabled state to be true
            expect(tool.disabled()).toBe false

            # Check we can change it
            tool.disabled(true)
            expect(tool.disabled()).toBe true


    describe 'ContentTools.ToolUI.apply()', () ->

        it 'should apply the tool associated with the component', () ->

            tool = new ContentTools.ToolUI(
                ContentTools.ToolShelf.fetch('heading'))
            region = new ContentEdit.Region(
                document.querySelectorAll('.editable')[0])
            element = region.children[0]

            # Apply the tool to a paragraph and check that it successfully
            # converts the paragraph to a heading.
            tool.apply(element)

            expect(element.tagName()).toBe 'h1'


    describe 'ContentTools.Tool.mount()', () ->

        it 'should mount the component', () ->

            # Start the editor so the document is editable
            tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('bold'))
            editor.attach(tool)
            tool.mount(editor.domElement())

            expect(tool.isMounted()).toBe true


    describe 'ContentTools.Tool.update()', () ->

        it 'should update the state of the tool based on the currently focused
                element and content selection', () ->

            tool = new ContentTools.ToolUI(
                ContentTools.ToolShelf.fetch('heading'))
            region = new ContentEdit.Region(
                document.querySelectorAll('.editable')[0])
            element = region.children[0]

            # Check the tool is disabled after an update if no element is
            # selected (e.g it's not applicable to the current selection).
            tool.update()
            expect(tool.disabled()).toBe true

            # Check the tool is enabled after an update if an element is
            # provided.
            tool.update(element)
            expect(tool.disabled()).toBe false