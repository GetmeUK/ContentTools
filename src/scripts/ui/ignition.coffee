class ContentTools.IgnitionUI extends ContentTools.WidgetUI

    # To control editing of content (starting/stopping) a ignition switch is
    # provided, the switch has 3 states:
    #
    # - ready    - Displays an edit option
    # - editing  - Displays confirm and cancel options
    # - busy     - Displays a busy status animation

    constructor: () ->
        super()

        # The state to return to once when the component state reverts from a
        # a busy state.
        @_revertToState = 'ready'

        # The state of the switch
        @_state = 'ready'

    # Methods

    busy: (busy) ->
        # Set the widget to busy (or revert if from a busy state to its previous
        # state.
        if @dispatchEvent(@createEvent('busy', {busy: busy}))

            # If the widget is already busy do nothing
            if busy == (@_state == 'busy')
                return

            if busy
                @_revertToState = @_state
                @state('busy')
            else
                @state(@_revertToState)

    cancel: () ->
        # Dispatch the cancel event against the switch and set its state to
        # ready.
        if @dispatchEvent(@createEvent('cancel'))
            @state('ready')

    confirm: () ->
        # Dispatch the confirm event against the switch set its state to
        # ready.
        if @dispatchEvent(@createEvent('confirm'))
            @state('ready')

    edit: () ->
        # Dispatch the edit event against the switch and set its state to
        # editing.
        if @dispatchEvent(@createEvent('edit'))
            @state('editing')

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

    state: (state) ->
        # Get/Set the state of the ignition switch. State must be one of the
        # following values:
        #
        # - busy
        # - editing
        # - ready
        #

        if state == undefined
            return @_state

        # If the state hasn't changed do nothing
        if @_state == state
            return

        if not @dispatchEvent(@createEvent('statechange', {state: state}))
            return

        # Modify the state of the switch
        @_state = state

        # Remove existing state modifier classes
        @removeCSSClass('ct-ignition--busy')
        @removeCSSClass('ct-ignition--editing')
        @removeCSSClass('ct-ignition--ready')

        # Apply the new state modifier class
        if @_state is 'busy'
            @addCSSClass('ct-ignition--busy')

        else if @_state is 'editing'
            @addCSSClass('ct-ignition--editing')

        else if @_state is 'ready'
            @addCSSClass('ct-ignition--ready')

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
            @edit()

        # Stop editing - Confirm changes
        @_domConfirm.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @confirm()

        # Stop editing - Cancel changes
        @_domCancel.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @cancel()