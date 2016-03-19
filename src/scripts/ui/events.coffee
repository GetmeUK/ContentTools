class ContentTools.Event

    # The `Event` class provides information about events dispatched from/to
    # `UIComponents`.

    constructor: (name, detail) ->

        # The name of the event
        @_name = name

        # Detail of the event (typically an object but can actually be set to
        # any value).
        @_detail = detail

        # The date/time the event was created
        @_timeStamp = Date.now()

        # A flag indicating if the event has been cancelled
        @_defaultPrevented = false

        # A flag indicating if the execution of additional callbacks for the
        # event has been halted.
        @_propagationStopped = false

    # Read-only properties

    defaultPrevented: () ->
        return @_defaultPrevented

    detail: () ->
        return @_detail

    name: () ->
        return  @_name

    propagationStopped: () ->
        return @_propagationStopped

    timeStamp: () ->
        return @_timeStamp

    # Methods

    preventDefault: () ->
        # Cancel the event
        @_defaultPrevented = true

    stopImmediatePropagation: () ->
        # Prevent the event trigger any future callbacks
        @_propagationStopped = true