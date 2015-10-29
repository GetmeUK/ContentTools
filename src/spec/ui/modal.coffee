# ModalUI

describe 'ContentTools.ModalUI', () ->

    div = null
    editor = null

    beforeEach ->
        # Create an editable region
        div = document.createElement('div')
        div.setAttribute('class', 'editable')
        document.body.appendChild(div)

        # Initialize the editor
        editor = ContentTools.EditorApp.get()
        editor.init('.editable')

    afterEach ->
        # Shutdown the editor
        editor.destroy()

        # Remove the editable region
        document.body.removeChild(div)


    describe 'ContentTools.ModalUI()', () ->

        it 'should return an instance of a ModalUI', () ->

            modal = new ContentTools.ModalUI(true, false)
            expect(modal instanceof ContentTools.ModalUI).toBe true

    describe 'ContentTools.ModalUI.mount()', () ->

        it 'should mount the component', () ->

            modal = new ContentTools.ModalUI(true, true)
            editor.attach(modal)
            modal.show()
            expect(modal.isMounted()).toBe true

        it 'should apply transparent flag', () ->

            # Check that the transparency and allowScrolling flags are set
            modal = new ContentTools.ModalUI(true, true)
            editor.attach(modal)
            modal.show()

            # Check transparency flag is set
            classes = modal.domElement().getAttribute('class').split(' ')
            expect(classes.indexOf('ct-modal--transparent') > -1).toBe true

        it 'should apply no-scrolling flag', () ->

            # Check that the transparency and allowScrolling flags are set
            modal = new ContentTools.ModalUI(true, false)
            editor.attach(modal)
            modal.show()

            # Check no scrolling flag is not set
            classes = (document.body.getAttribute('class') or '').split(' ')
            expect(classes.indexOf('ct--no-scroll') > -1).toBe true


    describe 'ContentTools.ModalUI.unmount()', () ->

        it 'should unmount the component', () ->

            modal = new ContentTools.ModalUI(true, true)
            editor.attach(modal)
            modal.show()
            modal.unmount()
            expect(modal.isMounted()).toBe false

        it 'should remove no-scrolling flag', () ->

            # Check that the transparency and allowScrolling flags are set
            modal = new ContentTools.ModalUI(true, false)
            editor.attach(modal)
            modal.show()
            modal.unmount()

            # Check no scrolling flag is not set
            classes = (document.body.getAttribute('class') or '').split(' ')
            expect(classes.indexOf('ct--no-scroll') > -1).toBe false


    # Events

    describe 'ContentTools.ModalUI > Events', () ->

        it 'should trigger a `click` event if clicked', () ->

            modal = new ContentTools.ModalUI(true, true)
            editor.attach(modal)
            modal.show()

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: () ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            modal.bind('click', foo.handleFoo)

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)
            modal.domElement().dispatchEvent(clickEvent)

            expect(foo.handleFoo).toHaveBeenCalled()
