class ContentTools.AnchoredDialogUI extends ContentTools.WidgetUI

    # Base class for creating anchored dialogs. An anchored dialog appears above
    # the page but is anchored to a set position within, they are typically used
    # for in page edits, such as setting a link within the page.

    constructor: () ->
        super()

        # The position of the dialog
        @_position = [0, 0]

    # Public methods

    mount: () ->
        # Mount the widget to the DOM
        #
        # Note: This method doesn't call the `_addEventListeners` method which
        # is typical of other UI components, instead it expects the inheriting
        # class to override this method and call `_addEventListeners` at the
        # appropriate point.

        # Create the dialog
        @_domElement = @constructor.createDiv([
            'ct-widget',
            'ct-anchored-dialog'
            ])
        @parent().domElement().appendChild(@_domElement)

        # Set the position of the dialog
        @_contain()
        @_domElement.style.top = "#{ @_position[1] }px"
        @_domElement.style.left = "#{ @_position[0] }px"

    position: (newPosition) ->
        # Get/Set the position of the dialog
        if newPosition is undefined
            return @_position.slice()

        @_position = newPosition.slice()

        if @isMounted()
            @_contain()
            @_domElement.style.top = "#{ @_position[1] }px"
            @_domElement.style.left = "#{ @_position[0] }px"

    # Private methods

    _contain: () ->
        # Ensure the position doesn't place the dialog off the page.

        # The component must be mounted in the DOM, if not we can't determined
        # the width and height and therefore whether the position places the
        # dialog off the page or not.
        if not @isMounted()
            return

        # Calculate half the width of the anchored dialog (as anchored dialogs
        # are displayed centrally) amnd add a 5 pixel buffer so we don't bump
        # right up to the edge.
        halfWidth = (@_domElement.getBoundingClientRect().width / 2 + 5)

        # Get the width of the document excluding the scroll bars
        pageWidth = document.documentElement.clientWidth or
            document.body.clientWidth

        # Adjust the position to be contained (if necessary)
        if (@_position[0] + halfWidth) > (pageWidth - halfWidth)
            @_position[0] = pageWidth - halfWidth

        if @_position[0] < halfWidth
            @_position[0] = halfWidth


class ContentTools.DialogUI extends ContentTools.WidgetUI

    # Base class for creating standard dialogs.

    constructor: (caption='') ->
        super()

        # A flag indicating that the dialog is currently busy
        @_busy = false

        # The dialog's caption
        @_caption = caption

    # Methods

    busy: (busy) ->
        # Get/Set the dialog's busy status
        if busy is undefined
            return @_busy

        # Check that we need to change the current state of the dialog
        if @_busy is busy
            return

        # Modify the state
        @_busy = busy

        # Add/Remove busy modifier class to the dialog
        if not @isMounted()
            return

        if @_busy
            ContentEdit.addCSSClass(@_domElement, 'ct-dialog--busy')
        else
            ContentEdit.removeCSSClass(@_domElement, 'ct-dialog--busy')

    caption: (caption) ->
        # Get/Set the caption for the dialog
        if caption is undefined
            return @_caption

        # Replace any existing caption
        @_caption = caption
        @_domCaption.textContent = ContentEdit._(caption)

    mount: () ->
        # Mount the widget to the DOM
        #
        # Note: This method doesn't call the `_addEventListeners` method which
        # is typical of other UI components, instead it expects the inheriting
        # class to override this method an call `_addEventListeners` at the
        # appropriate point.

        # Blur the focused element to ensure that it's contents can be edited
        # once the dialog is open.
        if document.activeElement
            document.activeElement.blur()

            # HACK: This is a work around for blurring the contenteditable
            # element in webkit, thanks to Marek Suscak's fiddle here:
            # http://jsfiddle.net/mareksuscak/oytdoxy8/
            #
            # ~ Anthony Blackshaw <ant@getme.co.uk>, 28th June 2016
            window.getSelection().removeAllRanges()

        # Create the dialog
        dialogCSSClasses = [
            'ct-widget',
            'ct-dialog'
            ]
        if @_busy
            dialogCSSClasses.push('ct-dialog--busy')
        @_domElement = @constructor.createDiv(dialogCSSClasses)
        @parent().domElement().appendChild(@_domElement)

        # Add the dialog header
        domHeader = @constructor.createDiv(['ct-dialog__header'])
        @_domElement.appendChild(domHeader)

        # Caption
        @_domCaption = @constructor.createDiv(['ct-dialog__caption'])
        domHeader.appendChild(@_domCaption)
        @caption(@_caption)

        # Close button
        @_domClose = @constructor.createDiv(['ct-dialog__close'])
        domHeader.appendChild(@_domClose)

        # Body
        domBody = @constructor.createDiv(['ct-dialog__body'])
        @_domElement.appendChild(domBody)

        # View
        @_domView = @constructor.createDiv(['ct-dialog__view'])
        domBody.appendChild(@_domView)

        # Controls
        @_domControls = @constructor.createDiv(['ct-dialog__controls'])
        domBody.appendChild(@_domControls)

        # Busy
        @_domBusy = @constructor.createDiv(['ct-dialog__busy'])
        @_domElement.appendChild(@_domBusy)

    unmount: () ->
        # Unmount the component from the DOM
        super()

        @_domBusy = null
        @_domCaption = null
        @_domClose = null
        @_domControls = null
        @_domView = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget

        # Cancelling the dialog

        # Using the escape key
        @_handleEscape = (ev) =>

            # Check the dialog isn't busy
            if @_busy
                return

            if ev.keyCode is 27
                @dispatchEvent(@createEvent('cancel'))

        document.addEventListener('keyup', @_handleEscape)

        # Via the close button
        @_domClose.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check the dialog isn't busy
            if @_busy
                return

            @dispatchEvent(@createEvent('cancel'))

    _removeDOMEventListeners: () ->

        document.removeEventListener('keyup', @_handleEscape)