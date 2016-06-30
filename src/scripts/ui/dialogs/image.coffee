class ContentTools.ImageDialog extends ContentTools.DialogUI

    # A dialog to support inserting an image

    # Note: The image dialog doesn't handle the uploading of images it expects
    # this process to be handled by an external library. The external library
    # should be defined as an object against the ContentTools namespace like so:
    #
    # ContentTools.IMAGE_UPLOADER = externalImageUploader
    #
    # The external library should provide an `init(dialog)` method. This method
    # recieves the dialog widget and can then set up all required event bindings
    # to support image uploads.

    constructor: ()->
        super('Insert image')

        # If applied, this is a handle to the crop marks component for the
        # current image.
        @_cropMarks = null

        # If the dialog is populated, this is the URL of the image
        @_imageURL = null

        # If the dialog is populated, this is the size of the image
        @_imageSize = null

        # The upload progress of the dialog (0-100)
        @_progress = 0

        # The initial state of the dialog
        @_state = 'empty'

        # If an image uploader factory is defined create a new uploader for the
        # dialog.
        if ContentTools.IMAGE_UPLOADER
            ContentTools.IMAGE_UPLOADER(this)

    # Read-only properties

    cropRegion: () ->
        # Return the defined crop-region (top, left, bottom, right), values are
        # normalized to the range 0.0 - 1.0. If no crop region is defined then
        # the maximum region will be returned (e.g [0, 0, 1, 1])
        if @_cropMarks
            return @_cropMarks.region()

        return [0, 0, 1, 1]

    # Methods

    addCropMarks: () ->
        # Add crop marks to the current image
        if @_cropMarks
            return

        # Determine the crop region
        @_cropMarks = new CropMarksUI(@_imageSize)
        @_cropMarks.mount(@_domView)

        # Mark the crop control as active
        ContentEdit.addCSSClass(@_domCrop, 'ct-control--active')

    clear: () ->
        # Clear the current image
        if @_domImage
            @_domImage.parentNode.removeChild(@_domImage)
            @_domImage = null

        # Clear image attributes
        @_imageURL = null
        @_imageSize = null

        # Set the dialog to empty
        @state('empty')

    mount: () ->
        # Mount the widget
        super()

        # Update dialog class
        ContentEdit.addCSSClass(@_domElement, 'ct-image-dialog')
        ContentEdit.addCSSClass(@_domElement, 'ct-image-dialog--empty')

        # Update view class
        ContentEdit.addCSSClass(@_domView, 'ct-image-dialog__view')

        # Add controls

        # Image tools & progress bar
        domTools = @constructor.createDiv(
            ['ct-control-group', 'ct-control-group--left'])
        @_domControls.appendChild(domTools)

        # Rotate CCW
        @_domRotateCCW = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--rotate-ccw'
            ])
        @_domRotateCCW.setAttribute(
            'data-ct-tooltip',
            ContentEdit._('Rotate') + ' -90°'
            )
        domTools.appendChild(@_domRotateCCW)

        # Rotate CW
        @_domRotateCW = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--rotate-cw'
            ])
        @_domRotateCW.setAttribute(
            'data-ct-tooltip',
            ContentEdit._('Rotate') + ' 90°'
            )
        domTools.appendChild(@_domRotateCW)

        # Rotate CW
        @_domCrop = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--crop'
            ])
        @_domCrop.setAttribute('data-ct-tooltip', ContentEdit._('Crop marks'))
        domTools.appendChild(@_domCrop)

        # Progress bar
        domProgressBar = @constructor.createDiv(['ct-progress-bar'])
        domTools.appendChild(domProgressBar)

        @_domProgress = @constructor.createDiv(['ct-progress-bar__progress'])
        domProgressBar.appendChild(@_domProgress)

        # Actions
        domActions = @constructor.createDiv(
            ['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domActions)

        # Upload button
        @_domUpload = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--upload'
            ])
        @_domUpload.textContent = ContentEdit._('Upload')
        domActions.appendChild(@_domUpload)

        # File input for upload
        @_domInput = document.createElement('input')
        @_domInput.setAttribute('class', 'ct-image-dialog__file-upload')
        @_domInput.setAttribute('name', 'file')
        @_domInput.setAttribute('type', 'file')
        @_domInput.setAttribute('accept', 'image/*')
        @_domUpload.appendChild(@_domInput)

        # Insert
        @_domInsert = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--insert'
            ])
        @_domInsert.textContent = ContentEdit._('Insert')
        domActions.appendChild(@_domInsert)

        # Cancel
        @_domCancelUpload = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--cancel'
            ])
        @_domCancelUpload.textContent = ContentEdit._('Cancel')
        domActions.appendChild(@_domCancelUpload)

        # Clear
        @_domClear = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--clear'
            ])
        @_domClear.textContent = ContentEdit._('Clear')
        domActions.appendChild(@_domClear)

        # Add interaction handlers
        @_addDOMEventListeners()

        @dispatchEvent(@createEvent('imageuploader.mount'))

    populate: (imageURL, imageSize) ->
        # Populate the dialog with an image

        # Set image attributes
        @_imageURL = imageURL
        @_imageSize = imageSize

        # Check for existing image, if there isn't one add one
        if not @_domImage
            @_domImage = @constructor.createDiv(['ct-image-dialog__image'])
            @_domView.appendChild(@_domImage)

        # Set the image to appear
        @_domImage.style['background-image'] = "url(#{ imageURL })"

        # Set the dialog to populated
        @state('populated')

    progress: (progress) ->
        # Get/Set upload progress
        if progress is undefined
            return @_progress

        @_progress = progress

        # Update progress bar width
        if not @isMounted()
            return

        @_domProgress.style.width = "#{ @_progress }%"

    removeCropMarks: () ->
        # Remove crop marks from the current image
        if not @_cropMarks
            return

        @_cropMarks.unmount()
        @_cropMarks = null

        # Mark the crop control as no longer active
        ContentEdit.removeCSSClass(@_domCrop, 'ct-control--active')

    save: (imageURL, imageSize, imageAttrs) ->
        # Save and insert the current image
        @dispatchEvent(
            @createEvent(
                'save',
                {
                    'imageURL': imageURL,
                    'imageSize': imageSize,
                    'imageAttrs': imageAttrs
                })
            )

    state: (state) ->
        # Set/get the state of the dialog (empty, uploading, populated)

        if state is undefined
            return @_state

        # Check that we need to change the current state of the dialog
        if @_state == state
            return

        # Modify the state
        prevState = @_state
        @_state = state

        # Update state modifier class for the dialog
        if not @isMounted()
            return

        ContentEdit.addCSSClass(@_domElement, "ct-image-dialog--#{ @_state }")
        ContentEdit.removeCSSClass(
            @_domElement,
            "ct-image-dialog--#{ prevState }"
            )

    unmount: () ->
        # Unmount the component from the DOM
        super()

        @_domCancelUpload = null
        @_domClear = null
        @_domCrop = null
        @_domInput = null
        @_domInsert = null
        @_domProgress = null
        @_domRotateCCW = null
        @_domRotateCW = null
        @_domUpload = null

        @dispatchEvent(@createEvent('imageuploader.unmount'))

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget
        super()

        # File ready for upload
        @_domInput.addEventListener 'change', (ev) =>
            # Get the file uploaded
            file = ev.target.files[0]

            # Clear the file inputs value so that the same file can be uploaded
            # again if the user cancels the upload or clears it and starts then
            # changes their mind.
            ev.target.value = ''
            if ev.target.value
                # Hack for clearing the file field value in IE
                ev.target.type = 'text'
                ev.target.type = 'file'

            @dispatchEvent(
                @createEvent('imageuploader.fileready', {file: file})
                )

        # Cancel upload
        @_domCancelUpload.addEventListener 'click', (ev) =>
            @dispatchEvent(@createEvent('imageuploader.cancelupload'))

        # Clear image
        @_domClear.addEventListener 'click', (ev) =>
            @removeCropMarks()
            @dispatchEvent(@createEvent('imageuploader.clear'))

        # Rotate the image
        @_domRotateCCW.addEventListener 'click', (ev) =>
            @removeCropMarks()
            @dispatchEvent(@createEvent('imageuploader.rotateccw'))

        @_domRotateCW.addEventListener 'click', (ev) =>
            @removeCropMarks()
            @dispatchEvent(@createEvent('imageuploader.rotatecw'))

        @_domCrop.addEventListener 'click', (ev) =>
            if @_cropMarks
                @removeCropMarks()

            else
                @addCropMarks()

        @_domInsert.addEventListener 'click', (ev) =>
            @dispatchEvent(@createEvent('imageuploader.save'))


class CropMarksUI extends ContentTools.AnchoredComponentUI

    # Crop marks widget. Allows a crop region to be defined for images in the
    # image dialog.

    constructor: (imageSize)->
        super()

        # Set when the component is mounted/fitted, holds the region the
        # crop marks are restricted to.
        @_bounds = null

        # The handle currently being dragged
        @_dragging = null

        # The origin of the drag (e.g the top, left coordinates the drag started
        # from).
        @_draggingOrigin = null

        # The physical size of the image being cropped
        @_imageSize = imageSize

    # Methods

    mount: (domParent, before=null) ->
        # Crop marks
        @_domElement = @constructor.createDiv(['ct-crop-marks'])

        # Clippers
        @_domClipper = @constructor.createDiv(['ct-crop-marks__clipper'])
        @_domElement.appendChild(@_domClipper)

        # Rulers
        @_domRulers = [
            @constructor.createDiv([
                'ct-crop-marks__ruler',
                'ct-crop-marks__ruler--top-left'
                ]),
            @constructor.createDiv([
                'ct-crop-marks__ruler',
                'ct-crop-marks__ruler--bottom-right'
                ])
            ]
        @_domClipper.appendChild(@_domRulers[0])
        @_domClipper.appendChild(@_domRulers[1])

        # Handles
        @_domHandles = [
            @constructor.createDiv([
                'ct-crop-marks__handle',
                'ct-crop-marks__handle--top-left'
                ]),
            @constructor.createDiv([
                'ct-crop-marks__handle',
                'ct-crop-marks__handle--bottom-right'
                ])
            ]
        @_domElement.appendChild(@_domHandles[0])
        @_domElement.appendChild(@_domHandles[1])

        # Mount the widget
        super(domParent, before)

        # Fit the component to the parent components image
        @_fit(domParent)

    region: () ->
        # Return the crop region (top, left, bottom, right), values are
        # normalized to the range 0.0 - 1.0.
        return [
            parseFloat(@_domHandles[0].style.top) / @_bounds[1],
            parseFloat(@_domHandles[0].style.left) / @_bounds[0],
            parseFloat(@_domHandles[1].style.top) / @_bounds[1],
            parseFloat(@_domHandles[1].style.left) / @_bounds[0]
            ]

    unmount: () ->
        # Unmount the component from the DOM
        super()

        @_domClipper = null
        @_domHandles = null
        @_domRulers = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget
        super()

        # Handle the handles being dragged
        @_domHandles[0].addEventListener 'mousedown', (ev) =>

            # Check left mouse button used
            if ev.button is 0
                @_startDrag(0, ev.clientY, ev.clientX)

        @_domHandles[1].addEventListener 'mousedown', (ev) =>

            # Check left mouse button used
            if ev.button is 0
                @_startDrag(1, ev.clientY, ev.clientX)

    _drag: (top, left) ->
        # Handle dragging of handle/ruler
        if @_dragging == null
            return

        # Prevent content selection while dragging elements
        ContentSelect.Range.unselectAll()

        # Calculate the new position of the handle
        offsetTop = top - @_draggingOrigin[1]
        offsetLeft = left - @_draggingOrigin[0]

        # Apply constraints
        height = @_bounds[1]
        left = 0
        top = 0
        width = @_bounds[0]

        # Cannot overlap
        minCrop = Math.min(Math.min(ContentTools.MIN_CROP, height), width)

        if @_dragging is 0
            height = parseInt(@_domHandles[1].style.top) - minCrop
            width = parseInt(@_domHandles[1].style.left) - minCrop
        else
            left = parseInt(@_domHandles[0].style.left) + minCrop
            top = parseInt(@_domHandles[0].style.top) + minCrop

        # Must be within bounds
        offsetTop = Math.min(Math.max(top, offsetTop), height)
        offsetLeft = Math.min(Math.max(left, offsetLeft), width)

        # Move the handle
        @_domHandles[@_dragging].style.top = "#{ offsetTop }px"
        @_domHandles[@_dragging].style.left = "#{ offsetLeft }px"
        @_domRulers[@_dragging].style.top = "#{ offsetTop }px"
        @_domRulers[@_dragging].style.left = "#{ offsetLeft }px"

    _fit: (domParent) ->
        # Fit the crop marks element to reflect/overlap the image (displayed in
        # the background of the domParent.

        # Calculate the ratio required to fit the image into the parent DOM
        rect = domParent.getBoundingClientRect()
        widthScale = rect.width / @_imageSize[0]
        heightScale = rect.height / @_imageSize[1]
        ratio = Math.min(widthScale, heightScale)

        # Calculate the position and size for the crop marks element
        width = ratio * @_imageSize[0]
        height = ratio * @_imageSize[1]
        left = (rect.width - width) / 2
        top = (rect.height - height) / 2

        # Set the position and size of crop marks element
        @_domElement.style.width = "#{ width }px"
        @_domElement.style.height = "#{ height }px"
        @_domElement.style.top = "#{ top }px"
        @_domElement.style.left = "#{ left }px"

        # Position the handles and rulers
        @_domHandles[0].style.top = '0px'
        @_domHandles[0].style.left = '0px'
        @_domHandles[1].style.top = "#{ height }px"
        @_domHandles[1].style.left = "#{ width }px"

        @_domRulers[0].style.top = '0px'
        @_domRulers[0].style.left = '0px'
        @_domRulers[1].style.top = "#{ height }px"
        @_domRulers[1].style.left = "#{ width }px"

        # Set the bounds
        @_bounds = [width, height]

    _startDrag: (handleIndex, top, left) ->
        # Handle start of handle/ruler drag

        # Set dragging state
        domHandle = @_domHandles[handleIndex]
        @_dragging = handleIndex
        @_draggingOrigin = [
            left - parseInt(domHandle.style.left),
            top - parseInt(domHandle.style.top)
            ]

        # Handle any mouse move event (as a drag)
        @_onMouseMove = (ev) =>
            @_drag(ev.clientY, ev.clientX)

        document.addEventListener('mousemove', @_onMouseMove)

        # Handle any mouse up event (as stop dragging)
        @_onMouseUp = (ev) =>
            @_stopDrag()

        document.addEventListener('mouseup', @_onMouseUp)

    _stopDrag: () ->
        # Handle handle/ruler drag stopping

        # Remove event handlers
        document.removeEventListener('mousemove', @_onMouseMove)
        document.removeEventListener('mouseup', @_onMouseUp)

        # Unset dragging state
        @_dragging = null
        @_draggingOrigin = null