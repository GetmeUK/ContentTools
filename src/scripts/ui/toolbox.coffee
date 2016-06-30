class ContentTools.ToolboxUI extends ContentTools.WidgetUI

    # The toolbox window provides a set of content editing tools to the user
    # (e.g make the selected text bold, insert an image, etc.) The toolbox is
    # also draggable so that the user can position as required whilst editing.

    constructor: (tools) ->
        super()

        # The tools that will populate the toolbox. The structure of the tools
        # parameter should be an list of lists, where the top level list
        # represents tool groups and the sub-lists are made up of a list of tool
        # names, for example:
        #
        # [
        #     ['bold', 'italic'],    # Tool group 1
        #     ['image']              # Tool group 2
        #     ...
        # ]
        @_tools = tools

        # Flag indicating if the toolbox is currently being dragged
        @_dragging = false

        # The offset of the cursor to the toolbox's position on the page at the
        # point we start dragging.
        @_draggingOffset = null

        # The DOM element relating to the toolbox's grip which allows the user
        # to drag the toolbox to any position on the page.
        @_domGrip = null

        # A map of tool UI components mounted to the toolbox
        @_toolUIs = {}

    # Read-only properties

    isDragging: () ->
        # Return true if the toolbox is currently being dragged
        return @_dragging

    # Methods

    hide: () ->
        # Hide the widget

        # We unbind events from the toolbox as soon as we start to hide it as we
        # don't want any interactions once the process of hiding the toolbox has
        # started.
        @_removeDOMEventListeners()

        super()

    mount: () ->
        # Mount the widget to the DOM

        # Toolbox
        @_domElement = @constructor.createDiv([
            'ct-widget',
            'ct-toolbox'
            ])
        @parent().domElement().appendChild(@_domElement)

        # Grip
        @_domGrip = @constructor.createDiv([
            'ct-toolbox__grip',
            'ct-grip'
            ])
        @_domElement.appendChild(@_domGrip)

        @_domGrip.appendChild(@constructor.createDiv(['ct-grip__bump']))
        @_domGrip.appendChild(@constructor.createDiv(['ct-grip__bump']))
        @_domGrip.appendChild(@constructor.createDiv(['ct-grip__bump']))

        # Tools
        @_domToolGroups = @constructor.createDiv(['ct-tool-groups'])
        @_domElement.appendChild(@_domToolGroups)
        @tools(@_tools)

        # Restore the position of the element (if there's a restore set)
        restore = window.localStorage.getItem('ct-toolbox-position')
        if restore and /^\d+,\d+$/.test(restore)
            position = (parseInt(coord) for coord in restore.split(','))
            @_domElement.style.left = "#{ position[0] }px"
            @_domElement.style.top = "#{ position[1] }px"

            # After restoring the position make sure the toolbox is still
            # visible in the window.
            @_contain()

        # Add interaction handlers
        @_addDOMEventListeners()

    tools: (tools) ->
        # Get/Set the tools that populate the toolbox
        if tools is undefined
            return @_tools

        # Set the tools
        @_tools = tools

        # Only attempt to mount the tools if the toolbox itself is mounted
        if not @isMounted()
            return

        # Clear existing tools
        for toolName, toolUI of @_toolUIs
            toolUI.unmount()
        @_toolUIs = {}

        # Remove tool groups
        while @_domToolGroups.lastChild
            @_domToolGroups.removeChild(@_domToolGroups.lastChild)

        # Add the tools
        for toolGroup, i in @_tools

            # Create a group for the tools
            domToolGroup = @constructor.createDiv(['ct-tool-group'])
            @_domToolGroups.appendChild(domToolGroup)

            # Create an associated ToolUI compontent for each tool in the group
            for toolName in toolGroup

                # Get the tool
                tool = ContentTools.ToolShelf.fetch(toolName)

                # Create an associated ToolUI component and add it to the
                # toolbox.
                @_toolUIs[toolName] = new ContentTools.ToolUI(tool)
                @_toolUIs[toolName].mount(domToolGroup)
                @_toolUIs[toolName].disabled(true)

                # Whenever the tool is applied we'll want to force an update
                @_toolUIs[toolName].addEventListener 'applied', () =>
                    @updateTools()

    updateTools: () ->
        # Refresh all tool UIs in the toolbox

        # Get the currently focused element and selection (if there is one)
        element = ContentEdit.Root.get().focused()
        selection = null
        if element and element.selection
            selection = element.selection()

        # Update the status of all tools
        for name, toolUI of @_toolUIs
            toolUI.update(element, selection)

    unmount: () ->
        # Unmount the widget from the DOM
        super()

        @_domGrip = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # Allow the toolbox to be dragged to a new location by the user
        @_domGrip.addEventListener('mousedown', @_onStartDragging)

        # Ensure that when the window is resized the toolbox remains in view
        @_handleResize = (ev) =>
            if @_resizeTimeout
                clearTimeout(@_resizeTimeout)

            containResize = () =>
                @_contain()

            @_resizeTimeout = setTimeout(containResize, 250)

        window.addEventListener('resize', @_handleResize)

        # Set up a timed event to update the status of each tool
        @_updateTools = () =>
            app = ContentTools.EditorApp.get()

            # Determine if the element, selection, or document history has
            # changed, if not then we don't need to update the tools.
            update = false

            # Check the selected element and selection are the same
            element = ContentEdit.Root.get().focused()

            selection = null
            if element == @_lastUpdateElement
                if element and element.selection
                    selection = element.selection()

                    # Check the selection hasn't changed
                    if @_lastUpdateSelection
                        if not selection.eq(@_lastUpdateSelection)
                            update = true
                    else
                        update = true

            else
                # Not the same element
                update = true

            # Check the documents history (if there is one)
            if app.history
                if @_lastUpdateHistoryLength != app.history.length()
                    update = true

                # Remember the history length for next update
                @_lastUpdateHistoryLength = app.history.length()

                if @_lastUpdateHistoryIndex != app.history.index()
                    update = true

                # Remember the history index for next update
                @_lastUpdateHistoryIndex = app.history.index()

            # Remember the element/section for next update
            @_lastUpdateElement = element
            @_lastUpdateSelection = selection

            # Only update the tools if we can detect something has changed
            if update
                for name, toolUI of @_toolUIs
                    toolUI.update(element, selection)

        @_updateToolsInterval = setInterval(@_updateTools, 100)

        # Capture top-level key events so that we can override common key
        # behaviour.
        @_handleKeyDown = (ev) =>

            # Keyboard events that apply only to non-text elements
            element = ContentEdit.Root.get().focused()
            if element and not element.content

                # Add support for deleting non-text elements using the `delete`
                # key.
                if ev.keyCode is 46
                    ev.preventDefault()

                    # Remove the element
                    return ContentTools.Tools.Remove.apply(element, null, () ->)

                # Add support for adding a new paragraph after non-text elements
                # using the `return` key.
                if ev.keyCode is 13
                    ev.preventDefault()

                    # Add a new paragraph element after the current element
                    Paragraph = ContentTools.Tools.Paragraph
                    return Paragraph.apply(element, null, () ->)

            # Undo/Redo key support
            #
            # Windows undo: Ctrl+z
            # Windows redo: Ctrl+y
            # -
            # Mac undo:     Cmd+z
            # Mac redo:     Shift+Cmd+z
            # -
            # Linux undo:   Ctrl+z
            # Linux redo:   Shift+Ctrl+z

            # Guess the OS
            version = navigator.appVersion
            os = 'linux'
            if version.indexOf('Mac') != -1
                os = 'mac'
            else if version.indexOf('Win') != -1
                os = 'windows'

            # Check for undo/redo command
            redo = false
            undo = false

            switch os
                when 'linux'
                    if ev.keyCode is 90 and ev.ctrlKey
                        redo = ev.shiftKey
                        undo = not redo

                when 'mac'
                    if ev.keyCode is 90 and ev.metaKey
                        redo = ev.shiftKey
                        undo = not redo

                when 'windows'
                    if ev.keyCode is 89 and ev.ctrlKey
                        redo = true
                    if ev.keyCode is 90 and ev.ctrlKey
                        undo = true

            # Perform undo/redo
            if undo and ContentTools.Tools.Undo.canApply(null, null)
                ContentTools.Tools.Undo.apply(null, null, () ->)

            if redo and ContentTools.Tools.Redo.canApply(null, null)
                ContentTools.Tools.Redo.apply(null, null, () ->)

        window.addEventListener('keydown', @_handleKeyDown)

    _contain: () ->
        # Ensure the toolbox is visible in the current window
        unless @isMounted()
            return

        rect = @_domElement.getBoundingClientRect()

        if rect.left + rect.width > window.innerWidth
            @_domElement.style.left = "#{ window.innerWidth - rect.width }px"

        if rect.top + rect.height > window.innerHeight
            @_domElement.style.top = "#{ window.innerHeight - rect.height }px"

        if rect.left < 0
            @_domElement.style.left = '0px'

        if rect.top < 0
            @_domElement.style.top = '0px'

        # Save the new position to local storage so we can restore it on
        # remount.
        rect = @_domElement.getBoundingClientRect()
        window.localStorage.setItem(
            'ct-toolbox-position',
            "#{ rect.left },#{ rect.top }"
            )

    _removeDOMEventListeners: () ->
        # Remove DOM event listeners for the widget

        # Remove mouse event handlers
        if @isMounted()
            @_domGrip.removeEventListener('mousedown', @_onStartDragging)

        # Remove key events
        window.removeEventListener('keydown', @_handleKeyDown)

        # Remove resize handler
        window.removeEventListener('resize', @_handleResize)

        # Remove timer for updating tools
        clearInterval(@_updateToolsInterval)

    # Dragging methods

    _onDrag: (ev) =>
        # User has dragged the toolbox to a new position

        # Prevent content selection while dragging elements
        ContentSelect.Range.unselectAll()

        # Reposition the toolbox
        @_domElement.style.left = "#{ ev.clientX - @_draggingOffset.x }px"
        @_domElement.style.top = "#{ ev.clientY - @_draggingOffset.y }px"

    _onStartDragging: (ev) =>
        # Start dragging the toolbox
        ev.preventDefault()

        if @isDragging()
            return

        # Flag that the toolbox is being dragged
        @_dragging = true
        @addCSSClass('ct-toolbox--dragging')

        # Calculate the offset of the cursor to the toolbox
        rect = @_domElement.getBoundingClientRect()
        @_draggingOffset = {
            x: ev.clientX - rect.left,
            y: ev.clientY - rect.top
            }

        # Setup dragging behaviour for the element
        document.addEventListener('mousemove', @_onDrag)
        document.addEventListener('mouseup', @_onStopDragging)

        # Add dragging class to the body (this class is defined in ContentEdit
        # it disabled content selection via CSS).
        ContentEdit.addCSSClass(document.body, 'ce--dragging')

    _onStopDragging: (ev) =>
        # User has finished dragging the toolbox to a new position
        unless @isDragging()
            return

        # Ensure the toolbox isn't outside the window
        @_contain()

        # Remove dragging behaviour
        document.removeEventListener('mousemove', @_onDrag)
        document.removeEventListener('mouseup', @_onStopDragging)

        # Reset the dragging offset
        @_draggingOffset = null

        # Flag that the toolbox is no longer being dragged
        @_dragging = false
        @removeCSSClass('ct-toolbox--dragging')

        # Remove dragging class from the body (this class is defined in
        # ContentEdit it disabled content selection via CSS).
        ContentEdit.removeCSSClass(document.body, 'ce--dragging')


class ContentTools.ToolUI extends ContentTools.AnchoredComponentUI

    # A tool that can be selected in the toolbox.

    constructor: (tool) ->
        super()

        # The tool associated with this UI tool
        @tool = tool

        # Flag indicating if the mouse button is down whilst the cursor is over
        # (and remains over) the tool.
        @_mouseDown = false

        # Flag indicating if the tools is disabled
        @_disabled = false

    # Methods

    apply: (element, selection) ->
        # Apply the tool UIs associated tool
        unless @tool.canApply(element, selection)
            return

        detail = {
            'element': element,
            'selection': selection
            }

        callback = (applied) =>
            if applied
                @dispatchEvent(@createEvent('applied', detail))

        if @dispatchEvent(@createEvent('apply', detail))
            @tool.apply(element, selection, callback)

    disabled: (disabledState) ->
        # Get/Set the disabled state of the tool

        # Return the current state if `disabledState` hasn't been provided
        if disabledState == undefined
            return @_disabled

        # Set the state
        if @_disabled == disabledState
            return

        # Set the disabled state
        @_disabled = disabledState

        if disabledState
            # Disable the tool
            @_mouseDown = false
            @addCSSClass('ct-tool--disabled')
            @removeCSSClass('ct-tool--applied')

        else
            # Enable the tool
            @removeCSSClass('ct-tool--disabled')

    mount: (domParent, before=null) ->
        # Mount the component to the DOM

        @_domElement = @constructor.createDiv([
            'ct-tool',
            "ct-tool--#{ @tool.icon }"
            ])

        # Add the tooltip
        @_domElement.setAttribute('data-ct-tooltip', ContentEdit._(@tool.label))

        super(domParent, before)

    update: (element, selection) ->
        # Update the state of the tool based on the current element and
        # selection.

        # Most elements are automatically disabled if there is no element
        # however some tools such as redo/undo don't require an element to be
        # applied.
        if @tool.requiresElement
            # If there's no element selected then the tool is disabled
            if not (element and element.isMounted())
                @disabled(true)
                return

        # Check if the tool can be applied
        if @tool.canApply(element, selection)
            @disabled(false)
        else
            @disabled(true)
            return

        # Check of the tool is already being applied
        if @tool.isApplied(element, selection)
            @addCSSClass('ct-tool--applied')
        else
            @removeCSSClass('ct-tool--applied')

    # Private methods

    _addDOMEventListeners: () =>
        # Add all event bindings for the DOM element in this method
        @_domElement.addEventListener('mousedown', @_onMouseDown)
        @_domElement.addEventListener('mouseleave', @_onMouseLeave)
        @_domElement.addEventListener('mouseup', @_onMouseUp)

    # It's important to note that the click event for tools is managed in order
    # to prevent focus being lost from an element because of a tool being
    # clicked. Native 'mousedown' events triggered have their defaults
    # prevented.

    _onMouseDown: (ev) =>
        # Flag that the mouse has been clicked down over the tool
        ev.preventDefault()

        # If the tool is disabled ignore this event
        if @disabled()
            return

        @_mouseDown = true
        @addCSSClass('ct-tool--down')

    _onMouseLeave: (ev) =>
        # Cursor has left the tool so remove flag indicating the mouse is down
        # over the tool.
        @_mouseDown = false
        @removeCSSClass('ct-tool--down')

    _onMouseUp: (ev) =>
        # If a click event has occured exectute the tool
        if @_mouseDown
            element = ContentEdit.Root.get().focused()

            # Most elements are automatically disabled if there is no element
            # however some tools such as redo/undo don't require an element to
            # be applied.
            if @tool.requiresElement
                unless element and element.isMounted()
                    return

            selection = null
            if element and element.selection
                selection = element.selection()

            @apply(element, selection)

        # Reset the mouse down flag
        @_mouseDown = false
        @removeCSSClass('ct-tool--down')