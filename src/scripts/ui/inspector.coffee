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

            # Convert each element to a UI tag
            tag = new ContentTools.TagUI(element)
            @_tagUIs.push(tag)
            tag.mount(@_domTags)


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
        dialog.bind 'cancel', () =>
            dialog.unbind('cancel')

            modal.hide()
            dialog.hide()

            if @element.restoreState
                @element.restoreState()

        # Support saving the dialog
        dialog.bind 'save', (attributes, styles, innerHTML) =>
            dialog.unbind('save')

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