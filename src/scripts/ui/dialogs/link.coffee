class ContentTools.LinkDialog extends ContentTools.AnchoredDialogUI

    # An anchored dialog to support inserting/modifying a link

    constructor: (href='', target='') ->
        super()

        # The initial value to set the href and target attribute
        # of the link as (e.g if we're editing a link)
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

        # Create the open in new widow button
        @_domOpenInNewWindow = @constructor.createDiv(['ct-anchored-dialog__new-window-toggle'])
        @_domElement.appendChild(@_domOpenInNewWindow)

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

        linkAttr = {}
        linkAttr.href = @_domInput.value.trim()
        linkAttr.target = @_target if @_target

        @trigger('save', linkAttr)

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

    _targetToggleDOMClass: () ->
        if @_target == '_blank'
            ContentEdit.addCSSClass(
                @_domOpenInNewWindow,
                'ct-anchored-dialog__new-window-toggle--active'
            )
        else
            ContentEdit.removeCSSClass(
                @_domOpenInNewWindow,
                'ct-anchored-dialog__new-window-toggle--active'
            )

    _addDOMEventListeners: () ->
        # Add event listeners for the widget

        # Add support for saving the link whenever the `return` key is pressed
        # or the button is selected.

        # Input
        @_domInput.addEventListener 'keypress', (ev) =>
            if ev.keyCode is 13
                @save()

        # Open in new window
        @_domOpenInNewWindow.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_target = if @_target == '_blank' then '' else '_blank'
            @_targetToggleDOMClass()

        # Button
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @save()
