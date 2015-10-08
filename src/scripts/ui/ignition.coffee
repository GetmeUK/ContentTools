class ContentTools.IgnitionUI extends ContentTools.WidgetUI

    # To control editing of content (starting/stopping) a ignition switch is
    # provided, the switch has 3 states:

    constructor: () ->
        super()

        # Flag indicating if the ignition is currently busy (cannot be
        # interacted with).
        @_busy = false

    # Methods

    busy: (busy) ->
        # Get/Set the busy state of the ignition switch. The busy state is
        # useful when you want to prevent the user from attempting to start the
        # editor, for example during a save request.
        if busy is undefined
            return @_busy

        # Check the ignition isn't already busy
        if @_busy is busy
            return

        # Change the state of the switch
        @_busy = busy
        if busy
            @addCSSClass('ct-ignition--busy')
        else
            @removeCSSClass('ct-ignition--busy')

    changeState: (state) ->
        # Change the state of the ignition without triggering an event, (useful
        # when you wish to revert to a previous state).
        if state is 'editing'
            @addCSSClass('ct-ignition--editing')
            @removeCSSClass('ct-ignition--ready')

        else if state is 'ready'
            @removeCSSClass('ct-ignition--editing')
            @addCSSClass('ct-ignition--ready')

    mount: () ->
        # Mount the component to the DOM
        super()

        # Base widget component
        @_domElement = @constructor.createDiv([
            'ct-widget',
            'ct-ignition',
            'ct-ignition--ready'
            ])
        @parent().domElement().appendChild(@_domElement)

        # Edit button
        @_domEdit = @constructor.createDiv([
            'ct-ignition__button',
            'ct-ignition__button--edit'
            ])
        @_domElement.appendChild(@_domEdit)

        # Confirm button
        @_domConfirm = @constructor.createDiv([
            'ct-ignition__button',
            'ct-ignition__button--confirm'
            ])
        @_domElement.appendChild(@_domConfirm)

        # Cancel button
        @_domCancel = @constructor.createDiv([
            'ct-ignition__button',
            'ct-ignition__button--cancel'
            ])
        @_domElement.appendChild(@_domCancel)

        # Busy
        @_domBusy = @constructor.createDiv([
            'ct-ignition__button',
            'ct-ignition__button--busy'
            ])
        @_domElement.appendChild(@_domBusy)

        # Add events
        @_addDOMEventListeners()

    unmount: () ->
        # Unmount the widget from the DOM
        super()

        @_domEdit = null
        @_domConfirm = null
        @_domCancel = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add all DOM event bindings for the component in this method

        # Start editing
        @_domEdit.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Change the state of the switch
            @addCSSClass('ct-ignition--editing')
            @removeCSSClass('ct-ignition--ready')

            # Trigger the start event
            @trigger('start')

        # Stop editing - Confirm changes
        @_domConfirm.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Change the state of the switch
            @removeCSSClass('ct-ignition--editing')
            @addCSSClass('ct-ignition--ready')

            # Trigger the start event
            @trigger('stop', true)

        # Stop editing - Cancel changes
        @_domCancel.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Change the state of the switch
            @removeCSSClass('ct-ignition--editing')
            @addCSSClass('ct-ignition--ready')

            # Trigger the start event
            @trigger('stop', false)