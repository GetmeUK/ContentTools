class ContentTools.History

    # The `History` class provides a mechanism for storing, navigating and
    # reverting the changes made to an editable document.

    constructor: (regions) ->
        # The last time a snapshot was taken
        @_lastSnapshotTaken = null

        # The map of regions that changes will be stored for
        @_regions = {}
        @replaceRegions(regions)

        # Undo & Redo move restore the state of the document to a snapshot in
        # the historic stack. To keep track of the current position in the stack
        # we use `_snapshotIndex`.
        @_snapshotIndex = -1

        # A stack of historic snapshot for the document
        @_snapshots = []

        # Store the initial state of the document
        @_store()

    # Read-only properties

    canRedo: () ->
        # Return true if a redo can be performed
        return @_snapshotIndex < @_snapshots.length - 1

    canUndo: () ->
        # Return true if an undo can be performed
        return @_snapshotIndex > 0

    index: () ->
        # Return the snapshot index for the history stack
        return @_snapshotIndex

    length: () ->
        # The number of snapshots stored
        return @_snapshots.length

    snapshot: () ->
        # Return the current snapshot
        return @_snapshots[@_snapshotIndex]

    # Methods

    goTo: (index) ->
        # Move the head to a specific point in history
        @_snapshotIndex = Math.min((@_snapshots.length - 1), Math.max(0, index))
        return @snapshot()

    redo: () ->
        # Revert to the document to the next state in she stack
        return @goTo(@_snapshotIndex + 1)

    replaceRegions: (regions) ->
        # Replace the existing map of regions with a new set (this is commonly
        # called when a previous state has been restored).
        @_regions = {}
        for k, v of regions
            @_regions[k] = v

    restoreSelection: (snapshot) ->
        # Restore the selection for a snapshot

        # Check an element was selected
        if not snapshot.selected
            return

        # Find the selected element
        region = @_regions[snapshot.selected.region]
        element = region.descendants()[snapshot.selected.element]

        # Select the element and if applicable reset the selection
        element.focus()
        if element.selection and snapshot.selected.selection
            element.selection(snapshot.selected.selection)

    stopWatching: () ->
        # Stop watching the document for changes

        # Clear any related intervals/timeouts
        if @_watchInterval
            clearInterval(@_watchInterval)

        if @_delayedStoreTimeout
            clearTimeout(@_delayedStoreTimeout)

    undo: () ->
        # Revert the document to the previous state in the stack
        return @goTo(@_snapshotIndex - 1)

    watch: () ->
        # Watch the document for changes
        #
        # The watch process monitors the root element for changes by comparing
        # its last modified date with the last date a snapshot was taken, if the
        # 2 are not the same then it triggers the creation of snapshot.
        #
        # However to ensure we don't take snapshots whilst the user is still
        # active we wait for a period of inactivity before taking the snapshot
        # (as this is quite a time consuming process and could make the editor
        # feel laggy).

        @_lastSnapshotTaken = Date.now()

        watch = () =>
            lastModified = ContentEdit.Root.get().lastModified()

            # Check the document has actually been updated
            if lastModified is null
                return

            # Check if the document has been modified
            if lastModified > @_lastSnapshotTaken

                # If the document hasn't changed since we last checked do
                # nothing and exit
                if @_delayedStoreRequested == lastModified
                    return

                # Clear any existing delayed store request
                if @_delayedStoreTimeout
                    clearTimeout(@_delayedStoreTimeout)

                # Trigger a snapshot after a short delay of inactivity
                delayedStore = () =>
                    @_lastSnapshotTaken = lastModified
                    @_store()

                @_delayedStoreRequested = lastModified
                @_delayedStoreTimeout = setTimeout(delayedStore, 500)

        @_watchInterval = setInterval(watch, 50)

    # Private methods

    _store: () ->
        # Store the current state of the document

        # Take a snapshot
        snapshot = {
            regions: {},
            regionModifieds: {},
            rootModified: ContentEdit.Root.get().lastModified(),
            selected: null
            }

        # Store the HTML
        for name, region of @_regions
            snapshot.regions[name] = region.html()
            snapshot.regionModifieds[name] = region.lastModified()

        # Store any selection state information
        element = ContentEdit.Root.get().focused()

        if element
            snapshot.selected = {}

            # Determine the selected region
            region = element.closest (node) ->
                return node.type() is 'Region' or node.type() is 'Fixture'

            # Check a region can be found (this catches cases where the focused
            # element isn't attached to the region.
            if not region
                return

            for name, other_region of @_regions
                if region == other_region
                    snapshot.selected.region = name
                    break

            # Determine the collapsed index of the selected element
            snapshot.selected.element = region.descendants().indexOf(element)

            # Store the current selection (for elements that support it)
            if element.selection
                snapshot.selected.selection = element.selection()

        # If the index is not the last item in the stack then remove items after
        # it.
        if @_snapshotIndex < (@_snapshots.length - 1)
            @_snapshots = @_snapshots.slice(0, @_snapshotIndex + 1)

        @_snapshotIndex++
        @_snapshots.splice(@_snapshotIndex, 0, snapshot)