class ContentTools.InspectorUI extends ContentTools.WidgetUI

    # The inspector provides a breadcrumb style navigation tool for the
    # currently selected element in the document and it's chain of parent
    # elements.

    constructor: () ->
        super()

        # A list of TagUI elements displayed in the inspector
        @_tagUIs = []

    mount: () ->
        # Mount the widget to the DOM

        # Inspector
        @_domElement = @constructor.createDiv(['ct-widget', 'ct-inspector'])
        @parent().domElement().appendChild(@_domElement)

        # Tags
        @_domTags = @constructor.createDiv([
            'ct-inspector__tags',
            'ct-tags'
            ])
        @_domElement.appendChild(@_domTags)

        # Counter
        @_domCounter = @constructor.createDiv(['ct-inspector__counter'])
        @_domElement.appendChild(@_domCounter)
        @updateCounter()

        # Add interaction handlers
        @_addDOMEventListeners()

        # Listen for changes in focus at which point we need to update the tool
        @_handleFocusChange = () =>
            @updateTags()

        ContentEdit.Root.get().bind('blur', @_handleFocusChange)
        ContentEdit.Root.get().bind('focus', @_handleFocusChange)

        # We use mount here to catch instances where the tag name is changed, in
        # which case the focus wont be affected but the element will be
        # remounted in the DOM.
        ContentEdit.Root.get().bind('mount', @_handleFocusChange)

    unmount: () ->
        # Unmount the widget from the DOM
        super()

        @_domTags = null

        # Remove listeners for the inspector
        ContentEdit.Root.get().unbind('blur', @_handleFocusChange)
        ContentEdit.Root.get().unbind('focus', @_handleFocusChange)
        ContentEdit.Root.get().unbind('mount', @_handleFocusChange)

    updateCounter: () ->
        # Update the counter displaying the number of words in the editable
        # regions and the line/column for the cursor if within a preformatted
        # text block.

        # The method used to count words is from
        # Countable - https://sacha.me/Countable/ and
        # https://github.com/RadLikeWhoa/Countable/.
        #
        # The formatting of the counts to thousands is from StackOverflow:
        # http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript

        unless @isMounted()
            return

        # Word count
        completeText = ''
        for region in ContentTools.EditorApp.get().orderedRegions()

            # If one of the regions returned is undefined we ignore it, this can
            # happen if the regions are modified during an update but the
            # effects are harmless.
            unless region
                continue

            completeText += region.domElement().textContent

        completeText = completeText.trim()

        # Strip tags
        completeText = completeText.replace(/<\/?[a-z][^>]*>/gi, '')

        # Strip zero-width spaces
        completeText = completeText.replace(/[\u200B]+/, '')

        # Strip other irrelevant characters
        completeText = completeText.replace(/['";:,.?¿\-!¡]+/g, '')

        # Count the words
        word_count = (completeText.match(/\S+/g) or []).length

        # Format the count to use commas for thousands
        word_count = word_count.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')

        # We only display line/column if the currently focused element is a
        # preformatted text block.
        element = ContentEdit.Root.get().focused()
        unless element and
                element.type() == 'PreText' and
                element.selection().isCollapsed()
            @_domCounter.textContent = word_count
            return

        # Line/Column
        line = 0
        column = 1

        # Find the selected line, column
        sub = element.content.substring(0, element.selection().get()[0])
        lines = sub.text().split('\n')
        line = lines.length
        column = lines[lines.length - 1].length + 1

        # Format the line and column
        line = line.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
        column = column.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')

        @_domCounter.textContent = "#{word_count} / #{line}:#{column}"

    updateTags: () ->
        # Update the tags based on the current selection
        element = ContentEdit.Root.get().focused()

        # Clear the current list of tags
        for tag in @_tagUIs
            tag.unmount()

        @_tagUIs = []

        # If there's no element selected we're done
        if not element
            return

        # Get a list of parent elements for the currently selected element
        elements = element.parents()
        elements.reverse()
        elements.push(element)

        for element in elements

            # Certain tags are ignored as attributes cannot be safely set
            # against them.
            if ContentTools.INSPECTOR_IGNORED_ELEMENTS.indexOf(
                    element.type()) != -1
                continue

            if element.isFixed()
                continue

            # Convert each element to a UI tag
            tag = new ContentTools.TagUI(element)
            @_tagUIs.push(tag)
            tag.mount(@_domTags)

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # Update the counter every 4 times a second
        @_updateCounterInterval = setInterval(
            () => @updateCounter(),
            250
            )

    _removeDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # Clear the counter update
        clearInterval(@_updateCounterInterval)


class ContentTools.TagUI extends ContentTools.AnchoredComponentUI

    # A tag displayed in the inspector representing the selected element or one
    # of it's parents.

    constructor: (@element) ->
        super()

    # Methods

    mount: (domParent, before=null) ->
        # Mount the component to the DOM

        @_domElement = @constructor.createDiv(['ct-tag'])
        @_domElement.textContent = @element.tagName()

        super(domParent, before)

    # Private methods

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget
        @_domElement.addEventListener('mousedown', @_onMouseDown)

    _onMouseDown: (ev) =>
        # Open a properties dialog for the associated element

        # We don't want to lose selected elements focus so prevent the event's
        # default behaviour.
        ev.preventDefault()

        # If supported allow store the state for restoring once the dialog is
        # cancelled.
        if @element.storeState
            @element.storeState()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI()

        # Dialog
        dialog = new ContentTools.PropertiesDialog(@element)

        # Support cancelling the dialog
        dialog.addEventListener 'cancel', () =>
            modal.hide()
            dialog.hide()

            if @element.restoreState
                @element.restoreState()

        # Support saving the dialog
        dialog.addEventListener 'save', (ev) =>
            detail = ev.detail()
            attributes = detail.changedAttributes
            styles = detail.changedStyles
            innerHTML = detail.innerHTML

            # Apply the attribute changes
            for name, value of attributes

                # The `class` attribute has to be handled differently from other
                # attributes as CSS classes should only be set using the
                # add/removeCSSClass methods.
                if name == 'class'

                    # If the value is null (marked for remove) default it to an
                    # empty string so all classes will be safely removed.
                    if value == null
                        value = ''

                    # Apply any new classes (and build a map of all classes for
                    # the element so we know which ones, if any, to remove).
                    classNames = {}
                    for className in value.split(' ')
                        className = className.trim()

                        if not className
                            continue

                        classNames[className] = true

                        # If the element doesn't have the class add it
                        if not @element.hasCSSClass(className)
                            @element.addCSSClass(className)

                    # Remove any classes no longer present
                    for className in @element.attr('class').split(' ')
                        className = className.trim()

                        # If the class is no longer assocated with the element
                        # remove it.
                        if classNames[className] == undefined
                            @element.removeCSSClass(className)

                else
                    if value == null
                        @element.removeAttr(name)
                    else
                        @element.attr(name, value)

            # Apply the style changes
            for cssClass, applied of styles
                if applied
                    @element.addCSSClass(cssClass)
                else
                    @element.removeCSSClass(cssClass)

            # Apply any inner HTML changes
            unless innerHTML is null

                # Check there has been a change
                if innerHTML != dialog.getElementInnerHTML()

                    # Update the elements inner HTML
                    element = @element
                    unless element.content
                        element = element.children[0]

                    element.content = new HTMLString.String(
                        innerHTML,
                        element.content.preserveWhitespace()
                        )
                    element.updateInnerHTML()
                    element.taint()

                    # If we've changed the inner HTML just place the caret at
                    # the start of the selection.
                    element.selection(new ContentSelect.Range(0, 0))
                    element.storeState()

            modal.hide()
            dialog.hide()

            # Restore any previous state
            if @element.restoreState
                @element.restoreState()

        # Show the dialog
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()