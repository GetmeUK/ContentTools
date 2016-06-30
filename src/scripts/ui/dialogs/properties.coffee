class ContentTools.PropertiesDialog extends ContentTools.DialogUI

    # A dialog to support editing an elements properties

    constructor: (@element)->
        super('Properties')

        # A list of AttributeUI instances representing the element's attributes
        @_attributeUIs = []

        # The currently focused attribute
        @_focusedAttributeUI = null

        # A list of StyleUI instances representing the element's styles
        @_styleUIs = []

        # Check the element to determine if the dialog should provide a code
        # editor.
        @_supportsCoding = @element.content
        if @element.type() in ['ListItem', 'TableCell']
            @_supportsCoding = true

    # Methods

    caption: (caption) ->
        # Get/Set the caption for the dialog
        if caption is undefined
            return @_caption

        # Replace any existing caption
        this._caption = caption
        @_domCaption.textContent = ContentEdit._(caption) +
            ": #{ @element.tagName() }"

    changedAttributes: () ->
        # Return a map of attributes set in the dialog (only attributes that
        # have changed - e.g been added, modified or removed). Attributes that
        # have been removed are assigned null value.

        attributes = {}
        changedAttributes = {}

        # Find new or modified attributes
        for attributeUI in @_attributeUIs
            name = attributeUI.name()
            value = attributeUI.value()

            # Ignore fields without a name (typically the last attribute)
            if name == ''
                continue

            attributes[name.toLowerCase()] = true
            if @element.attr(name) != value
                changedAttributes[name] = value

        # Find removed attributes
        restricted = ContentTools.getRestrictedAtributes(@element.tagName())
        for name, value of @element.attributes()
            if restricted and restricted.indexOf(name.toLowerCase()) != -1
                continue

            if attributes[name] == undefined
                changedAttributes[name] = null

        return changedAttributes

    changedStyles: () ->
        # Return a map of styles where the value flags if the style has been set
        # to applied or not (only styles that have changed - e.g been added or
        # removed - are included).

        styles = {}
        for styleUI in @_styleUIs

            # Only add the include styles that have changed
            cssClass = styleUI.style.cssClass()
            if @element.hasCSSClass(cssClass) != styleUI.applied()
                styles[cssClass] = styleUI.applied()

        return styles

    getElementInnerHTML: () ->
        # Return the inner HTML for the element
        if not @_supportsCoding
            return null

        # Cater for the content being stored in a top-level text element or a
        # wrapper class for a list item or table cell.
        if @element.content
            return @element.content.html()
        return @element.children[0].content.html()

    mount: () ->
        # Mount the widget
        super()

        # Update dialog class
        ContentEdit.addCSSClass(@_domElement, 'ct-properties-dialog')

        # Update view class
        ContentEdit.addCSSClass(@_domView, 'ct-properties-dialog__view')

        # The properties dialog supports a tab between styles and attributes, by
        # default it is opened with styles tab showing.

        # Styles
        @_domStyles = @constructor.createDiv(['ct-properties-dialog__styles'])
        @_domStyles.setAttribute(
            'data-ct-empty',
            ContentEdit._('No styles available for this tag')
            )
        @_domView.appendChild(@_domStyles)

        # Add the styles in the style palette for this element
        for style in ContentTools.StylePalette.styles(@element)
            styleUI = new StyleUI(
                style,
                @element.hasCSSClass(style.cssClass())
                )
            @_styleUIs.push(styleUI)
            styleUI.mount(@_domStyles)

        # Attributes
        @_domAttributes = @constructor.createDiv(
            ['ct-properties-dialog__attributes'])
        @_domView.appendChild(@_domAttributes)

        # Add the elements attributes
        restricted = ContentTools.getRestrictedAtributes(@element.tagName())
        attributes = @element.attributes()

        # Build a list of attribute names that we can sort alphabetically. We
        # sort the attributes on mounting the dialog but not when new attributes
        # are added (these are simply appended to the end of the list which is
        # less jarring for the user).
        attributeNames = []
        for name, value of attributes
            # Check that attribute isn't restricted
            if restricted and restricted.indexOf(name.toLowerCase()) != -1
                continue

            attributeNames.push(name)

        attributeNames.sort()

        # Create an assciated `attributeUI` instance for each attribute
        for name in attributeNames
            value = attributes[name]

            @_addAttributeUI(name, value)

        # Add an empty attribute to allow new attributes to be created
        @_addAttributeUI('', '')

        # Code
        @_domCode = @constructor.createDiv(['ct-properties-dialog__code'])
        @_domView.appendChild(@_domCode)

        # Add a textarea in which the inner HTML can be edited
        @_domInnerHTML = document.createElement('textarea')
        @_domInnerHTML.setAttribute('class', 'ct-properties-dialog__inner-html')
        @_domInnerHTML.setAttribute('name', 'code')
        @_domInnerHTML.value = @getElementInnerHTML()
        @_domCode.appendChild(@_domInnerHTML)

        # Controls

        # Tabs
        domTabs = @constructor.createDiv(
            ['ct-control-group', 'ct-control-group--left'])
        @_domControls.appendChild(domTabs)

        # Styles
        @_domStylesTab = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--styles'
            ])
        @_domStylesTab.setAttribute('data-ct-tooltip', ContentEdit._('Styles'))
        domTabs.appendChild(@_domStylesTab)

        # Attributes
        @_domAttributesTab = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--attributes'
            ])
        @_domAttributesTab.setAttribute(
            'data-ct-tooltip',
            ContentEdit._('Attributes')
            )
        domTabs.appendChild(@_domAttributesTab)

        # Code
        @_domCodeTab = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--code'
            ])
        @_domCodeTab.setAttribute('data-ct-tooltip', ContentEdit._('Code'))
        domTabs.appendChild(@_domCodeTab)

        unless @_supportsCoding
            ContentEdit.addCSSClass(@_domCodeTab, 'ct-control--muted')

        # Remove attribute control
        @_domRemoveAttribute = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--remove',
            'ct-control--muted'
            ])
        @_domRemoveAttribute.setAttribute(
            'data-ct-tooltip',
            ContentEdit._('Remove')
            )
        domTabs.appendChild(@_domRemoveAttribute)

        # Actions
        domActions = @constructor.createDiv(
            ['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domActions)

        @_domApply = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--apply'
            ])
        @_domApply.textContent = ContentEdit._('Apply')
        domActions.appendChild(@_domApply)

        # Check to see which tab was last active and restore it (defaults to the
        # styles tab).
        lastTab = window.localStorage.getItem('ct-properties-dialog-tab')
        if lastTab == 'attributes'
            ContentEdit.addCSSClass(@_domElement,
                'ct-properties-dialog--attributes')
            ContentEdit.addCSSClass(@_domAttributesTab, 'ct-control--active')
        else if lastTab == 'code' and @_supportsCoding
            ContentEdit.addCSSClass(@_domElement,
                'ct-properties-dialog--code')
            ContentEdit.addCSSClass(@_domCodeTab, 'ct-control--active')
        else
            # Default to styles
            ContentEdit.addCSSClass(@_domElement,
                'ct-properties-dialog--styles')
            ContentEdit.addCSSClass(@_domStylesTab, 'ct-control--active')

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the properties. The event trigged by saving the properties
        # receives 3 values:
        #
        # - attributes (map of attributes and their values, attributes with null
        #   values have been removed).
        # - styles (map of styles that have changed and whether they are applied
        #   or not).
        # - innerHTML (the inner HTML for the element).

        innerHTML = null
        if @_supportsCoding
            innerHTML = @_domInnerHTML.value

        detail = {
            changedAttributes: @changedAttributes(),
            changedStyles: @changedStyles(),
            innerHTML: innerHTML
            }
        @dispatchEvent(@createEvent('save', detail))

    # Private methods

    _addAttributeUI: (name, value) ->
        # Add an AttributeUI widget to the attributes tab, this method also
        # binds the required events to each attribute.
        dialog = this

        # Create the attribute widget
        attributeUI = new AttributeUI(name, value)
        @_attributeUIs.push(attributeUI)

        # Handle blur events
        attributeUI.addEventListener 'blur', (ev) ->

            # Mark that no attribute currently has focus
            dialog._focusedAttributeUI = null

            # Disable the remove attribute control
            ContentEdit.addCSSClass(
                dialog._domRemoveAttribute,
                'ct-control--muted'
                )

            # If the attribute has no name and isn't the last attribute remove
            # it.
            index = dialog._attributeUIs.indexOf(this)
            length = dialog._attributeUIs.length
            if @name() is '' and index < (length - 1)
                @unmount()
                dialog._attributeUIs.splice(index, 1)

            # Check that the last attribute has no name or value, else we need
            # to create a new empty attribute.
            lastAttributeUI = dialog._attributeUIs[length - 1]
            if lastAttributeUI
                if lastAttributeUI.name() and lastAttributeUI.value()
                    dialog._addAttributeUI('', '')

        # Handle focus events
        attributeUI.addEventListener 'focus', (ev) ->
            # Mark that this is the attribute that currently has focus
            dialog._focusedAttributeUI = this

            # Enable the remove attribute control
            ContentEdit.removeCSSClass(
                dialog._domRemoveAttribute,
                'ct-control--muted'
                )

        # Handle input events
        attributeUI.addEventListener 'namechange', (ev) ->
            element = dialog.element
            name = @name().toLowerCase()
            restricted = ContentTools.getRestrictedAtributes(element.tagName())

            # Validate the name
            valid = true

            # Validate the name isn't restricted
            if restricted and restricted.indexOf(name) != -1
                valid = false

            # Validate the name isn't duplicated
            for otherAttributeUI in dialog._attributeUIs

                # Empty names don't count as duplicates
                if name == ''
                    continue

                if otherAttributeUI == this
                    continue

                if otherAttributeUI.name().toLowerCase() != name
                    continue

                valid = false

            # Set the AttributeUI's valid status
            @valid(valid)

            # Set the state of the apply control based on whether the attribute
            # is valid.
            if valid
                ContentEdit.removeCSSClass(
                    dialog._domApply,
                    'ct-control--muted'
                    )
            else
                ContentEdit.addCSSClass(dialog._domApply, 'ct-control--muted')

        # Mount the attribute widget
        attributeUI.mount(@_domAttributes)

        return attributeUI

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget
        super()

        # Add support for tabbing between styles and attributes

        selectTab = (selected) =>
            # Select a tab from the interface
            tabs = ['attributes', 'code', 'styles']

            # Unselect existing tab
            for tab in tabs
                if tab == selected
                    continue
                tabCap = tab.charAt(0).toUpperCase() + tab.slice(1)
                ContentEdit.removeCSSClass(@_domElement,
                    "ct-properties-dialog--#{ tab }")
                ContentEdit.removeCSSClass(
                    @["_dom#{ tabCap }Tab"],
                    'ct-control--active'
                    )

            # Select the tab
            selectedCap = selected.charAt(0).toUpperCase() + selected.slice(1)
            ContentEdit.addCSSClass(@_domElement,
                "ct-properties-dialog--#{ selected }")
            ContentEdit.addCSSClass(
                @["_dom#{ selectedCap }Tab"],
                'ct-control--active'
                )

            # Remember this tab was last open
            window.localStorage.setItem('ct-properties-dialog-tab', selected)

        # Styles
        @_domStylesTab.addEventListener 'mousedown', () =>
            selectTab('styles')

        # Attributes
        @_domAttributesTab.addEventListener 'mousedown', () =>
            selectTab('attributes')

        # Code
        if @_supportsCoding
            @_domCodeTab.addEventListener 'mousedown', () =>
                selectTab('code')

        # Remove attribute
        @_domRemoveAttribute.addEventListener 'mousedown', (ev) =>
            ev.preventDefault()

            if @_focusedAttributeUI

                # Determine if this is the last attribute in the list
                index = @_attributeUIs.indexOf(@_focusedAttributeUI)
                last = index == (@_attributeUIs.length - 1)

                # Remove the AttributeUI widget
                @_focusedAttributeUI.unmount()
                @_attributeUIs.splice(index, 1)

                # If this was the last item make sure we add a new empty one
                if last
                    @_addAttributeUI('', '')

        # Real-time validate any inline code changes
        validateCode = (ev) =>
            # Validate the content
            try
                content = new HTMLString.String(@_domInnerHTML.value)
                ContentEdit.removeCSSClass(
                    @_domInnerHTML,
                    'ct-properties-dialog__inner-html--invalid'
                    )
                ContentEdit.removeCSSClass(@_domApply, 'ct-control--muted')
            catch
                # If the content is invalid we change the style of the textarea
                # to reflect this state and disable the apply button.
                ContentEdit.addCSSClass(
                    @_domInnerHTML,
                    'ct-properties-dialog__inner-html--invalid'
                    )
                ContentEdit.addCSSClass(@_domApply, 'ct-control--muted')

        @_domInnerHTML.addEventListener('input', validateCode)
        @_domInnerHTML.addEventListener('propertychange', validateCode)

        # Apply
        @_domApply.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check the control isn't muted, if it is then one or more
            # attributes aren't valid.
            cssClass = @_domApply.getAttribute('class')
            if cssClass.indexOf('ct-control--muted') == -1
                @save()


class StyleUI extends ContentTools.AnchoredComponentUI

    # A switch representing a predefined style that can be applied to an
    # element with this tag name.

    constructor: (@style, applied) ->
        super()

        @_applied = applied

    # Methods

    applied: (applied) ->
        # Get/Set the applied flag for the style
        if applied is undefined
            return @_applied

        # If the value is the same there's nothing to do
        if @_applied is applied
            return

        @_applied = applied

        # Update the section class to reflect the applied value
        if @_applied
            ContentEdit.addCSSClass(@_domElement, 'ct-section--applied')
        else
            ContentEdit.removeCSSClass(@_domElement, 'ct-section--applied')

    mount: (domParent, before=null) ->
        # Mount the component to the DOM

        # Section
        @_domElement = @constructor.createDiv(['ct-section'])
        if @_applied
            ContentEdit.addCSSClass(@_domElement, 'ct-section--applied')

        # Label
        label = @constructor.createDiv(['ct-section__label'])
        label.textContent = @style.name()
        @_domElement.appendChild(label)

        # Switch
        @_domElement.appendChild(@constructor.createDiv(['ct-section__switch']))

        super(domParent, before)

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        toggleSection = (ev) =>
            ev.preventDefault()
            if @applied()
                @applied(false)
            else
                @applied(true)

        @_domElement.addEventListener 'click', toggleSection


class AttributeUI extends ContentTools.AnchoredComponentUI

    # An component that allows an attribute to be named and given a value given
    # or to be removed.

    constructor: (name, value) ->
        super()

        @_initialName = name
        @_initialValue = value

    # Read-only properties

    name: () ->
        # Return the name value of the attribute
        return @_domName.value.trim()

    value: () ->
        # Return the value of the attribute
        return @_domValue.value.trim()

    # Methods

    mount: (domParent, before=null) ->
        # Mount the component to the DOM

        # Attribute
        @_domElement = @constructor.createDiv(['ct-attribute'])

        # Name
        @_domName = document.createElement('input')
        @_domName.setAttribute('class', 'ct-attribute__name')
        @_domName.setAttribute('name', 'name')
        @_domName.setAttribute('placeholder', ContentEdit._('Name'))
        @_domName.setAttribute('type', 'text')
        @_domName.setAttribute('value', @_initialName)
        @_domElement.appendChild(@_domName)

        # Value
        @_domValue = document.createElement('input')
        @_domValue.setAttribute('class', 'ct-attribute__value')
        @_domValue.setAttribute('name', 'value')
        @_domValue.setAttribute('placeholder', ContentEdit._('Value'))
        @_domValue.setAttribute('type', 'text')
        @_domValue.setAttribute('value', @_initialValue)
        @_domElement.appendChild(@_domValue)

        super(domParent, before)

    valid: (valid) ->
        # Set the state of the attributes name input to valid or invalid
        if valid
            ContentEdit.removeCSSClass(
                @_domName,
                'ct-attribute__name--invalid'
                )
        else
            ContentEdit.addCSSClass(@_domName, 'ct-attribute__name--invalid')

    # Private methods

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # Name
        @_domName.addEventListener 'blur', () =>
            # Find the next attribute so we can move the focus if the attribute
            # is removed when blurred.
            name = @name()
            nextDomAttribute = @_domElement.nextSibling

            @dispatchEvent(@createEvent('blur'))

            # Determine if the next DOM element is an attribute
            if name is '' and nextDomAttribute
                # Move focus to next attribute
                nextNameDom = nextDomAttribute.querySelector(
                    '.ct-attribute__name')
                nextNameDom.focus()

        @_domName.addEventListener 'focus', () =>
            @dispatchEvent(@createEvent('focus'))

        @_domName.addEventListener 'input', () =>
            @dispatchEvent(@createEvent('namechange'))

        @_domName.addEventListener 'keydown', (ev) =>
            if ev.keyCode is 13
                @_domValue.focus()

        # Value
        @_domValue.addEventListener 'blur', () =>
            @dispatchEvent(@createEvent('blur'))

        @_domValue.addEventListener 'focus', () =>
            @dispatchEvent(@createEvent('focus'))

        @_domValue.addEventListener 'keydown', (ev) =>
            if ev.keyCode != 13 and (ev.keyCode != 9 or ev.shiftKey)
                return

            # Prevent the default shift of focus on the tab key
            ev.preventDefault()

            # Determine if the next DOM element is an attribute
            nextDomAttribute = @_domElement.nextSibling
            if not nextDomAttribute
                # No more attributes, just blur the value field
                @_domValue.blur()

                # If blurring the field created a new attribute then move the
                # focus to that element.
                nextDomAttribute = @_domElement.nextSibling

            if nextDomAttribute
                # Move focus to next attribute
                nextNameDom = nextDomAttribute.querySelector(
                    '.ct-attribute__name')
                nextNameDom.focus()