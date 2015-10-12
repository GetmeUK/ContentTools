class ContentTools.ComponentUI

    # All UI compontents inherit from the CompontentUI class which provides base
    # functionality and a common API.

    constructor: () ->

        # Event bindings for the component
        @_bindings = {}

        # The component's parent
        @_parent = null

        # The component's children
        @_children = []

        # The DOM element associated with this component
        @_domElement = null

    # Read-only methods

    children: () ->
        # Return the list of children for the component
        return @_children.slice()

    domElement: () ->
        # Return the mounted DOM element for the component
        return @_domElement

    isMounted: () ->
        # Return true if the component is mounted to the DOM
        return @_domElement != null

    parent: () ->
        # Return the parent of the component
        return @_parent

    # Methods

    attach: (component, index) ->
        # Attach a component as a child of this component

        if component.parent()
            component.parent().detach(component)

        component._parent = this

        if index != undefined
            @_children.splice(index, 0, component)
        else
            @_children.push(component)

    addCSSClass: (className) ->
        # Add a CSS class to the DOM element
        unless @isMounted()
            return

        ContentEdit.addCSSClass(@_domElement, className)

    detatch: (component) ->
        # Detach a child component from this component

        # Find the component to detatch (if not found return)
        componentIndex = @_children.indexOf(component)
        if componentIndex == -1
            return

        # Remove the component from the components children
        @_children.splice(componentIndex, 1)

    mount: () ->
        # Mount the component to the DOM

    removeCSSClass: (className) ->
        # Remove a CSS class from the DOM element
        unless @isMounted()
            return

        ContentEdit.removeCSSClass(@_domElement, className)

    unmount: () ->
        # Unmount the component from the DOM
        unless @isMounted()
            return

        @_removeDOMEventListeners()
        @_domElement.parentNode.removeChild(@_domElement)
        @_domElement = null

    # Event methods

    bind: (eventName, callback) ->
        # Bind a callback to an event

        # Check a list has been set for the specified event
        if @_bindings[eventName] is undefined
            @_bindings[eventName] = []

        # Add the callback to list for the event
        @_bindings[eventName].push(callback)

        return callback

    trigger: (eventName, args...) ->
        # Trigger an event against the node

        # Check we have callbacks to trigger for the event
        unless @_bindings[eventName]
            return

        # Call each function bound to the event
        for callback in @_bindings[eventName]
            if not callback
                continue
            callback.call(this, args...)

    unbind: (eventName, callback) ->
        # Unbind a callback from an event

        # If no eventName is specified remove all events
        unless eventName
            @_bindings = {}
            return

        # If no callback is specified remove all callbacks for the event
        unless callback
            @_bindings[eventName] = undefined
            return

        # Check if any callbacks are bound to this event
        unless @_bindings[eventName]
            return

        # Remove the callback from the event
        for suspect, i in @_bindings[eventName]
            if suspect is callback
                @_bindings[eventName].splice(i, 1)

    # Private methods

    _addDOMEventListeners: () ->
        # Add all event bindings for the DOM element in this method

    _removeDOMEventListeners: () ->
        # Remove all event bindings for the DOM element in this method

    @createDiv: (classNames, attributes, content) ->
        # All UI components are constructed entirely from one or more nested
        # <div>s, this class method provides a shortcut for creating a <div>
        # including the initial CSS class names, attributes and content.

        # Create the element
        domElement = document.createElement('div')

        # Add the specified CSS classes
        if classNames and classNames.length > 0
            domElement.setAttribute('class', classNames.join(' '))

        # Add the specified attributes
        if attributes
            for name, value of attributes
                domElement.setAttribute(name, value)

        if content
            domElement.innerHTML = content

        return domElement


class ContentTools.WidgetUI extends ContentTools.ComponentUI

    # The widget class provides a base class for components that render at the
    # root of the application.

    attach: (component, index) ->
        # Attach a component as a child of this component
        super(component, index)

        if not @isMounted()
            component.mount()

    detatch: (component) ->
        # Detach a child component from this component
        super(component)

        if @isMounted()
            component.unmount()

    show: () ->
        # Show the widget
        if not @isMounted()
            @mount()

        # We delay adding the --active modifier to ensure any CSS transition is
        # activated.
        fadeIn = () =>
            @addCSSClass('ct-widget--active')

        setTimeout(fadeIn, 100)

    hide: () ->
        # Hide the widget

        # Removing the --active modifier will attempt to trigger an CSS
        # transition to fade out the widget. Once the transition to 0 opacity
        # is complete we unmount it.
        @removeCSSClass('ct-widget--active')

        monitorForHidden = () =>

            # If there's no support for `getComputedStyle` then we fallback to
            # unmounting the widget immediately.
            unless window.getComputedStyle
                @unmount()
                return

            # If the widget is now hidden we unmount it
            if parseFloat(window.getComputedStyle(@_domElement).opacity) < 0.01
                @unmount()
            else
                setTimeout(monitorForHidden, 250)

        if @isMounted()
            setTimeout(monitorForHidden, 250)


class ContentTools.AnchoredComponentUI extends ContentTools.ComponentUI

    # Anchored components are mounted against a specified DOM element at a
    # specified anchor. Remounting an anchored component requires that the
    # parent perform the re-mount.
    #
    # The benefit of anchored components is they are light weight and can be
    # rendered into different a specific DOM element by the parent, for example
    # tools within the toolbox are anchored components.

    mount: (domParent, before=null) ->
        # Mount the component to the DOM (mount should be called by inheriting
        # classes after they've created their DOM element using `super`.

        # Mount the element
        domParent.insertBefore(@_domElement, before)

        # Add interaction handlers
        @_addDOMEventListeners()