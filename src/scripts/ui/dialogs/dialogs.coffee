class ContentTools.AnchoredDialogUI extends ContentTools.WidgetUI

    # Base class for creating anchored dialogs. An anchored dialog appears above
    # the page but is anchored to a set position within, they are typically used
    # for in page edits, such as setting a link within the page.

    constructor: () ->
        super()

        # The position of the dialog
        @_position = [0, 0]

    # Methods

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
        @_domElement.style.top = "#{ @_position[1] }px"
        @_domElement.style.left = "#{ @_position[0] }px"

    position: (newPosition) ->
        # Get/Set the position of the dialog
        if newPosition is undefined
            return @_position.slice()

        @_position = newPosition.slice()

        if @isMounted()
            @_domElement.style.top = "#{ @_position[1] }px"
            @_domElement.style.left = "#{ @_position[0] }px"


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
                @trigger('cancel')

        document.addEventListener('keyup', @_handleEscape)

        # Via the close button
        @_domClose.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check the dialog isn't busy
            if @_busy
                return

            @trigger('cancel')

    _removeDOMEventListeners: () ->

        document.removeEventListener('keyup', @_handleEscape)