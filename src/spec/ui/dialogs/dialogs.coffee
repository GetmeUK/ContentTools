# AnchoredDialogUI

describe 'ContentTools.AnchoredDialogUI', () ->

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


    describe 'ContentTools.AnchoredDialogUI()', () ->

        it 'should return an instance of a AnchoredDialogUI', () ->

            dialog = new ContentTools.AnchoredDialogUI()
            expect(dialog instanceof ContentTools.AnchoredDialogUI).toBe true


    describe 'ContentTools.AnchoredDialogUI.mount()', () ->

        it 'should mount the dialog', () ->

            dialog = new ContentTools.AnchoredDialogUI()
            editor.attach(dialog)
            dialog.mount()
            expect(dialog.isMounted()).toBe true


    describe 'ContentTools.AnchoredDialogUI.position()', () ->

        it 'should set/get the dialogs position', () ->

            dialog = new ContentTools.AnchoredDialogUI()
            editor.attach(dialog)
            dialog.mount()

            # Initially the should be dialogs position should be [0, 0]
            expect(dialog.position()).toEqual [0 ,0]

            # Set a new position and check that it's been applied
            dialog.position([7, 7])
            style = dialog.domElement().style

            expect(dialog.position()).toEqual [7 ,7]
            expect(style.top).toBe '7px'
            expect(style.left).toBe '7px'


# DialogUI