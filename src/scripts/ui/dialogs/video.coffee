class ContentTools.VideoDialog extends ContentTools.DialogUI

    # A dialog to support inserting a video

    constructor: ()->
        super('Insert video')

    clearPreview: () ->
        # Clear the current video preview
        if @_domPreview
            @_domPreview.parentNode.removeChild(@_domPreview)
            @_domPreview = undefined

    mount: () ->
        # Mount the widget
        super()

        # Update dialog class
        ContentEdit.addCSSClass(@_domElement, 'ct-video-dialog')

        # Update view class
        ContentEdit.addCSSClass(@_domView, 'ct-video-dialog__preview')

        # Add controls
        domControlGroup = @constructor.createDiv(['ct-control-group'])
        @_domControls.appendChild(domControlGroup)

        # Input
        @_domInput = document.createElement('input')
        @_domInput.setAttribute('class', 'ct-video-dialog__input')
        @_domInput.setAttribute('name', 'url')
        @_domInput.setAttribute(
            'placeholder',
            ContentEdit._('Paste YouTube or Vimeo URL') + '...'
            )
        @_domInput.setAttribute('type', 'text')
        domControlGroup.appendChild(@_domInput)

        # Insert button
        @_domButton = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--insert'
            'ct-control--muted'
            ])
        @_domButton.textContent = ContentEdit._('Insert')
        domControlGroup.appendChild(@_domButton)

        # Add interaction handlers
        @_addDOMEventListeners()

    preview: (url) ->
        # Preview the specified URL

        # Remove any existing preview
        @clearPreview()

        # Insert the preview iframe
        @_domPreview = document.createElement('iframe')
        @_domPreview.setAttribute('frameborder', '0')
        @_domPreview.setAttribute('height', '100%')
        @_domPreview.setAttribute('src', url)
        @_domPreview.setAttribute('width', '100%')
        @_domView.appendChild(@_domPreview)

    save: () ->
        # Save the video. This method triggers the save method against the
        # dialog allowing the calling code to listen for the `save` event and
        # manage the outcome.

        # Attempt to parse a video embed URL
        videoURL = @_domInput.value.trim()
        embedURL = ContentTools.getEmbedVideoURL(videoURL)
        if embedURL
            @dispatchEvent(@createEvent('save', {'url': embedURL}))
        else
            # If we can't generate an embed URL trust that the user's knows what
            # they are doing and save with the supplied URL.
            @dispatchEvent(@createEvent('save', {'url': videoURL}))

    show: () ->
        # Show the widget
        super()

        # Once visible automatically give focus to the link input
        @_domInput.focus()

    unmount: () ->
        # Unmount the component from the DOM

        # Unselect any content
        if @isMounted()
            @_domInput.blur()

        super()

        @_domButton = null
        @_domInput = null
        @_domPreview = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget
        super()

        # Provide a preview of the video whenever a valid URL is inserted into
        # the input.
        @_domInput.addEventListener 'input', (ev) =>

            # If the input field is empty we disable the insert button
           if ev.target.value
                ContentEdit.removeCSSClass(@_domButton, 'ct-control--muted')
            else
                ContentEdit.addCSSClass(@_domButton, 'ct-control--muted')

            # We give the user half a second to make additional changes before
            # updating the preview video otherwise changes to the text input can
            # appear to stutter as the browser updates the preview on every
            # change.

            if @_updatePreviewTimeout
                clearTimeout(@_updatePreviewTimeout)

            updatePreview = () =>
                videoURL = @_domInput.value.trim()
                embedURL = ContentTools.getEmbedVideoURL(videoURL)
                if embedURL
                    @preview(embedURL)
                else
                    @clearPreview()

            @_updatePreviewTimeout = setTimeout(updatePreview, 500)

        # Add support for saving the video whenever the `return` key is pressed
        # or the button is selected.

        # Input
        @_domInput.addEventListener 'keypress', (ev) =>
            if ev.keyCode is 13
                @save()

        # Button
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check the button isn't muted, if it is then the video URL fields
            # isn't populated.
            cssClass = @_domButton.getAttribute('class')
            if cssClass.indexOf('ct-control--muted') == -1
                @save()