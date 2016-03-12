class _EditorApp extends ContentTools.ComponentUI

    # The editor application

    constructor: () ->
        super()

        # Whenever the user starts to edit the page a new history stack is
        # created to provide undo/redo support.
        @history = null

        # The state of the app
        @_state = ContentTools.EditorApp.DORMANT

        # A map of editable regions (`ContentEdit.Region`) the editor will
        # manage.
        @_regions = null

        # A list of the mapped regions used to determine their order
        @_orderedRegions = null

        # The last modified dates for the root node and regions
        @_rootLastModified = null
        @_regionsLastModified = {}

        # The UI widgets that form the editor's interface
        @_ignition = null
        @_inspector = null
        @_toolbox = null

    # Read-only properties

    ctrlDown: () ->
        return @_ctrlDown

    domRegions: () ->
        # Return a list of DOM nodes that are assigned as be editable regions
        return @_domRegions

    orderedRegions: () ->
        # Return a list of regions in the given order
        return (@_regions[name] for name in @_orderedRegions)

    regions: () ->
        # Return a list of editable regions on the page
        return @_regions

    shiftDown: () ->
        return @_shiftDown

    getState: () ->
        # Returns the current state of the editor (see `ContentTools.EditorApp`
        # for information on possible editor states).
        return @_state

    isDormant: () ->
        # Return true if the editor is currently in the dormant state
        return @_state is ContentTools.EditorApp.DORMANT

    isReady: () ->
        # Return true if the editor is currently in the ready state
        return @_state is ContentTools.EditorApp.READY

    isEditing: () ->
        # Return true if the editor is currently in the editing state
        return @_state is ContentTools.EditorApp.EDITING

    # Methods

    busy: (busy) ->
        # Get/set the state of the editor (the state is actually held against
        # the ignition).
        return @_ignition.busy(busy)

    init: (queryOrDOMElements, namingProp='id') ->
        # Initialize the editor application

        # The property used to extract a name/key for a region
        @_namingProp = namingProp

        # Assign the DOM regions
        if queryOrDOMElements.length > 0 and
                queryOrDOMElements[0].nodeType is Node.ELEMENT_NODE
            # If a list has been provided then assume it contains a list of DOM
            # elements each of which is a region.
            @_domRegions = queryOrDOMElements
        else
            # If a CSS query has been specified then use that to select the
            # regions in the DOM.
            @_domRegions = document.querySelectorAll(queryOrDOMElements)

        # If there aren't any editiable regions return early leaving the app
        # DORMANT.
        if @_domRegions.length == 0
            return

        # Mount the element to the DOM
        @mount()

        # Set up the ignition switch for page editing
        @_ignition = new ContentTools.IgnitionUI()
        @attach(@_ignition)

        @_ignition.bind 'start', () =>
            @start()

        @_ignition.bind 'stop', (save) =>
            # HACK: We can't currently capture certain changes to text
            # elements (for example deletion of a section of text from the
            # context menu option). Long-term mutation observers or
            # consistent support for the `input` event against
            # `contenteditable` elements would resolve this.
            #
            # For now though we manually perform a content sync if an
            # element supporting that method has focus.
            focused = ContentEdit.Root.get().focused()
            if focused and focused.isMounted() and
                    focused._syncContent != undefined

                focused._syncContent()

            if save
                @save()
            else
                # If revert returns false then we cancel the stop action
                if not @revert()
                    # Reset the ignition state
                    @_ignition.changeState('editing')
                    return

            @stop()

        if @_domRegions.length
            @_ignition.show()

        # Toolbox
        @_toolbox = new ContentTools.ToolboxUI(ContentTools.DEFAULT_TOOLS)
        @attach(@_toolbox)

        # Inspector
        @_inspector = new ContentTools.InspectorUI()
        @attach(@_inspector)

        # Set as ready to edit
        @_state = ContentTools.EditorApp.READY

        # Check when elements are detached that the parent region is not empty
        ContentEdit.Root.get().bind 'detach', (element) =>
            @_preventEmptyRegions()

        # Monitor paste events so that we can pre-parse the content the user
        # wants to paste into the region.
        ContentEdit.Root.get().bind 'paste', (element, ev) =>
            @paste(element, ev.clipboardData)

        # Manage the transition between regions
        ContentEdit.Root.get().bind 'next-region', (region) =>

            # Is there a next region?
            regions = @orderedRegions()
            index = regions.indexOf(region)
            if index >= (regions.length - 1)
                return

            # Move to the next region
            region = regions[index + 1]

            # Is there a content element to move to?
            element = null
            for child in region.descendants()
                if child.content != undefined
                    element = child
                    break

            # If there is a content child move the selection to it else check
            # the next region.
            if element
                element.focus()
                element.selection(new ContentSelect.Range(0, 0))
                return

            ContentEdit.Root.get().trigger('next-region', region)

        ContentEdit.Root.get().bind 'previous-region', (region) =>

            # Is there a previous region?
            regions = @orderedRegions()
            index = regions.indexOf(region)
            if index <= 0
                return

            # Move to the previous region
            region = regions[index - 1]

            # Is there a content element to move to?
            element = null
            descendants = region.descendants()
            descendants.reverse()
            for child in descendants
                if child.content != undefined
                    element = child
                    break

            # If there is a content child move the selection to it else check
            # the next region.
            if element
                length = element.content.length()
                element.focus()
                element.selection(new ContentSelect.Range(length, length))
                return

            ContentEdit.Root.get().trigger('previous-region', region)


    destroy: () ->
        # Destroy the editor application
        @unmount()

    highlightRegions: (highlight) ->
        # Highlight (or stop highlighting) editiable regions within the page
        for domRegion in @_domRegions
            if highlight
                ContentEdit.addCSSClass(domRegion, 'ct--highlight')
            else
                ContentEdit.removeCSSClass(domRegion, 'ct--highlight')

    mount: () ->
        # Mount the widget to the DOM
        @_domElement = @constructor.createDiv(['ct-app'])
        document.body.insertBefore(@_domElement, null)
        @_addDOMEventListeners()

    paste: (element, clipboardData) ->
        # Paste content into the given element

        # Extract the content of the clipboard
        content = clipboardData.getData('text/plain')

        # Convert the content into a series of lines to be inserted
        lines = content.split('\n')

        # Filter out any blank (whitespace only) lines
        lines = lines.filter (line) ->
            return line.trim() != ''

        # Check there's something to paste
        if not lines
            return

        # If the content is more than one paragraph or if the selected element
        # doesn't support text create new elements for each line of content.
        encodeHTML = HTMLString.String.encode

        type = element.type()
        if (lines.length > 1 or not element.content) and type != 'PreText'

            # Find the insertion point in the document
            if type == 'ListItemText'
                # If the element is a ListItem then we want to insert the lines
                # as siblings.
                insertNode = element.parent()
                insertIn = element.parent().parent()
                insertAt = insertIn.children.indexOf(insertNode) + 1

            else
                # For any other element type we want to insert the lines as
                # paragraphs.
                insertNode = element
                if insertNode.parent().type() != 'Region'
                    insertNode = element.closest (node) ->
                        return node.parent().type() is 'Region'

                insertIn = insertNode.parent()
                insertAt = insertIn.children.indexOf(insertNode) + 1

            # Insert each line as a paragraph
            for line, i in lines
                line = encodeHTML(line)
                if type == 'ListItemText'
                    item = new ContentEdit.ListItem()
                    itemText = new ContentEdit.ListItemText(line)
                    item.attach(itemText)
                    lastItem = itemText

                else
                    item = new ContentEdit.Text('p', {}, line)
                    lastItem = item

                insertIn.attach(item, insertAt + i)

            # Give focus to the last line/paragraph added and position the
            # cursor at the end of it.
            lineLength = lastItem.content.length()
            lastItem.focus()
            lastItem.selection(new ContentSelect.Range(lineLength, lineLength))

        else
            # If the element supports content and we only have one line of
            # content then we insert the pasted text within the element's
            # existing content.

            # Convert the content to a HTMLString
            content = encodeHTML(content)
            content = new HTMLString.String(content, type is 'PreText')

            # Insert the content into the element's existing content
            selection = element.selection()
            cursor = selection.get()[0] + content.length()
            tip = element.content.substring(0, selection.get()[0])
            tail = element.content.substring(selection.get()[1])

            # Format the string using tags for the first character it is
            # replacing (if any).
            replaced = element.content.substring(
                selection.get()[0],
                selection.get()[1]
                )
            if replaced.length()
                character = replaced.characters[0]
                tags = character.tags()

                if character.isTag()
                    tags.shift()

                if tags.length >= 1
                    content = content.format(0, content.length(), tags...)

            element.content = tip.concat(content)
            element.content = element.content.concat(tail, false)
            element.updateInnerHTML()

            # Mark the element as tainted
            element.taint()

            # Restore the selection
            selection.set(cursor, cursor)
            element.selection(selection)

    unmount: () ->
        # Unmount the widget from the DOM

        # Check the editor is mounted
        if not @isMounted()
            return

        # Remove the DOM element
        @_domElement.parentNode.removeChild(@_domElement)
        @_domElement = null

        # Remove any DOM event bindings
        @_removeDOMEventListeners()

        # Reset child component handles
        @_ignition = null
        @_inspector = null
        @_toolbox = null

    # Page state methods

    revert: () ->
        # Revert the page to it's previous state before we started editing
        # the page.

        # Check if there are any changes, and if there are make the user confirm
        # they want to lose them.
        confirmMessage = ContentEdit._('Your changes have not been saved, do you really want to lose them?')
        if ContentEdit.Root.get().lastModified() > @_rootLastModified and
                not window.confirm(confirmMessage)
            return false

        # Revert the page to it's initial state
        @revertToSnapshot(@history.goTo(0), false)

        return true

    revertToSnapshot: (snapshot, restoreEditable=true) ->
        # Revert the page to the specified snapshot (the snapshot should be a
        # map of regions and the associated HTML).

        for name, region of @_regions
            # Apply the changes made to the DOM (affectively reseting the DOM to
            # a non-editable state).
            region.domElement().innerHTML = snapshot.regions[name]

        # Check to see if we need to restore the regions to an editable state
        if restoreEditable
            # Unset any focused element against root
            if ContentEdit.Root.get().focused()
                ContentEdit.Root.get().focused().blur()

            # Reset the regions map
            @_regions = {}

            # Convert each assigned node to an editable region
            for domRegion, i in @_domRegions
                name = domRegion.getAttribute(@_namingProp)
                if not name
                    name = i
                @_regions[name] = new ContentEdit.Region(domRegion)

            # Update history with the new regions
            @history.replaceRegions(@_regions)

            # Restore the selection for the snapshot
            @history.restoreSelection(snapshot)

            # Update the inspector tags
            @_inspector.updateTags()

    save: (passive, args...) ->
        # Save changes to the current page

        # Check the document has changed, if not we don't need do anything
        root = ContentEdit.Root.get()
        if root.lastModified() == @_rootLastModified and passive
            return

        # Build a map of the modified regions
        modifiedRegions = {}
        for name, region of @_regions
            # Check for regions that contain only a place holder
            html = region.html()
            if region.children.length == 1
                child = region.children[0]
                if child.content and not child.content.html()
                    html = ''

            # Apply the changes made to the DOM (affectively resetting the DOM
            # to a non-editable state).
            unless passive
                region.domElement().innerHTML = html

            # Check the region has been modified, if not we don't include it in
            # the output.
            if region.lastModified() == @_regionsLastModified[name]
                continue

            modifiedRegions[name] = html

            # Set the region back to not modified
            @_regionsLastModified[name] = region.lastModified()

        # Trigger the save event with a region HTML map for the changed
        # content.
        @trigger('save', modifiedRegions, args...)

    setRegionOrder: (regionNames) ->
        # Set the navigation order of regions on the page to the order set in
        # `regionNames`.
        @_orderedRegions = regionNames.slice()

    start: () ->
        # Start editing the page

        # Set the edtior to busy while we set up
        @busy(true)

        # Convert each assigned node to a region
        @_regions = {}
        @_orderedRegions = []
        for domRegion, i in @_domRegions
            name = domRegion.getAttribute(@_namingProp)
            if not name
                name = i
            @_regions[name] = new ContentEdit.Region(domRegion)
            @_orderedRegions.push(name)

            # Store the date at which the region was last modified so we can
            # check for changes on save.
            @_regionsLastModified[name] = @_regions[name].lastModified()

        # Ensure no region is empty
        @_preventEmptyRegions()

        # Store the date at which the root was last modified so we can check for
        # changes on save.
        @_rootLastModified = ContentEdit.Root.get().lastModified()

        # Create a new history instance to store the page changes against
        @history = new ContentTools.History(@_regions)
        @history.watch()

        # Set the application state to editing
        @_state = ContentTools.EditorApp.EDITING

        # Display the editing tools
        @_toolbox.show()
        @_inspector.show()

        @busy(false)

    stop: () ->
        # Stop editing the page.

        # Blur any existing focused element
        if ContentEdit.Root.get().focused()
            ContentEdit.Root.get().focused().blur()

        # Clear history
        @history.stopWatching()
        @history = null

        # Hide the editing tools
        @_toolbox.hide()
        @_inspector.hide()

        # Remove all regions
        @_regions = {}

        # Set the application state to ready to edit
        @_state = ContentTools.EditorApp.READY

    # Private methods

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # If the user holds the shift key down for a set period we highlight
        # editable regions on the page (for example by flashing them).
        #
        # In addition we monitor the Crtl/Meta and Shift key statuses so that
        # they can be tested independently of a ui event.
        @_handleHighlightOn = (ev) =>
            if ev.keyCode in [17, 224] # Ctrl/Cmd
                @_ctrlDown = true
                return

            if ev.keyCode is 16 # Shift
                # Check for repeating key in which case we don't want to create
                # additional timeouts.
                if @_highlightTimeout
                    return

                @_shiftDown = true
                @_highlightTimeout = setTimeout(
                    () => @highlightRegions(true),
                    ContentTools.HIGHLIGHT_HOLD_DURATION
                    )

        @_handleHighlightOff = (ev) =>
            # Ignore repeated key press events
            if ev.keyCode in [17, 224] # Ctrl/Cmd
                @_ctrlDown = false
                return

            if ev.keyCode is 16 # Shift
                @_shiftDown = false
                if @_highlightTimeout
                    clearTimeout(@_highlightTimeout)
                    @_highlightTimeout = null
                @highlightRegions(false)

        document.addEventListener('keydown', @_handleHighlightOn)
        document.addEventListener('keyup', @_handleHighlightOff)

        # When unloading the page we check to see if the user is currently
        # editing and if so ask them to confirm the action.
        window.onbeforeunload = (ev) =>
            if @_state is ContentTools.EditorApp.EDITING
                return ContentEdit._('Your changes have not been saved, do you really want to lose them?')

        # When the page is unloaded we destroy the app to make sure everything
        # is cleaned up.
        window.addEventListener 'unload', (ev) =>
            @destroy()

    _preventEmptyRegions: () ->
        # Ensure no region is empty by inserting a placeholder <p> tag if
        # required.

        # Check for any region that is now empty
        for name, region of @_regions

            # We have to check for elements that can receive focus as static
            # elements alone don't allow new content to be added to a region.
            hasEditableChildren = false
            for child in region.children
                if child.type() != 'Static'
                    hasEditableChildren = true
                    break

            if hasEditableChildren
                continue

            # Insert a placeholder text element to prevent the region from
            # becoming empty.
            placeholder = new ContentEdit.Text('p', {}, '')
            region.attach(placeholder)

            # This action will mark the region as modified which it technically
            # isn't and so we commit the change to nullify this.
            region.commit()

    _removeDOMEventListeners: () ->
        # Remove DOM event listeners for the widget

        # Highlight events
        document.removeEventListener('keydown', @_handleHighlightOn)
        document.removeEventListener('keyup', @_handleHighlightOff)


class ContentTools.EditorApp

    # The `ContentTools.EditorApp` class is a singleton, this code provides
    # access to the singleton instance of the protected `_EditorApp` class which
    # is initialized the first time the class method `get` is called.

    # Constants

    # A set of possible states for the editor.

    # An instance of the `_EditorApp` class exists but the `init` method has not
    # yet been called (the primary distinction here is that the editor has not
    # been mounted to the DOM).
    @DORMANT = 'dormant'

    # The editor has been mounted to the DOM and is ready (e.g the `start`
    # method can be called to begin editing the document).
    @READY = 'ready'

    # The editor is in the editing state allowing changes to be made to the
    # document.
    @EDITING = 'editing'

    # Storage for the singleton instance that will be created for the editor app
    instance = null

    @get: () ->
        cls = ContentTools.EditorApp.getCls()
        instance ?= new cls()

    @getCls: () ->
        return _EditorApp