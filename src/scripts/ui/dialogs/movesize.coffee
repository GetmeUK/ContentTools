class ContentTools.MoveSizeDialog extends ContentTools.AnchoredDialogUI

    # An anchored dialog to support moving and sizing elements.
    # Avoids interfering with copy/paste operations on touch devices.

    constructor: (element) ->
        super()

        # The element to move/resize
        @_moveSizeElement = element

        @position(@_getCurrentPosition())

    mount: () ->
        # Mount the widget
        super()

        # Only show size inputs for resizeable elements
        if @_moveSizeElement instanceof ContentEdit.ResizableElement and @_moveSizeElement.can('resize')
            size = @_moveSizeElement.size();
            ContentEdit.addCSSClass(@_domElement, 'ct-anchored-dialog__move-size-buttons')
        else
            ContentEdit.addCSSClass(@_domElement, 'ct-anchored-dialog__move-buttons')

        # Reposition the dialog since the applied class has changed its size
        @position(@_getCurrentPosition())

        # Create the movement buttons
        @_domMoveUpLeftButton = @constructor.createDiv([
            'ct-anchored-dialog__button',
            'ct-anchored-dialog__move-up-left-button',
            ])
        @_domElementInner.appendChild(@_domMoveUpLeftButton)

        @_domMoveUpButton = @constructor.createDiv([
            'ct-anchored-dialog__button',
            'ct-anchored-dialog__move-up-button',
            ])
        @_domElementInner.appendChild(@_domMoveUpButton)

        @_domMoveUpRightButton = @constructor.createDiv([
            'ct-anchored-dialog__button',
            'ct-anchored-dialog__move-up-right-button',
            ])
        @_domElementInner.appendChild(@_domMoveUpRightButton)

        # Create the input element for the width
        if @_moveSizeElement instanceof ContentEdit.ResizableElement and @_moveSizeElement.can('resize')
            @_domWidthInput = document.createElement('input')
            @_domWidthInput.setAttribute('class', 'ct-anchored-dialog__size-input ct-anchored-dialog__size-input-first')
            @_domWidthInput.setAttribute('name', 'width')
            @_domWidthInput.setAttribute(
                'placeholder',
                ContentEdit._('Enter a width') + '...'
                )
            @_domWidthInput.setAttribute('type', 'text')
            @_domWidthInput.setAttribute('value', size[0])
            @_domElementInner.appendChild(@_domWidthInput)

        @_domMoveDownLeftButton = @constructor.createDiv([
            'ct-anchored-dialog__button',
            'ct-anchored-dialog__move-down-left-button',
            ])
        @_domElementInner.appendChild(@_domMoveDownLeftButton)

        @_domMoveDownButton = @constructor.createDiv([
            'ct-anchored-dialog__button',
            'ct-anchored-dialog__move-down-button',
            ])
        @_domElementInner.appendChild(@_domMoveDownButton)

        @_domMoveDownRightButton = @constructor.createDiv([
            'ct-anchored-dialog__button',
            'ct-anchored-dialog__move-down-right-button',
            ])
        @_domElementInner.appendChild(@_domMoveDownRightButton)

        # Create the input element for the height
        if @_moveSizeElement instanceof ContentEdit.ResizableElement and @_moveSizeElement.can('resize')
            @_domHeightInput = document.createElement('input')
            @_domHeightInput.setAttribute('class', 'ct-anchored-dialog__size-input')
            @_domHeightInput.setAttribute('name', 'height')
            @_domHeightInput.setAttribute(
                'placeholder',
                ContentEdit._('Enter a height') + '...'
                )
            @_domHeightInput.setAttribute('type', 'text')
            @_domHeightInput.setAttribute('value', size[1])
            @_domElementInner.appendChild(@_domHeightInput)

        # Add interaction handlers
        @_addDOMEventListeners()

    # Private methods

    _getCurrentPosition: () ->
        # Recalculate current position information
        [scrollX, scrollY] = ContentTools.getScrollPosition()

        rect = @_moveSizeElement.domElement().getBoundingClientRect()
        currPosition = [
            rect.left + (rect.width / 2) + scrollX,
            rect.top + (rect.height / 2) + scrollY
            ]

        return currPosition

    _adjustPosition: (origPosition) ->

        # Update the position of the dialog so it remains centered on the element
        newPosition = @_getCurrentPosition()
        @position(newPosition)

        # Automatic scrolling is a bit confusing but some people might prefer it
        if ContentTools.MOVE_SIZE_AUTO_SCROLL

            # Find a parent scrollable element
            scrollElement = null
            currElement = @_moveSizeElement.domElement().parentNode;
            while currElement and not scrollElement
                if currElement.clientHeight > 0 and currElement.scrollHeight - 25 > currElement.clientHeight
                    scrollElement = currElement

                currElement = currElement.parentNode;

            if not scrollElement
                scrollElement = window

            # Attempt to scroll so that the dialog remains at the same location on the screen
            scrollElement.scrollLeft += newPosition[0] - origPosition[0]
            scrollElement.scrollTop += newPosition[1] - origPosition[1]

    _move: (vert, horz) ->
        # Find a valid element to move the element to (if any)
        newElement = null
        currElement = @_moveSizeElement
        if vert == 'up'
            currElement = currElement.previous()
            while currElement and not newElement
                if currElement != @_moveSizeElement.parent() and currElement.can('drop') and (currElement.constructor.droppers[@_moveSizeElement.type()] or @_moveSizeElement.constructor.droppers[currElement.type()])
                    newElement = currElement

                currElement = currElement.previous()
        else
            currElement = currElement.next()
            while currElement and not newElement
                if currElement != @_moveSizeElement.parent() and currElement.can('drop') and (currElement.constructor.droppers[@_moveSizeElement.type()] or @_moveSizeElement.constructor.droppers[currElement.type()])
                    newElement = currElement

                currElement = currElement.next()

        if not newElement
            return

        origPosition = @_getCurrentPosition()

        # Move the element
        if vert == 'up'
            if newElement == @_moveSizeElement.previousSibling()
                @_moveSizeElement.drop(newElement, ['above', horz])
            else
                @_moveSizeElement.drop(newElement, ['below', horz])
        else
            if newElement == @_moveSizeElement.nextSibling()
                @_moveSizeElement.drop(newElement, ['below', horz])
            else
                @_moveSizeElement.drop(newElement, ['above', horz])

        @_adjustPosition(origPosition)

    _widthUpdated: () ->
        # The width input element was updated
        if @_domWidthInput.value == ''
            return;

        @_domHeightInput.value = Math.round(parseInt(@_domWidthInput.value) * @_moveSizeElement.aspectRatio())

        origPosition = @_getCurrentPosition()
        @_moveSizeElement.size([@_domWidthInput.value, @_domHeightInput.value])
        @_adjustPosition(origPosition)

    _heightUpdated: () ->
        # The height input element was updated
        if @_domHeightInput.value == ''
            return;

        @_domWidthInput.value = Math.round(parseInt(@_domHeightInput.value) / @_moveSizeElement.aspectRatio())

        origPosition = @_getCurrentPosition()
        @_moveSizeElement.size([@_domWidthInput.value, @_domHeightInput.value])
        @_adjustPosition(origPosition)

    _addDOMEventListeners: () ->
        # Add event listeners for the widget

        # Buttons
        @_domMoveUpLeftButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_move('up', 'left')

        @_domMoveUpButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_move('up', 'center')

        @_domMoveUpRightButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_move('up', 'right')

        @_domMoveDownLeftButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_move('down', 'left')

        @_domMoveDownButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_move('down', 'center')

        @_domMoveDownRightButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @_move('down', 'right')

        # Input elements
        if @_moveSizeElement instanceof ContentEdit.ResizableElement and @_moveSizeElement.can('resize')
            @_domWidthInput.addEventListener 'keypress', (ev) =>
                @_widthUpdated()

            @_domWidthInput.addEventListener 'keyup', (ev) =>
                @_widthUpdated()

            @_domWidthInput.addEventListener 'input', (ev) =>
                @_widthUpdated()

            @_domWidthInput.addEventListener 'change', (ev) =>
                @_widthUpdated()

            @_domWidthInput.addEventListener 'blur', (ev) =>
                size = @_moveSizeElement.size()

                @_domWidthInput.value = size[0]
                @_domHeightInput.value = size[1]

            @_domHeightInput.addEventListener 'keypress', (ev) =>
                @_heightUpdated()

            @_domHeightInput.addEventListener 'keyup', (ev) =>
                @_heightUpdated()

            @_domHeightInput.addEventListener 'input', (ev) =>
                @_heightUpdated()

            @_domHeightInput.addEventListener 'change', (ev) =>
                @_heightUpdated()

            @_domHeightInput.addEventListener 'blur', (ev) =>
                size = @_moveSizeElement.size()

                @_domWidthInput.value = size[0]
                @_domHeightInput.value = size[1]
