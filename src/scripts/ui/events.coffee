class ContentTools.Event

    # The `Event` class provides information about events dispatched by
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
        # Return true if the event has been cancelled
        return @_defaultPrevented

    detail: () ->
        # Return the detail of the event
        return @_detail

    name: () ->
        # Return the name of the event
        return  @_name

    propagationStopped: () ->
        # Return true if the event has been halted
        return @_propagationStopped

    timeStamp: () ->
        # Return a time stamp of when the event was created
        return @_timeStamp

    # Methods

    preventDefault: () ->
        # Cancel the event preventing the default event action
        @_defaultPrevented = true

    stopImmediatePropagation: () ->
        # Halt the event preventing any bound listener functions that have not
        # yet been called for the event being called.
        @_propagationStopped = true