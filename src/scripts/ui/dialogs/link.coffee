class ContentTools.LinkDialog extends ContentTools.AnchoredDialogUI

    # An anchored dialog to support inserting/modifying a link

    constructor: (initialValue='')->
        super()

        # The initial value to set the link as (e.g if we're editing a link)
        @_initialValue = initialValue

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
        @_domInput.setAttribute('value', @_initialValue)
        @_domElement.appendChild(@_domInput)

        # Create the confirm button
        @_domButton = @constructor.createDiv(['ct-anchored-dialog__button'])
        @_domElement.appendChild(@_domButton)

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the link. This method triggers the save method against the dialog
        # allowing the calling code to listen for the `save` event and manage
        # the outcome.

        if not @isMounted
            return @trigger('save', '')

        @trigger('save', @_domInput.value.trim())

    show: () ->
        # Show the widget
        super()

        # Once visible automatically give focus to the link input
        @_domInput.focus()

        # If a there's an intially value then select it so it can be easily
        # replaced.
        if @_initialValue
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

        # Button
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @save()
