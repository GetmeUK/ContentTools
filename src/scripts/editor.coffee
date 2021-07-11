class _EditorApp extends ContentTools.ComponentUI

    # The editor application

    constructor: () ->
        super()

        # Whenever the user starts to edit the page a new history stack is
        # created to provide undo/redo support.
        @history = null

        # The state of the app
        @_state = 'dormant'

        # Flags indicating if the editor has been set to busy (typically whilst
        # the application waits for a response from a remote server).
        @_busy = false

        # The property used to store a region/fixtures name
        @_namingProp = null

        # The test to use to determine if region is a fixture (by default we
        # look for the data-fixture attribute).
        @_fixtureTest = (domElement) ->
            return domElement.hasAttribute('data-fixture')

        # The query (or set of DOM elements) that define the editable
        # regions/fixtures with the page.
        @_regionQuery = null

        # A list of DOM elements representing regions
        @_domRegions = null

        # A map of editable regions (`ContentEdit.Region/Fixture`) the editor
        # will manage.
        @_regions = {}

        # A list of the mapped regions used to determine their order
        @_orderedRegions = []

        # The last modified dates for the root node and regions
        @_rootLastModified = null
        @_regionsLastModified = {}

        # The UI widgets that form the editor's interface
        @_ignition = null
        @_inspector = null
        @_toolbox = null

        # Flag used to indicate that for a temporary period the editor should
        # allow empty regions to exist.
        @_emptyRegionsAllowed = false

    # Read-only properties

    ctrlDown: () ->
        return @_ctrlDown

    domRegions: () ->
        # Return a list of DOM nodes that are assigned as be editable regions
        return @_domRegions

    getState: () ->
        # Returns the current state of the editor (see `ContentTools.EditorApp`
        # for information on possible editor states).
        return @_state

    ignition: () ->
        # Return the ignition component for the editor
        return @_ignition

    inspector: () ->
        # Return the inspector component for the editor
        return @_inspector

    isDormant: () ->
        # Return true if the editor is currently in the dormant state
        return @_state is 'dormant'

    isReady: () ->
        # Return true if the editor is currently in the ready state
        return @_state is 'ready'

    isEditing: () ->
        # Return true if the editor is currently in the editing state
        return @_state is 'editing'

    orderedRegions: () ->
        # Return a list of regions in the given order
        return (@_regions[name] for name in @_orderedRegions)

    regions: () ->
        # Return a list of editable regions on the page
        return @_regions

    shiftDown: () ->
        return @_shiftDown

    toolbox: () ->
        # Return the toolbox component for the editor
        return @_toolbox

    # Methods

    busy: (busy) ->
        # Get/set the busy flag for the editor

        # Return the busy flag
        if busy == undefined
            return @_busy

        # Set the busy flag
        @_busy = busy

        # If the ignition exists set the busy flag for it also
        if @_ignition
            @_ignition.busy(busy)

    createPlaceholderElement: (region) ->
        # Return a placeholder element for the region (used to populate an empty
        # region).
        return new ContentEdit.Text('p', {}, '')

    init: (
            queryOrDOMElements,
            namingProp='id',
            fixtureTest=null,
            withIgnition=true
            ) ->

        # Initialize the editor application

        # Set the naming property
        @_namingProp = namingProp

        # If defined set the function used to test for fixtures
        if fixtureTest
            @_fixtureTest = fixtureTest

        # Mount the element to the DOM
        @mount()

        # Set up the ignition switch for page editing
        if withIgnition
            @_ignition = new ContentTools.IgnitionUI()
            @attach(@_ignition)

            # Set up events to allow the ignition switch to manage the editor
            # state.
            @_ignition.addEventListener 'edit', (ev) =>
                ev.preventDefault()

                # Start the editor and set the ignition switch to `editing`
                @start()
                @_ignition.state('editing')

            @_ignition.addEventListener 'confirm', (ev) =>
                ev.preventDefault()

                if @_ignition.state() != 'editing'
                    return

                # Stop the editor and request that changes are saved
                @_ignition.state('ready')
                @stop(true)

            @_ignition.addEventListener 'cancel', (ev) =>
                ev.preventDefault()

                if @_ignition.state() != 'editing'
                    return

                # Stop the editor and request that changes are reverted
                @stop(false)

                # Update the state of the ignition switch based on the outcome
                # of the stop action (e.g whether the revert was actioned or
                # cancelled).
                if this.isEditing()
                    @_ignition.state('editing')
                else
                    @_ignition.state('ready')

        # Toolbox
        @_toolbox = new ContentTools.ToolboxUI(ContentTools.DEFAULT_TOOLS)
        @attach(@_toolbox)

        # Inspector
        @_inspector = new ContentTools.InspectorUI()
        @attach(@_inspector)

        # Set as ready to edit
        @_state = 'ready'

        @_handleDetach = (element) =>
            @_preventEmptyRegions()

        @_handleClipboardPaste = (element, ev) =>
            # Get the clipboardData
            clipboardData = null

            # Non-IE browsers
            if ev.clipboardData
                if ev.clipboardData.getData('text/html') and
                        element.type() != 'PreText'
                    @pasteHTML(element, ev.clipboardData.getData('text/html'))
                else
                    @pasteText(element, ev.clipboardData.getData('text/plain'))

                return

            # IE browsers
            if window.clipboardData
                clipboardData = window.clipboardData.getData('TEXT')
                @pasteText(element, window.clipboardData.getData('TEXT'))

        @_handleNextRegionTransition = (region) =>
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

        @_handlePreviousRegionTransition = (region) =>
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

        # Check when elements are detached that the parent region is not empty
        ContentEdit.Root.get().bind('detach', @_handleDetach)

        # Monitor paste events so that we can pre-parse the content the user
        # wants to paste into the region.
        ContentEdit.Root.get().bind('paste', @_handleClipboardPaste)

        # Manage the transition between regions
        ContentEdit.Root.get().bind('next-region', @_handleNextRegionTransition)
        ContentEdit.Root.get().bind(
            'previous-region',
            @_handlePreviousRegionTransition
            )

        # Sync the page regions
        @syncRegions(queryOrDOMElements)

    destroy: () ->
        # Destroy the editor application

        # Remove any events bound to the ContentEdit Root
        ContentEdit.Root.get().unbind('detach', @_handleDetach)
        ContentEdit.Root.get().unbind('paste', @_handleClipboardPaste)
        ContentEdit.Root.get().unbind(
            'next-region',
            @_handleNextRegionTransition
            )
        ContentEdit.Root.get().unbind(
            'previous-region',
            @_handlePreviousRegionTransition
            )

        # Remove any event listeners attached to the editor
        @removeEventListener()

        # Unmount the editor
        @unmount()

        # Clear the list of children for the editor
        @_children = []

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

    unmount: () ->
        # Unmount the widget from the DOM

        # Check the editor is mounted
        if not @isMounted()
            return

        # Unmount all children
        for child in @_children
            child.unmount()

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

    pasteHTML: (element, content) ->
        # Paste HTML into/after the given element
        tagNames = ContentEdit.TagNames.get()

        # Clean the HTML
        sandbox = document.implementation.createHTMLDocument()
        wrapper = sandbox.createElement('div')
        wrapper.innerHTML = ContentTools.getHTMLCleaner().clean(content.trim())

        # Remove any undefined nodes or empty #text nodes
        childNodes = []
        for childNode in wrapper.childNodes
            unless childNode
                continue

            if childNode.nodeName.toLowerCase() == '#text'
                if childNode.textContent.trim() == ''
                    continue

            childNodes.push(childNode)

        unless childNodes.length
            return

        # Paste the HTML
        inlineTags = ContentTools.INLINE_TAGS.slice()
        inlineTags.push('#text')
        firstNode = childNodes[0].nodeName.toLowerCase()
        lastNode = childNodes[childNodes.length - 1].nodeName.toLowerCase()

        # Cater for a single line of HTML being pasted, or pasting into a
        # fixture.
        if element.isFixed() or (inlineTags.indexOf(firstNode) > -1 and
                inlineTags.indexOf(lastNode) > -1)

            # If we merging multiple block level elements into one we strip
            # HTML before doing so.
            #
            # HACK: This isn't the long term plan, where we're resolving here
            # is an issue where pasting multiple paragraphs into a fixture
            # causes issues because fixtures typically don't cater for block
            # level elements as children. Long term this needs to be improved
            # to cater for merging the text elements within to produce a
            # single text element (retaining the HTML tags) that can be pasted
            # into the fixture.
            #
            # ~ Anthony Blackshaw <ant@getme.co.uk>, 7 Jan 2018
            #
            if (inlineTags.indexOf(firstNode) > -1 and
                    inlineTags.indexOf(lastNode) > -1)
                content = new HTMLString.String(wrapper.innerHTML)

            else
                content = new HTMLString.String(
                    HTMLString.String.encode(wrapper.textContent)
                )

            # Check we can paste in to the selected element
            if element.content

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

                return

            else
                # Can't paste content into the selected element so update the
                # wrapper to contain a single paragraph.
                wrapper.innerHTML = '<p>' + content.html() + '</p>'

        # If the element isn't a text element find the nearest top level
        # node that we can insert the pasted content after.
        originalElement = element
        if element.parent().type() != 'Region'
            element = element.closest (node) ->
                return node.parent().type() is 'Region'

        region = element.parent()

        # If the content starts and ends with an inline tag then we need to
        # wrap it within a paragraph tag before inserting.

        if (inlineTags.indexOf(firstNode) > -1 and
                inlineTags.indexOf(lastNode) > -1)

            innerP = wrapper.createElement('p')
            while wrapper.childNodes.length > 0
                innerP.appendChild(wrapper.childNodes[0])
            wrapper.appendChild(innerP)

        i = 0
        newElement = originalElement
        for node in wrapper.childNodes
            unless node
                continue

            # Skip whitespace text elements
            if node.nodeName == '#text' and node.textContent.trim() == ''
                continue

            # Attempt to convert the node to a ContentEdit element
            elementCls = tagNames.match(node.nodeName)

            # We assume nodes that don't match an element are inline and so we
            # wrap then in a paragraph tag for insertion.
            if elementCls == ContentEdit.Static
                p = document.createElement('p')
                p.appendChild(node)
                node = p
                elementCls = ContentEdit.Text

            # Create the new element
            newElement = elementCls.fromDOMElement(node)

            # Insert the new element into the page
            region.attach(
                newElement,
                region.children.indexOf(element) + (1 + i)
            )

            i += 1

        # Focus on the last focusable element inserted
        if newElement.focus
            newElement.focus()

        else if newElement.nextSibling()
            newElement = newElement.nextSibling().previousWithTest (node) ->
                if node.focus
                    return node

            if newElement
                newElement.focus()

        else
            newElement = newElement.nextWithTest (node) ->
                if node.focus
                    return node

            if newElement
                newElement.focus()
            else
                originalElement.focus()

    pasteText: (element, content) ->
        # Paste text into/after the given element

        # Convert the content into a series of lines to be inserted
        if element.type() != 'PreText'
            lines = content.split('\n')
        else
            lines = [content]

        # Filter out any blank (whitespace only) lines
        lines = lines.filter (line) ->
            return line.trim() != ''

        # Check there's something to paste
        if not lines
            return

        # Determine whether the new content should be pasted into the existing
        # element or should spawn new elements for each line of content.
        encodeHTML = HTMLString.String.encode
        spawn = true
        type = element.type()

        # Are their multiple lines to add?
        if lines.length == 1
            spawn = false

        # Is this a pre-text element which supports multiline content?
        if type == 'PreText'
            spawn = false

        # Does the element itself allow content to be spawned from it?
        if not element.can('spawn')
            spawn = false

        if spawn
            # Paste the content as multiple elements

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
            # Paste the content within the existing element

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

    revert: () ->
        # Revert the page to it's previous state before we started editing
        # the page.
        if not @dispatchEvent(@createEvent('revert'))
            return

        # Check if there are any changes, and if there are make the user confirm
        # they want to lose them.
        if ContentTools.CANCEL_MESSAGE
            confirmMessage = ContentEdit._(ContentTools.CANCEL_MESSAGE)
            if ContentEdit.Root.get().lastModified() > @_rootLastModified and
                    not window.confirm(confirmMessage)
                return false

        # Revert the page to it's initial state
        @revertToSnapshot(@history.goTo(0), false)

        return true

    revertToSnapshot: (snapshot, restoreEditable=true) ->
        # Revert the page to the specified snapshot (the snapshot should be a
        # map of regions and the associated HTML).

        domRegions = []
        for name, region of @_regions
            # Apply the changes made to the DOM (affectively reseting the DOM to
            # a non-editable state).

            # Unmount all children
            for child in region.children
                child.unmount()

            # Handle fixtures vs. standard regions
            if snapshot.regions[name] != undefined
                if region.children.length is 1 and region.children[0].isFixed()
                    wrapper = @constructor.createDiv()
                    wrapper.innerHTML = snapshot.regions[name]
                    domRegions.push(wrapper.firstElementChild)
                    region.domElement().parentNode.replaceChild(
                        wrapper.firstElementChild,
                        region.domElement()
                        )
                else
                    domRegions.push(region.domElement())
                    region.domElement().innerHTML = snapshot.regions[name]
            else
                region.domElement().remove();
                delete @_regions[name]

        # Resync the DOM regions, this is required as fixture will replace the
        # existing DOM region element (regions wont).
        @_domRegions = domRegions

        # Check to see if we need to restore the regions to an editable state
        if restoreEditable
            # Unset any focused element against root
            if ContentEdit.Root.get().focused()
                ContentEdit.Root.get().focused().blur()

            # Reset the regions map
            @_regions = {}

            @syncRegions(null, true)

            # Restore timestamps
            ContentEdit.Root.get()._modified = snapshot.rootModified
            for name, region of @_regions
                if snapshot.regionModifieds[name]
                    region._modified = snapshot.regionModifieds[name]

            # Update history with the new regions
            @history.replaceRegions(@_regions)

            # Restore the selection for the snapshot
            @history.restoreSelection(snapshot)

            # Update the inspector tags
            @_inspector.updateTags()

    save: (passive) ->
        # Save changes to the current page
        if not @dispatchEvent(@createEvent('save', {passive: passive}))
            return

        # Blur any active element to ensure empty elements are not retained
        root = ContentEdit.Root.get()
        if root.focused() and not passive
            root.focused().blur()

        # Check the document has changed, if not we don't need do anything
        if root.lastModified() == @_rootLastModified and passive
            # Trigger the saved event early with no modified regions,
            @dispatchEvent(
                @createEvent('saved', {regions: {}, passive: passive})
                )
            return

        # Build a map of the modified regions
        domRegions = []
        modifiedRegions = {}
        for name, region of @_regions
            # Check for regions that contain only a place holder
            html = region.html()
            if region.children.length == 1 and not region.type() is 'Fixture'
                child = region.children[0]
                if child.content and not child.content.html()
                    html = ''

            # Apply the changes made to the DOM (affectively resetting the DOM
            # to a non-editable state).
            unless passive
                # Unmount all children
                for child in region.children
                    child.unmount()

                # Handle fixtures vs. standard regions
                if region.children.length is 1 and region.children[0].isFixed()
                    wrapper = @constructor.createDiv()
                    wrapper.innerHTML = html
                    domRegions.push(wrapper.firstElementChild)
                    region.domElement().parentNode.replaceChild(
                        wrapper.firstElementChild,
                        region.domElement()
                    )
                else
                    domRegions.push(region.domElement())
                    region.domElement().innerHTML = html

            # Check the region has been modified, if not we don't include it in
            # the output.
            if region.lastModified() == @_regionsLastModified[name]
                continue

            modifiedRegions[name] = html

            # Set the region back to not modified
            @_regionsLastModified[name] = region.lastModified()

        # Resync the DOM regions, this is required as fixture will replace the
        # existing DOM region element (regions wont).
        @_domRegions = domRegions

        # Trigger the saved event with a region HTML map for the changed
        # content.
        @dispatchEvent(
            @createEvent('saved', {regions: modifiedRegions, passive: passive})
        )

    setRegionOrder: (regionNames) ->
        # Set the navigation order of regions on the page to the order set in
        # `regionNames`.
        @_orderedRegions = regionNames.slice()

    start: () ->
        # Start editing the page
        if not @dispatchEvent(@createEvent('start'))
            return

        # Set the edtior to busy while we set up
        @busy(true)

        # Convert each assigned node to a region
        @syncRegions()
        @_initRegions()

        # Ensure no region is empty
        @_preventEmptyRegions()

        # Store the date at which the root was last modified so we can check for
        # changes on save.
        @_rootLastModified = ContentEdit.Root.get().lastModified()

        # Create a new history instance to store the page changes against
        @history = new ContentTools.History(@_regions)
        @history.watch()

        # Set the application state to editing
        @_state = 'editing'

        # Display the editing tools
        @_toolbox.show()
        @_inspector.show()

        @busy(false)

        @dispatchEvent(@createEvent('started'))

    stop: (save) ->
        # Stop editing the page
        if not @dispatchEvent(@createEvent('stop', {save: save}))
            return

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
                return

        # Clear history
        @history.stopWatching()
        @history = null

        # Hide the editing tools
        @_toolbox.hide()
        @_inspector.hide()

        # Remove all regions
        @_regions = {}

        # Set the application state to ready to edit
        @_state = 'ready'

        # Blur any existing focused element
        if ContentEdit.Root.get().focused()
            @_allowEmptyRegions () =>
                ContentEdit.Root.get().focused().blur()

        @dispatchEvent(@createEvent('stopped'))

    syncRegions: (regionQuery, restoring) ->
        # Sync the editor with the page in order to map out the regions/fixtures
        # that can be edited.

        # If a region query has been provided then set it
        if regionQuery
            @_regionQuery = regionQuery

        # Find the DOM elements that will be managed as regions/fixtures
        @_domRegions = []
        if @_regionQuery

            # If a string is provided attempt select the DOM regions using a CSS
            # selector.
            if typeof @_regionQuery == 'string' or
                    @_regionQuery instanceof String
                @_domRegions = document.querySelectorAll(@_regionQuery)

            # Otherwise assume a valid list of DOM elements has been provided
            else
                @_domRegions = @_regionQuery

        # If the editor is currently in the 'editing' state then live sync
        if @_state is 'editing'
            @_initRegions(restoring)
            @_preventEmptyRegions()

        if @_ignition
            if @_domRegions.length
                @_ignition.show()
            else
                @_ignition.hide()

    # Private methods

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # If the user holds the shift key down for a set period we highlight
        # editable regions on the page (for example by flashing them).
        #
        # In addition we monitor the Crtl/Meta and Shift key statuses so that
        # they can be tested independently of a ui event.
        @_handleHighlightOn = (ev) =>
            if ev.keyCode in [17, 224, 91, 93] # Ctrl/Cmd
                @_ctrlDown = true

            if ev.keyCode is 16 and not @_ctrlDown # Shift
                # Check for repeating key in which case we don't want to create
                # additional timeouts.
                if @_highlightTimeout
                    return

                @_shiftDown = true
                @_highlightTimeout = setTimeout(
                    () => @highlightRegions(true),
                    ContentTools.HIGHLIGHT_HOLD_DURATION
                    )
                return

            # Remove the highlight if any other key is pressed
            clearTimeout(@_highlightTimeout)
            @highlightRegions(false)

        @_handleHighlightOff = (ev) =>
            # Ignore repeated key press events
            if ev.keyCode in [17, 224, 91, 93] # Ctrl/Cmd
                @_ctrlDown = false
                return

            if ev.keyCode is 16 # Shift
                @_shiftDown = false
                if @_highlightTimeout
                    clearTimeout(@_highlightTimeout)
                    @_highlightTimeout = null
                @highlightRegions(false)

        @_handleVisibility = (ev) =>
            # If the document is hidden at any time remove the region
            # highlighting.
            if not document.hasFocus()
                clearTimeout(@_highlightTimeout)
                @highlightRegions(false)

        document.addEventListener('keydown', @_handleHighlightOn)
        document.addEventListener('keyup', @_handleHighlightOff)
        document.addEventListener('visibilitychange', @_handleVisibility)

        # When unloading the page we check to see if the user is currently
        # editing and if so ask them to confirm the action.
        @_handleBeforeUnload = (ev) =>
            if @_state is 'editing' and ContentTools.CANCEL_MESSAGE
                if @history and @history._snapshotIndex
                    cancelMessage = ContentEdit._(ContentTools.CANCEL_MESSAGE)
                    (ev or window.event).returnValue = cancelMessage
                    return cancelMessage

        window.addEventListener('beforeunload', @_handleBeforeUnload)

        # When the page is unloaded we destroy the app to make sure everything
        # is cleaned up.
        @_handleUnload = (ev) =>
            @destroy()

        window.addEventListener('unload', @_handleUnload)

    _allowEmptyRegions: (callback) ->
        # Execute a function while allowing empty regions (e.g disabling the
        # default `_preventEmptyRegions` behaviour).
        @_emptyRegionsAllowed = true
        callback()
        @_emptyRegionsAllowed = false

    _preventEmptyRegions: () ->
        # Ensure no region is empty by inserting a placeholder <p> tag if
        # required.
        if @_emptyRegionsAllowed
            return

        # Check for any region that is now empty
        for name, region of @_regions
            lastModified = region.lastModified()

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
            placeholder = @createPlaceholderElement(region)
            region.attach(placeholder)

            # HACK: This action will mark the region as modified which it
            # technically isn't and so we commit the change to nullify this.
            region._modified = lastModified

    _removeDOMEventListeners: () ->
        # Remove DOM event listeners for the widget

        # Highlight events
        document.removeEventListener('keydown', @_handleHighlightOn)
        document.removeEventListener('keyup', @_handleHighlightOff)

        # Unload events
        window.removeEventListener('beforeunload', @_handleBeforeUnload)
        window.removeEventListener('unload', @_handleUnload)

    _initRegions: (restoring=false) ->
        # Initialize DOM regions within the page

        found = {}
        domRegions = []
        @_orderedRegions = []
        for domRegion, i in @_domRegions

            # Find a name for the region
            name = domRegion.getAttribute(@_namingProp)

            # If we can't find a name assign the region a name based on its
            # position on the page.
            if not name
                name = i

            # Remember that we added a region/fixture with this name, those that
            # aren't found are removed.
            found[name] = true

            # Update the order
            @_orderedRegions.push(name)

            # Check if the region/fixture is already initialized, in which case
            # we're done.
            if @_regions[name] and @_regions[name].domElement() == domRegion
                continue

            # Initialize the new region/fixture
            if @_fixtureTest(domRegion)
                @_regions[name] = new ContentEdit.Fixture(domRegion)
            else
                @_regions[name] = new ContentEdit.Region(domRegion)
            domRegions.push(@_regions[name].domElement())

            # Store the date at which the region was last modified so we can
            # check for changes on save.
            if not restoring
                @_regionsLastModified[name] = @_regions[name].lastModified()

        # Resync the DOM regions, this is required as fixture will replace the
        # existing DOM region element (regions wont).
        @_domRegions = domRegions

        # Remove any regions no longer part of the page
        for name, region of @_regions

            # If the region exists
            if found[name]
                continue

            # Remove the region
            delete @_regions[name]
            delete @_regionsLastModified[name]
            index = @_orderedRegions.indexOf(name)
            if index > -1
                @_orderedRegions.splice(index, 1)


class ContentTools.EditorApp

    # The `ContentTools.EditorApp` class is a singleton, this code provides
    # access to the singleton instance of the protected `_EditorApp` class which
    # is initialized the first time the class method `get` is called.

    # Storage for the singleton instance that will be created for the editor app
    instance = null

    @get: () ->
        cls = ContentTools.EditorApp.getCls()
        instance ?= new cls()

    @getCls: () ->
        return _EditorApp
