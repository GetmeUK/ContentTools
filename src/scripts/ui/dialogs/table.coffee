class ContentTools.TableDialog extends ContentTools.DialogUI

    # A dialog to support inserting/update a table

    constructor: (@table)->
        if @table
            super('Update table')
        else
            super('Insert table')

    # Methods

    mount: () ->
        # Mount the widget
        super()

        # Build the initial configuration of the dialog
        cfg = {columns: 3, foot: false, head: true}
        if @table
            cfg = {
                columns: @table.firstSection().children[0].children.length
                foot: @table.tfoot()
                head: @table.thead()
                }

        # Update dialog class
        ContentEdit.addCSSClass(@_domElement, 'ct-table-dialog')

        # Update view class
        ContentEdit.addCSSClass(@_domView, 'ct-table-dialog__view')

        # Add sections

        # Head
        headCSSClasses = ['ct-section']
        if cfg.head
            headCSSClasses.push('ct-section--applied')
        @_domHeadSection = @constructor.createDiv(headCSSClasses)
        @_domView.appendChild(@_domHeadSection)

        domHeadLabel = @constructor.createDiv(['ct-section__label'])
        domHeadLabel.textContent = ContentEdit._('Table head')
        @_domHeadSection.appendChild(domHeadLabel)

        @_domHeadSwitch = @constructor.createDiv(['ct-section__switch'])
        @_domHeadSection.appendChild(@_domHeadSwitch)

        # Body
        @_domBodySection = @constructor.createDiv([
            'ct-section',
            'ct-section--applied',
            'ct-section--contains-input'
            ])
        @_domView.appendChild(@_domBodySection)

        domBodyLabel = @constructor.createDiv(['ct-section__label'])
        domBodyLabel.textContent = ContentEdit._('Table body (columns)')
        @_domBodySection.appendChild(domBodyLabel)

        @_domBodyInput = document.createElement('input')
        @_domBodyInput.setAttribute('class', 'ct-section__input')
        @_domBodyInput.setAttribute('maxlength', '2')
        @_domBodyInput.setAttribute('name', 'columns')
        @_domBodyInput.setAttribute('type', 'text')
        @_domBodyInput.setAttribute('value', cfg.columns)
        @_domBodySection.appendChild(@_domBodyInput)

        # Foot
        footCSSClasses = ['ct-section']
        if cfg.foot
            footCSSClasses.push('ct-section--applied')
        @_domFootSection = @constructor.createDiv(footCSSClasses)
        @_domView.appendChild(@_domFootSection)

        domFootLabel = @constructor.createDiv(['ct-section__label'])
        domFootLabel.textContent = ContentEdit._('Table foot')
        @_domFootSection.appendChild(domFootLabel)

        @_domFootSwitch = @constructor.createDiv(['ct-section__switch'])
        @_domFootSection.appendChild(@_domFootSwitch)

        # Add controls
        domControlGroup = @constructor.createDiv(
            ['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domControlGroup)

        # Apply button
        @_domApply = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--apply'
            ])
        @_domApply.textContent = 'Apply'
        domControlGroup.appendChild(@_domApply)

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the table. The event trigged by saving the table includes a
        # dictionary with the table configuration in:
        #
        # `body` Number of columns.
        # `foot` True if a table foot section should be present.
        # `head` True if a table head section should be present.

        # Build a dictionary of the table configuration
        footCSSClass = @_domFootSection.getAttribute('class')
        headCSSClass = @_domHeadSection.getAttribute('class')

        detail = {
            columns: parseInt(@_domBodyInput.value),
            foot: footCSSClass.indexOf('ct-section--applied') > -1,
            head: headCSSClass.indexOf('ct-section--applied') > -1
            }

        @dispatchEvent(@createEvent('save', detail))

    unmount: () ->
        # Unmount the component from the DOM
        super()

        @_domBodyInput = null
        @_domBodySection = null
        @_domApply = null
        @_domHeadSection = null
        @_domHeadSwitch = null
        @_domFootSection = null
        @_domFootSwitch = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget
        super()

        # Add support for the head and foot switches
        toggleSection = (ev) ->
            ev.preventDefault()

            # Toggle applied class
            if this.getAttribute('class').indexOf('ct-section--applied') > -1
                ContentEdit.removeCSSClass(this, 'ct-section--applied')
            else
                ContentEdit.addCSSClass(this, 'ct-section--applied')

        @_domHeadSection.addEventListener 'click', toggleSection
        @_domFootSection.addEventListener 'click', toggleSection

        # Focus on the columns input if the section is clicked
        @_domBodySection.addEventListener 'click', (ev) =>
            @_domBodyInput.focus()

        # Check the value body input (number of columns) and enable/disable the
        # 'Apply' button depending on whether or not the value is a valid
        # integer between 1 and 999.
        @_domBodyInput.addEventListener 'input', (ev) =>
            valid = /^[1-9]\d{0,1}$/.test(ev.target.value)
            if valid
                ContentEdit.removeCSSClass(
                    @_domBodyInput,
                    'ct-section__input--invalid'
                    )
                ContentEdit.removeCSSClass(
                    @_domApply,
                    'ct-control--muted'
                    )
            else
                ContentEdit.addCSSClass(
                    @_domBodyInput,
                    'ct-section__input--invalid'
                    )
                ContentEdit.addCSSClass(
                    @_domApply,
                    'ct-control--muted'
                    )

        # Apply button
        @_domApply.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check the button isn't muted, if it is then the table
            # configuration isn't valid.
            cssClass = @_domApply.getAttribute('class')
            if cssClass.indexOf('ct-control--muted') == -1
                @save()