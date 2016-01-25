# ImageDialog

describe 'ContentTools.ImageDialog', () ->

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


    describe 'ContentTools.ImageDialog()', () ->

        it 'should return an instance of a ImageDialog', () ->

            dialog = new ContentTools.ImageDialog()
            expect(dialog instanceof ContentTools.ImageDialog).toBe true


    describe 'ContentTools.ImageDialog.cropRegion()', () ->

        it 'should return the crop region set by the user', () ->

            dialog = new ContentTools.ImageDialog()
            editor.attach(dialog)
            dialog.mount()

            # By default this should return the entire image [0, 0, 1, 1]
            expect(dialog.cropRegion()).toEqual([0, 0, 1, 1])

            # Populate the dialog with an image
            dialog._domView.style.width = '400px'
            dialog._domView.style.height = '400px'
            dialog.populate('test.png', [400, 400])

            # Add some crop marks for the dialog
            dialog.addCropMarks()
            dialog._cropMarks._domHandles[1].style.left = '200px'
            dialog._cropMarks._domHandles[1].style.top = '200px'

            # By default this should return the entire image [0, 0, 1, 1]
            expect(dialog.cropRegion()).toEqual([0, 0, 0.5, 0.5])

    #addCropMarks
    #clear
    #mount
    #populate
    #progress
    #removeCropMarks
    #save
    #state
    #unmount