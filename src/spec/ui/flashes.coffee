# FlashUI

describe 'ContentTools.FlashUI', () ->

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


    describe 'ContentTools.FlashUI()', () ->

        it 'should return an instance of a FlashUI', () ->

            flash = new ContentTools.FlashUI('ok')
            expect(flash instanceof ContentTools.FlashUI).toBe true

        it 'should mount the component', () ->

            flash = new ContentTools.FlashUI('ok')
            expect(flash.isMounted()).toBe true

        it 'should unmount the component after X seconds', (done) ->

            flash = new ContentTools.FlashUI('ok')

            checkUnmounted = () ->
                expect(flash.isMounted()).toBe false
                done()

            setTimeout(checkUnmounted, 500)


    describe 'ContentTools.FlashUI.mount()', () ->

        it 'should mount the component and apply the specified modifier', () ->

            # `mount` is called with the specified modifier in the constructor
            flash = new ContentTools.FlashUI('ok')
            expect(flash.isMounted()).toBe true

            # Get a list of classes against the class and check the specified
            # modifier is one of them.
            classes = flash.domElement().getAttribute('class').split(' ')
            expect(classes.indexOf('ct-flash--ok') > -1).toBe true