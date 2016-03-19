class ImageUploader
    # A dummy image uploader to allow the image dialog to be tested in the
    # sandbox environment.

    @imagePath: 'image.png'
    @imageSize: [600, 174]

    constructor: (dialog) ->
        # Initialize the dialog to support image uploads

        @_dialog = dialog

        # Listen to key events from the dialog and assign handlers to each
        @_dialog.addEventListener 'cancel', () =>
            @_onCancel()

        @_dialog.addEventListener 'imageUploader.cancelupload', () =>
            @_onCancelUpload()

        @_dialog.addEventListener 'imageUploader.clear', () =>
            @_onClear()

        @_dialog.addEventListener 'imageUploader.fileready', (ev) =>
            @_onFileReady(ev.files)

        @_dialog.addEventListener 'imageUploader.mount', () =>
            @_onMount()

        @_dialog.addEventListener 'imageUploader.rotateccw', () =>
            @_onRotateCCW()

        @_dialog.addEventListener 'imageUploader.rotatecw', () =>
            @_onRotateCW()

        @_dialog.addEventListener 'imageUploader.save', () =>
            @_onSave()

        @_dialog.addEventListener 'imageUploader.unmount', () =>
            @_onUnmount()

    # Event handlers

    _onCancel: () ->
        # Handle the user cancelling the dialog

    _onCancelUpload: () ->
        # Handle an upload being cancelled

        # Stop the upload
        clearTimeout(@_uploadingTimeout)

        # Set the dialog to empty
        @_dialog.state('empty')

    _onClear: () ->
        # Handle the current image being cleared
        @_dialog.clear()

    _onFileReady: (file) ->
        # Handle a file being selected by the user

        # Set the dialog state to uploading
        @_dialog.progress(0)
        @_dialog.state('uploading')

        # Simulate uploading the specified file
        upload = () =>
            progress = @_dialog.progress()
            progress += 1

            if progress <= 100
                @_dialog.progress(progress)
                @_uploadingTimeout = setTimeout(upload, 25)
            else
                @_dialog.populate(
                    ImageUploader.imagePath,
                    ImageUploader.imageSize
                    )

        @_uploadingTimeout = setTimeout(upload, 25)

    _onMount: () ->
        # Handle the dialog being mounted on the UI

    _onRotateCCW: () ->
        # Handle a request by the user to rotate the image counter-clockwise

        # Simulate rotating the image
        @_dialog.busy(true)
        clearBusy = () =>
            @_dialog.busy(false)
        setTimeout(clearBusy, 1500)

    _onRotateCW: () ->
        # Handle a request by the user to rotate the image clockwise

        # Simulate rotating the image
        @_dialog.busy(true)
        clearBusy = () =>
            @_dialog.busy(false)
        setTimeout(clearBusy, 1500)

    _onSave: () ->
        # Handle the user saving the image

        # Simulate processing the image
        @_dialog.busy(true)
        clearBusy = () =>
            @_dialog.busy(false)
            @_dialog.save(
                ImageUploader.imagePath,
                ImageUploader.imageSize
                {alt: 'Example of bad variable names'}
                )

        setTimeout(clearBusy, 1500)

    _onUnmount: () ->
        # Handle the dialog being unmounted from the UI

    # Class methods

    @createImageUploader: (dialog) ->
        return new ImageUploader(dialog)

window.ImageUploader = ImageUploader