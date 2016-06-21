class ContentTools.LinkDialog extends ContentTools.AnchoredDialogUI

    # An anchored dialog to support inserting/modifying a link

    # The target that will be set by the link tool if the open in new window
    # option is selected.
    NEW_WINDOW_TARGET = '_blank'

    constructor: (href='', target='') ->
        super()

        # The initial value to set the href and target attribute
        # of the link as (e.g if we're editing a link).
        @_href = href
        @_target = target

    mount: () ->
        # Mount the widget
        super()

        # Create the input element for the link
        @_domInput = document.createElement('input')
        @_domInput.setAttribute('class', 'ct-anchored-dialog__input')
        @_domInput.setAttribute('name', 'href')
        @_domInput.setAttribute(
            'placeholder',
            ContentEdit._('Enter a link') + '...'
            )
        @_domInput.setAttribute('type', 'text')
        @_domInput.setAttribute('value', @_href)
        @_domElement.appendChild(@_domInput)

        # Create a toggle button to allow users to toogle between no target and
        # TARGET (open in a new window).
        @_domTargetButton = @constructor.createDiv([
            'ct-anchored-dialog__target-button'])
        @_domElement.appendChild(@_domTargetButton)

        # Check if the new window target has already been set for the link
        if @_target == NEW_WINDOW_TARGET
            ContentEdit.addCSSClass(
                @_domTargetButton,
                'ct-anchored-dialog__target-button--active'
            )

        # Create the confirm button
        @_domButton = @constructor.createDiv(['ct-anchored-dialog__button'])
        @_domElement.appendChild(@_domButton)

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the link. This method triggers the save method against the dialog
        # allowing the calling code to listen for the `save` event and manage
        # the outcome.

        if not @isMounted()
            @dispatchEvent(@createEvent('save'))
            return

        detail = {href: @_domInput.value.trim()}
        if @_target
            detail.target = @_target

        @dispatchEvent(@createEvent('save', detail))

    show: () ->
        # Show the widget
        super()

        # Once visible automatically give focus to the link input
        @_domInput.focus()

        # If a there's an intially value then select it so it can be easily
        # replaced.
        if @_href
            @_domInput.select()

    unmount: () ->
        # Unmount the component from the DOM

        # Unselect any content
        if @isMounted()
            @_domInput.blur()

        super()

        @_domButton = null
        @_domInput = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget

        # Add support for saving the link whenever the `return` key is pressed
        # or the button is selected.

        # Input
        @_domInput.addEventListener 'keypress', (ev) =>
            if ev.keyCode is 13
                @save()

        # Toggle the target attribute for the link ('' or TARGET)
        @_domTargetButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # No target
            if @_target == NEW_WINDOW_TARGET
                @_target = ''
                ContentEdit.removeCSSClass(
                    @_domTargetButton,
                    'ct-anchored-dialog__target-button--active'
                )

            # Target TARGET
            else
                @_target = NEW_WINDOW_TARGET
                ContentEdit.addCSSClass(
                    @_domTargetButton,
                    'ct-anchored-dialog__target-button--active'
                )

        # Button
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @save()
