class CloudinaryImageUploader
    # An image uploader for the cloudinary image service (http://cloudinary.com)

    # The name of the cloud to upload images to
    @CLOUD_NAME: ''

    # The dimensions of the image as a draft used for editing before insertion
    @DRAFT_DIMENSIONS: [600, 600]

    # The default dimensions at which to insert the image at
    @INSERT_DIMENSIONS: [400, 400]

    # The URL used to retreive images from the service
    @RETRIEVE_URL: 'http://res.cloudinary.com/#CLOUD_NAME#/image/upload'

    # The preset code to uploaded to (required to support unsigned uploads)
    @UPLOAD_PRESET: ''

    # The URL used to upload images to the service
    @UPLOAD_URL: 'https://api.cloudinary.com/v1_1/#CLOUD_NAME#/image/upload'

    constructor: (dialog) ->
        # Initialize the dialog to support image uploads
        @_dialog = dialog

        # Add event handlers for the dialog
        @_dialog.bind 'imageUploader.cancelUpload', () =>
            @_onCancelUpload()

        @_dialog.bind 'imageUploader.clear', () =>
            @_onClear()

        @_dialog.bind 'imageUploader.fileReady', (files) =>
            @_onFileReady(files)

        @_dialog.bind 'imageUploader.rotateCCW', () =>
            @_onRotate(-90)

        @_dialog.bind 'imageUploader.rotateCW', () =>
            @_onRotate(90)

        @_dialog.bind 'imageUploader.save', () =>
            @_onSave()

    # Event handlers

    _onCancelUpload: () ->
        # Handle an upload being cancelled

        # Stop any upload
        if @_xhr
            @_xhr.upload.removeEventListener 'progress', @_xhrProgress
            @_xhr.removeEventListener 'readystatechange', @_xhrComplete
            @_xhr.abort()

        # Set the dialog to empty
        @_dialog.state('empty')

    _onClear: () ->
        # Handle the current image being cleared
        @_dialog.clear()
        @_image = null

    _onFileReady: (file) ->
        # Handle a file being selected by the user

        # Set the dialog state to uploading
        @_dialog.progress(0)
        @_dialog.state('uploading')

        # Build the form data to post to the server
        formData = new FormData()
        formData.append('file', file)
        formData.append('upload_preset', @constructor.UPLOAD_PRESET)

        # Build a request to send the file
        @_xhr = new XMLHttpRequest();
        @_xhr.open('POST', @constructor._getUploadURL(), true)

        # Handle progress
        @_xhrProgress = (ev) =>
            @_dialog.progress((ev.loaded / ev.total) * 100)

        # Handle completion
        @_xhrComplete = (ev) =>
            readyState = ev.target.readyState
            text = ev.target.responseText
            status = ev.target.status

            # Look for done response
            if readyState != 4
                return

            # Clear the XHR reference
            @_xhr = null

            # Handle the result of the upload
            if parseInt(status) is 200
                # Unpack the response (JSON)
                @_image = JSON.parse(text)

                # Store basic image attributes
                @_image.angle = 0
                @_image.width = parseInt(@_image.width)
                @_image.height = parseInt(@_image.height)
                @_image.maxWidth = @_image.width

                # Apply a draft size to the image for editing
                filename = @constructor.parseURL(@_image.url)[0]
                @_image.url = @constructor.buildURL(
                    filename,
                    [@constructor._getDraftTransform()]
                    )

                # Update the image in the dialog viewer
                @_dialog.populate(@_image.url, [@_image.width, @_image.height])

            else
                # Handle error response
                new ContentTools.FlashUI('no')

        @_xhr.upload.addEventListener('progress', @_xhrProgress)
        @_xhr.addEventListener('readystatechange', @_xhrComplete)

        # Send the file
        @_xhr.send(formData)

    _onRotate: (angle) ->
        # Handle a request by the user to rotate the image

        # Update the angle of the image
        @_image.angle += angle

        # Stay with the range 0-360
        if @_image.angle < 0
            @_image.angle += 360
        else if @_image.angle > 270
            @_image.angle -= 360

        # Whenever the image is rotated the dimensions are switched
        w = @_image.width
        h = @_image.height
        @_image.width = h
        @_image.height = w
        @_image.maxWidth = @_image.width

        # Build the transform for the image
        transforms = [@constructor._getDraftTransform()]
        if @_image.angle > 0
            transforms.unshift({a: @_image.angle})

        # Apply the rotation
        filename = @constructor.parseURL(@_image.url)[0]
        @_image.url = @constructor.buildURL(filename, transforms)

        # Update the image in the dialog viewer
        @_dialog.populate(@_image.url, [@_image.width, @_image.height])

    _onSave: () ->
        # Handle the user saving the image

        # Build the transforms to apply to the inserted image
        transforms = []

        # Angle
        if @_image.angle != 0
            transforms.push({a: @_image.angle})

        # Crop
        cropRegion = @_dialog.cropRegion()
        if not (cropRegion.toString() is [0, 0, 1, 1].toString())
            cropTransform = {
                c: 'crop',
                x: parseInt(@_image.width * cropRegion[1]),
                y: parseInt(@_image.height * cropRegion[0]),
                w: parseInt(@_image.width * (cropRegion[3] - cropRegion[1])),
                h: parseInt(@_image.height * (cropRegion[2] - cropRegion[0]))
                }

            # Update the width based on the crop
            @_image.width = cropTransform.w
            @_image.height = cropTransform.h
            @_image.maxWidth = @_image.width

            transforms.push(cropTransform)

        # Resize for insertion
        if @_image.width > @constructor.INSERT_DIMENSIONS[0] or
                @_image.height > @constructor.INSERT_DIMENSIONS[1]

            transforms.push({
                c: 'fit',
                w: @constructor.INSERT_DIMENSIONS[0],
                h: @constructor.INSERT_DIMENSIONS[1]
                })

            # Update the size of the image to fit the resize
            widthScale = @constructor.INSERT_DIMENSIONS[0] / @_image.width
            heightScale = @constructor.INSERT_DIMENSIONS[1] / @_image.height
            ratio = Math.min(widthScale, heightScale)
            @_image.width = ratio * @_image.width
            @_image.height = ratio * @_image.height

        # Build a URL for the image to insert
        filename = @constructor.parseURL(@_image.url)[0]
        @_image.url = @constructor.buildURL(filename, transforms)

        # Build the attributes for the image
        attrs = {
            'alt': '',
            'data-ce-max-width': @_image.maxWidth
        }

        # Insert the image
        @_dialog.save(@_image.url, [@_image.width, @_image.height], attrs)

    # Class methods

    @createImageUploader: (dialog) ->
        return new @(dialog)

    # Cloudinary utilities

    @_getDraftTransform: ()->
        # Return a transform to resize the image to the draft dimensions
        return {w: @DRAFT_DIMENSIONS[0], h: @DRAFT_DIMENSIONS[1], c: 'fit'}

    @_getRetrieveURL: () ->
        # Return the URL that images are retrieved from
        return @RETRIEVE_URL.replace('#CLOUD_NAME#', @CLOUD_NAME)

    @_getUploadURL: () ->
        # Return the URL that images are uploaded to
        return @UPLOAD_URL.replace('#CLOUD_NAME#', @CLOUD_NAME)

    @buildURL: (filename, transforms) ->
        # Build a URL from a filename and the transforms applied to the image

        # Build the transforms path
        transformStrs = []
        for transform in transforms
            paramStrs = []
            for name, value of transform
                paramStrs.push("#{ name }_#{ value }")
            transformStrs.push(paramStrs.join(','))

        # Build the URL
        parts = [@_getRetrieveURL()]
        if transformStrs.length > 0
            parts.push(transformStrs.join('/'))
        parts.push(filename)

        return parts.join('/')

    @parseURL: (url) ->
        # Parse a URL and return the filename and transformations

        # Strip the URL down to just the transformations, version (optional) and
        # filename.
        url = url.replace(new RegExp('^' + @_getRetrieveURL()), '')

        # Split the remaining path into parts
        parts = url.split('/')
        parts.shift()

        # Extract the filename
        filename = parts.pop()

        # If the URL contains a version remove it
        if parts.length and parts[parts.length - 1].match(/v\d+/)
            parts.pop()

        # Convert the remaining parts (transforms) into objects
        transforms = []
        for part in parts
            transform = {}
            for pair in part.split(',')
                [name, value] = pair.split('_')
                transform[name] = value
            transforms.push(transform)

        return [filename, transforms]

window.CloudinaryImageUploader = CloudinaryImageUploader


# Capture resize events and update image URLs to cater
_resizeTimeout = null

ContentEdit.Root.get().bind 'taint', (element) ->

    # We're only interested in images
    unless element.type() is 'Image'
        return

    # Give the user time to finish resizing before updating the URL
    if _resizeTimeout
        clearTimeout(_resizeTimeout)

    resizeURL = () ->
        # Update the images URL to reflect it's new size
        cls = CloudinaryImageUploader

        # Parse the existing URL
        [filename, transforms] = cls.parseURL(element.attr('src'))

        # If we couldn't parse the image URL exit
        if filename == undefined
            return

        # Switch out the size for the new size
        newSize = element.size()

        # Remove any existing resize transform
        if transforms.length > 0 and
                transforms[transforms.length - 1]['c'] == 'fill'
            transforms.pop()

        transforms.push({w: newSize[0], h: newSize[1], c: 'fill'})
        element.attr('src', cls.buildURL(filename, transforms))

    _resizeTimeout = setTimeout(resizeURL, 500)