class ContentTools.ToolShelf

    # The `ToolShelf` class allows tools to be stored using a name (string) as a
    # reference. Using a tools name makes is cleaner when defining a set of
    # tools to populate the `ToolboxUI` widget.

    @_tools = {}

    @stow: (cls, name) ->
        # Stow a tool on the shelf

        @_tools[name] = cls

    @fetch: (name) ->
        # Fetch a tool from the shelf by it's name
        unless @_tools[name]
            throw new Error("`#{name}` has not been stowed on the tool shelf")

        return @_tools[name]


class ContentTools.Tool

    # The `Tool` class defines a common API for editor tools. All tools should
    # inherit from the `Tool` class.
    #
    # Tools classes are designed to be used direct not as instances of the
    # class, every property and method for a tool is held against the class.
    #
    # A tool is effectively a collection of functions (class methods) with a set
    # of configuration settings (class properties). For this reason they are
    # defined using static classes.

    @label = 'Tool'
    @icon = 'tool'

    # Class methods

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the specified
        # element and selection.
        return false

    @isApplied: (element, selection) ->
        # Return true if the tool is currently applied to the specified
        # element and selection.
        return false

    @apply: (element, selection, callback) ->
        # Apply the tool to the specified element and selection
        throw new Error('Not implemented')

    # Private class methods

    @_insertAt: (element) ->
        # Find insert node and index for inserting an element after the
        # specified element.

        insertNode = element
        if insertNode.parent().constructor.name != 'Region'
            insertNode = element.closest (node) ->
                return node.parent().constructor.name is 'Region'

        insertIndex = insertNode.parent().children.indexOf(insertNode) + 1

        return [insertNode, insertIndex]


# Common tools

class ContentTools.Tools.Bold extends ContentTools.Tool

    # Make the current selection of text (non)bold (e.g <b>foo</b>).

    ContentTools.ToolShelf.stow(@, 'bold')

    @label = 'Bold'
    @icon = 'bold'
    @tagName = 'b'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        unless element.content
            return false

        return selection and not selection.isCollapsed()

    @isApplied: (element, selection) ->
        # Return true if the tool is currently applied to the current
        # element/selection.
        if element.content is undefined or not element.content.length()
            return false

        [from, to] = selection.get()
        if from == to
            to += 1

        return element.content.slice(from, to).hasTags(@tagName, true)

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element
        element.storeState()

        [from, to] = selection.get()

        if @isApplied(element, selection)
            element.content = element.content.unformat(
                from,
                to,
                new HTMLString.Tag(@tagName)
                )
        else
            element.content = element.content.format(
                from,
                to,
                new HTMLString.Tag(@tagName)
                )

        element.updateInnerHTML()
        element.taint()

        element.restoreState()

        callback(true)


class ContentTools.Tools.Italic extends ContentTools.Tools.Bold

    # Make the current selection of text (non)italic (e.g <i>foo</i>).

    ContentTools.ToolShelf.stow(@, 'italic')

    @label = 'Italic'
    @icon = 'italic'
    @tagName = 'i'


class ContentTools.Tools.Link extends ContentTools.Tools.Bold

    # Insert/Remove a link.

    ContentTools.ToolShelf.stow(@, 'link')

    @label = 'Link'
    @icon = 'link'
    @tagName = 'a'

    @getHref: (element, selection) ->
        # Get the existing href for the element and selection

        # Images
        if element.constructor.name == 'Image'
            if element.a
                return element.a.href

        # Text
        else
            # Find the first character in the selected text that has an `a` tag
            # and return its `href` value.
            [from, to] = selection.get()
            selectedContent = element.content.slice(from, to)
            for c in selectedContent.characters
                if not c.hasTags('a')
                    continue

                for tag in c.tags()
                    if tag.name() == 'a'
                        return tag.attr('href')

        return ''

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        if element.constructor.name == 'Image'
            return true
        else
            return super(element, selection)

    @isApplied: (element, selection) ->
        # Return true if the tool is currently applied to the current
        # element/selection.
        if element.constructor.name == 'Image'
            return element.a
        else
            return super(element, selection)

    @apply: (element, selection, callback) ->
        applied = false

        # Prepare text elements for adding a link
        if element.constructor.name == 'Image'
            # Images
            rect = element.domElement().getBoundingClientRect()

        else
            # Text elements
            element.storeState()

            # Add a fake selection wrapper to the selected text so that it
            # appears to be selected when the focus is lost by the element.
            selectTag = new HTMLString.Tag('span', {'class': 'ct--puesdo-select'})
            [from, to] = selection.get()
            element.content = element.content.format(from, to, selectTag)
            element.updateInnerHTML()

            # Measure a rectangle of the content selected so we can position the
            # dialog centrally.
            domElement = element.domElement()
            measureSpan = domElement.getElementsByClassName('ct--puesdo-select')
            rect = measureSpan[0].getBoundingClientRect()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI(transparent=true, allowScrolling=true)

        # When the modal is clicked on the dialog should close
        modal.bind 'click', () ->
            @unmount()
            dialog.hide()

            if element.content
                # Remove the fake selection from the element
                element.content = element.content.unformat(from, to, selectTag)
                element.updateInnerHTML()

                # Restore the selection
                element.restoreState()

            callback(applied)

        # Dialog
        dialog = new ContentTools.LinkDialog(@getHref(element, selection))
        dialog.position([
            rect.left + (rect.width / 2) + window.scrollX,
            rect.top + (rect.height / 2) + window.scrollY
            ])

        dialog.bind 'save', (href) ->
            dialog.unbind('save')

            applied = true

            # Add the link
            if element.constructor.name == 'Image'

                # Images
                if href
                    element.a = {href: href}
                else
                    element.a = null

            else
                # Text elements

                # Clear any existing link
                element.content = element.content.unformat(from, to, 'a')

                # If specified add the new link
                if href
                    a = new HTMLString.Tag('a', {href: href})
                    element.content = element.content.format(from, to, a)

                element.updateInnerHTML()
                element.taint()

            # Close the modal and dialog
            modal.trigger('click')

        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()


class ContentTools.Tools.Heading extends ContentTools.Tool

    # Convert the current text block to a heading (e.g <h1>foo</h1>)

    ContentTools.ToolShelf.stow(@, 'heading')

    @label = 'Heading'
    @icon = 'heading'
    @tagName = 'h1'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.

        return element.content != undefined and
                element.parent().constructor.name == 'Region'

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element
        element.storeState()

        # If the tag is a PreText tag then we need to handle the convert the
        # element not just the tag name.
        if element.constructor.name == 'PreText'
            # Convert the element to a Text element first
            content = element.content.html().replace(/&nbsp;/g, ' ')
            textElement = new ContentEdit.Text(@tagName, {}, content)

            # Remove the current element from the region
            parent = element.parent()
            insertAt = parent.children.indexOf(element)
            parent.detach(element)
            parent.attach(textElement, insertAt)

            # Restore selection
            element.blur()
            textElement.focus()
            textElement.selection(selection)

        else
            # Change the text elements tag name
            element.tagName(@tagName)
            element.restoreState()

        callback(true)


class ContentTools.Tools.Subheading extends ContentTools.Tools.Heading

    # Convert the current text block to a subheading (e.g <h2>foo</h2>)

    ContentTools.ToolShelf.stow(@, 'subheading')

    @label = 'Subheading'
    @icon = 'subheading'
    @tagName = 'h2'


class ContentTools.Tools.Paragraph extends ContentTools.Tools.Heading

    # Convert the current text block to a paragraph (e.g <p>foo</p>)

    ContentTools.ToolShelf.stow(@, 'paragraph')

    @label = 'Paragraph'
    @icon = 'paragraph'
    @tagName = 'p'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return element != undefined

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element
        app = ContentTools.EditorApp.get()
        forceAdd = app.ctrlDown()

        if ContentTools.Tools.Heading.canApply(element) and not forceAdd
            # If the element is a top level text element and the user hasn't
            # indicated they want to force add a new paragraph convert it to a
            # paragraph in-place.
            return super(element, selection, callback)
        else
            # If the element isn't a text element find the nearest top level
            # node and insert a new paragraph element after it.
            if element.parent().constructor.name != 'Region'
                element = element.closest (node) ->
                    return node.parent().constructor.name == 'Region'

            region = element.parent()
            paragraph = new ContentEdit.Text('p')
            region.attach(paragraph, region.children.indexOf(element) + 1)

            # Give the newely inserted paragraph focus
            paragraph.focus()

            callback(true)


class ContentTools.Tools.Preformatted extends ContentTools.Tools.Heading

    # Convert the current text block to a preformatted block (e.g <pre>foo</pre)

    ContentTools.ToolShelf.stow(@, 'preformatted')

    @label = 'Preformatted'
    @icon = 'preformatted'
    @tagName = 'pre'

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element

        # Escape the contents of the existing element
        text = element.content.text()

        # Create a new pre-text element using the current elements content
        preText = new ContentEdit.PreText(
            'pre', {},
            HTMLString.String.encode(text)
            )

        # Remove the current element from the region
        parent = element.parent()
        insertAt = parent.children.indexOf(element)
        parent.detach(element)
        parent.attach(preText, insertAt)

        # Restore selection
        element.blur()
        preText.focus()
        preText.selection(selection)

        callback(true)


class ContentTools.Tools.AlignLeft extends ContentTools.Tool

    # Apply a class to left align the contents of the current text block.

    ContentTools.ToolShelf.stow(@, 'align-left')

    @label = 'Align left'
    @icon = 'align-left'
    @className = 'text-left'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return element.content != undefined

    @isApplied: (element, selection) ->
        # Return true if the tool is currently applied to the current
        # element/selection.
        if not @canApply(element)
            return false

        # List items and table cells use child nodes to manage their content
        # which don't support classes, so we need to check the parent.
        if element.constructor.name in ['ListItemText', 'TableCellText']
            element = element.parent()

        return element.hasCSSClass(@className)

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element

        # List items and table cells use child nodes to manage their content
        # which don't support classes, so we need to use the parent.
        if element.constructor.name in ['ListItemText', 'TableCellText']
            element = element.parent()

        # Remove any existing text alignment classes applied
        for className in ['text-center', 'text-left', 'text-right']
            if element.hasCSSClass(className)
                element.removeCSSClass(className)

                # If we're removing the class associated with the tool then we
                # can return early (this allows the tool to be toggled on/off).
                if className == @className
                    return callback(true)

        # Add the alignment class to the element
        element.addCSSClass(@className)

        callback(true)


class ContentTools.Tools.AlignCenter extends ContentTools.Tools.AlignLeft

    # Apply a class to center align the contents of the current text block.

    ContentTools.ToolShelf.stow(@, 'align-center')

    @label = 'Align center'
    @icon = 'align-center'
    @className = 'text-center'


class ContentTools.Tools.AlignRight extends ContentTools.Tools.AlignLeft

    # Apply a class to right align the contents of the current text block.

    ContentTools.ToolShelf.stow(@, 'align-right')

    @label = 'Align right'
    @icon = 'align-right'
    @className = 'text-right'


class ContentTools.Tools.UnorderedList extends ContentTools.Tool

    # Set an element as an unordered list.

    ContentTools.ToolShelf.stow(@, 'unordered-list')

    @label = 'Bullet list'
    @icon = 'unordered-list'
    @listTag = 'ul'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return element.content != undefined and
                element.parent().constructor.name in ['Region', 'ListItem']

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element
        if element.parent().constructor.name == 'ListItem'

            # Find the parent list and change it to an unordered list
            element.storeState()
            list = element.closest (node) ->
                return node.constructor.name == 'List'
            list.tagName(@listTag)
            element.restoreState()

        else
            # Convert the element to a list

            # Create a new list using the current elements content
            listItemText = new ContentEdit.ListItemText(element.content.copy())
            listItem = new ContentEdit.ListItem()
            listItem.attach(listItemText)
            list = new ContentEdit.List(@listTag, {})
            list.attach(listItem)

            # Remove the current element from the region
            parent = element.parent()
            insertAt = parent.children.indexOf(element)
            parent.detach(element)
            parent.attach(list, insertAt)

            # Restore selection
            listItemText.focus()
            listItemText.selection(selection)

        callback(true)


class ContentTools.Tools.OrderedList extends ContentTools.Tools.UnorderedList

    # Set an element as an ordered list.

    ContentTools.ToolShelf.stow(@, 'ordered-list')

    @label = 'Numbers list'
    @icon = 'ordered-list'
    @listTag = 'ol'


class ContentTools.Tools.Table extends ContentTools.Tool

    # Insert/Update a Table.

    ContentTools.ToolShelf.stow(@, 'table')

    @label = 'Table'
    @icon = 'table'

    # Class methods

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return element != undefined

    @apply: (element, selection, callback) ->

        # If supported allow store the state for restoring once the dialog is
        # cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI()

        # If the element is part of a table find the parent table
        table = element.closest (node) ->
            return node and node.constructor.name is 'Table'

        # Dialog
        dialog = new ContentTools.TableDialog(table)

        # Support cancelling the dialog
        dialog.bind 'cancel', () =>
            dialog.unbind('cancel')

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog
        dialog.bind 'save', (tableCfg) =>
            dialog.unbind('save')

            # This flag indicates if we can restore the previous elements focus
            # and state or if we need to change the focus to the first cell in
            # the table.
            keepFocus = true

            if table
                # Update the existing table
                @_updateTable(tableCfg, table)

                # Check if the current element is still part of the table after
                # being updated.
                keepFocus = element.closest (node) ->
                    return node and node.constructor.name is 'Table'

            else
                # Create a new table
                table = @_createTable(tableCfg)

                # Insert it into the document
                [node, index] = @_insertAt(element)
                node.parent().attach(table, index)

                keepFocus = false

            if keepFocus
                element.restoreState()

            else
                # Focus on the first cell in the table e.g:
                #
                # TableSection > TableRow > TableCell > TableCellText
                table.firstSection().children[0].children[0].children[0].focus()

            modal.hide()
            dialog.hide()

            callback(true)

        # Show the dialog
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()

    # Private class methods

    @_adjustColumns: (section, columns) ->
        # Adjust the number of columns in a table section
        for row in section.children
            cellTag = row.children[0].tagName()
            currentColumns = row.children.length
            diff = columns - currentColumns

            if diff < 0
                # Remove columns
                for i in [diff...0]
                    cell = row.children[row.children.length - 1]
                    row.detach(cell)

            else if diff > 0
                # Add columns
                for i in [0...diff]
                    cell = new ContentEdit.TableCell(cellTag)
                    row.attach(cell)
                    cellText = new ContentEdit.TableCellText('')
                    cell.attach(cellText)

    @_createTable: (tableCfg) ->
        # Create a new table element from the specified configuration
        table = new ContentEdit.Table()

        # Head
        if tableCfg.head
            head = @_createTableSection('thead', 'th', tableCfg.columns)
            table.attach(head)

        # Body
        body = @_createTableSection('tbody', 'td', tableCfg.columns)
        table.attach(body)

        # Foot
        if tableCfg.foot
            foot = @_createTableSection('tfoot', 'td', tableCfg.columns)
            table.attach(foot)

        return table

    @_createTableSection: (sectionTag, cellTag, columns) ->
        # Create a new table section element
        section = new ContentEdit.TableSection(sectionTag)
        row = new ContentEdit.TableRow()
        section.attach(row)

        for i in [0...columns]
            cell = new ContentEdit.TableCell(cellTag)
            row.attach(cell)
            cellText = new ContentEdit.TableCellText('')
            cell.attach(cellText)

        return section

    @_updateTable: (tableCfg, table) ->
        # Update an existing table

        # Remove any sections no longer required
        if not tableCfg.head and table.thead()
            table.detach(table.thead())

        if not tableCfg.foot and table.tfoot()
            table.detach(table.tfoot())

        # Increase or decrease the number of columns
        columns = table.firstSection().children[0].children.length
        if tableCfg.columns != columns
            for section in table.children
                @_adjustColumns(section, tableCfg.columns)

        # Add any new sections
        if tableCfg.head and not table.thead()
            head = @_createTableSection('thead', 'th', tableCfg.columns)
            table.attach(head)

        if tableCfg.foot and not table.tfoot()
            foot = @_createTableSection('tfoot', 'td', tableCfg.columns)
            table.attach(foot)


class ContentTools.Tools.Indent extends ContentTools.Tool

    # Indent a list item.

    ContentTools.ToolShelf.stow(@, 'indent')

    @label = 'Indent'
    @icon = 'indent'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.

        return element.parent().constructor.name == 'ListItem' and
                element.parent().parent().children.indexOf(element.parent()) > 0

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element

        # Indent the list item
        element.parent().indent()

        callback(true)


class ContentTools.Tools.Unindent extends ContentTools.Tool

    # Unindent a list item.

    ContentTools.ToolShelf.stow(@, 'unindent')

    @label = 'Unindent'
    @icon = 'unindent'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return element.parent().constructor.name == 'ListItem'

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element

        # Indent the list item
        element.parent().unindent()

        callback(true)


class ContentTools.Tools.LineBreak extends ContentTools.Tool

    # Insert a line break in to the current element at the specified selection.

    ContentTools.ToolShelf.stow(@, 'line-break')

    @label = 'Line break'
    @icon = 'line-break'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return element.content

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element

        # Insert a BR at the current in index
        cursor = selection.get()[0] + 1

        tip = element.content.substring(0, selection.get()[0])
        tail = element.content.substring(selection.get()[1])
        br = new HTMLString.String('<br>', element.content.preserveWhitespace())
        element.content = tip.concat(br, tail)
        element.updateInnerHTML()
        element.taint()

        # Restore the selection
        selection.set(cursor, cursor)
        element.selection(selection)

        callback(true)


class ContentTools.Tools.Image extends ContentTools.Tool

    # Insert an image.

    ContentTools.ToolShelf.stow(@, 'image')

    @label = 'Image'
    @icon = 'image'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return true

    @apply: (element, selection, callback) ->

        # If supported allow store the state for restoring once the dialog is
        # cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI()

        # Dialog
        dialog = new ContentTools.ImageDialog()

        # Support cancelling the dialog
        dialog.bind 'cancel', () =>
            dialog.unbind('cancel')

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog
        dialog.bind 'save', (imageURL, imageSize, imageAttrs) =>
            dialog.unbind('save')

            if not imageAttrs
                imageAttrs = {}

            imageAttrs.height = imageSize[1]
            imageAttrs.src = imageURL
            imageAttrs.width = imageSize[0]

            # Create the new image
            image = new ContentEdit.Image(imageAttrs)

            # Find insert position
            [node, index] = @_insertAt(element)
            node.parent().attach(image, index)

            # Focus the new image
            image.focus()

            modal.hide()
            dialog.hide()

            callback(true)

        # Show the dialog
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()


class ContentTools.Tools.Video extends ContentTools.Tool

    # Insert a video.

    ContentTools.ToolShelf.stow(@, 'video')

    @label = 'Video'
    @icon = 'video'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return true

    @apply: (element, selection, callback) ->

        # If supported allow store the state for restoring once the dialog is
        # cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI()

        # Dialog
        dialog = new ContentTools.VideoDialog()

        # Support cancelling the dialog
        dialog.bind 'cancel', () =>
            dialog.unbind('cancel')

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog
        dialog.bind 'save', (videoURL) =>
            dialog.unbind('save')

            if videoURL
                # Create the new video
                video = new ContentEdit.Video(
                    'iframe', {
                        'frameborder': 0,
                        'height': ContentTools.DEFAULT_VIDEO_HEIGHT,
                        'src': videoURL,
                        'width': ContentTools.DEFAULT_VIDEO_WIDTH
                        })

                # Find insert position
                [node, index] = @_insertAt(element)
                node.parent().attach(video, index)

                # Focus the new video
                video.focus()

            else
                # Nothing to do restore state
                if element.restoreState
                    element.restoreState()

            modal.hide()
            dialog.hide()

            callback(videoURL != '')

        # Show the dialog
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()


class ContentTools.Tools.Undo extends ContentTools.Tool

    # Undo an action.

    ContentTools.ToolShelf.stow(@, 'undo')

    @label = 'Undo'
    @icon = 'undo'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        app = ContentTools.EditorApp.get()
        return app.history and app.history.canUndo()

    @apply: (element, selection, callback) ->
        app = ContentTools.EditorApp.get()

        # Revert the document to the previous state
        app.history.stopWatching()
        snapshot = app.history.undo()
        app.revertToSnapshot(snapshot)
        app.history.watch()


class ContentTools.Tools.Redo extends ContentTools.Tool

    # Redo an action.

    ContentTools.ToolShelf.stow(@, 'redo')

    @label = 'Redo'
    @icon = 'redo'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        app = ContentTools.EditorApp.get()
        return app.history and app.history.canRedo()

    @apply: (element, selection, callback) ->
        app = ContentTools.EditorApp.get()

        # Revert the document to the next state
        app.history.stopWatching()
        snapshot = app.history.redo()
        app.revertToSnapshot(snapshot)
        app.history.watch()


class ContentTools.Tools.Remove extends ContentTools.Tool

    # Remove the current element.

    ContentTools.ToolShelf.stow(@, 'remove')

    @label = 'Remove'
    @icon = 'remove'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        return true

    @apply: (element, selection, callback) ->
        # Apply the tool to the current element
        app = ContentTools.EditorApp.get()

        # Blur the element before it's removed otherwise it will retain focus
        # even when detached.
        element.blur()

        # Focus on the next element
        if element.nextContent()
            element.nextContent().focus()
        else if element.previousContent()
            element.previousContent().focus()

        # Remove the element
        switch element.constructor.name
            when 'ListItemText'
                # Delete the associated list or list item
                if app.ctrlDown()
                    list = element.closest (node) ->
                        return node.parent().constructor.name == 'Region'
                    list.parent().detach(list)
                else
                    element.parent().parent().detach(element.parent())
                break
            when 'TableCellText'
                # Delete the associated table or table row
                if app.ctrlDown()
                    table = element.closest (node) ->
                        return node.constructor.name == 'Table'
                    table.parent().detach(table)
                else
                    row = element.parent().parent()
                    row.parent().detach(row)
                break
            else
                element.parent().detach(element)
                break

        callback(true)