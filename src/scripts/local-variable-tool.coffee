class ReplaceVariableTool extends ContentTools.Tools.Bold

  # Insert/Remove a <replace-variable> tag.

  # Register the tool with the toolshelf
  ContentTools.ToolShelf.stow(@, 'local-variable')

  # The tooltip and icon modifier CSS class for the tool
  @label = 'Local Variable'
  @icon = 'local-variable'

  # The Bold provides a tagName attribute we can override to make inheriting
  # from the class cleaner.
  @tagName = 'local-variable'

  @apply: (element, selection, callback) ->
# Apply a <replace-variable> element to the specified element and selection

# Store the selection state of the element so we can restore it once done
    element.storeState()

    # Add a fake selection wrapper to the selected text so that it appears to be
    # selected when the focus is lost by the element.
    selectTag = new HTMLString.Tag('span', {'class': 'ct--puesdo-select'})
    [from, to] = selection.get()
    element.content = element.content.format(from, to, selectTag)
    element.updateInnerHTML()

    # Set-up the dialog
    app = ContentTools.EditorApp.get()

    # Add an invisible modal that we'll use to detect if the user clicks away
    # from the dialog to close it.
    modal = new ContentTools.ModalUI(transparent=true, allowScrolling=true)

    modal.addEventListener 'click', () ->

      # Close the dialog
      @unmount()
      dialog.hide()

      # Remove the fake selection from the element
      element.content = element.content.unformat(from, to, selectTag)
      element.updateInnerHTML()

      # Restore the real selection
      element.restoreState()

      # Trigger the callback
      callback(false)

    # Measure a rectangle of the content selected so we can position the
    # dialog centrally to it.
    domElement = element.domElement()
    measureSpan = domElement.getElementsByClassName('ct--puesdo-select')
    rect = measureSpan[0].getBoundingClientRect()

    # Create the dialog
    dialog = new LocalVariableDialog(@getValue(element, selection))
    dialog.position([
      rect.left + (rect.width / 2) + window.scrollX,
      rect.top + (rect.height / 2) + window.scrollY
    ])

    # Listen for save events against the dialog
    dialog.addEventListener 'save', (ev) ->
# Add/Update/Remove the <replace-variable>
      value = ev.detail().value

      # Clear any existing link
      element.content = element.content.unformat(from, to, 'local-variable')

      # If specified add the new replace-variable
      if value
        replaceVariable = new HTMLString.Tag('local-variable', {value: value})
        element.content = element.content.format(from, to, replaceVariable)

      element.updateInnerHTML()
      element.taint()

      # Close the modal and dialog
      modal.unmount()
      dialog.hide()

      # Remove the fake selection from the element
      element.content = element.content.unformat(from, to, selectTag)
      element.updateInnerHTML()

      # Restore the real selection
      element.restoreState()

      # Trigger the callback
      callback(true)

    app.attach(modal)
    app.attach(dialog)
    modal.show()
    dialog.show()


  @getValue: (element, selection) ->
# Find the first character in the selected text that has a `replace-variable` tag and
# return its `value` value.
    [from, to] = selection.get()
    selectedContent = element.content.slice(from, to)
    for c in selectedContent.characters

# Does this character have a replace-variable tag applied?
      if not c.hasTags('local-variable')
        continue

      # Find the replace-variable tag and return the value attribute value
      for tag in c.tags()
        if tag.name() == 'local-variable'
          return tag.attr('value')

      return ''

# @getCommonName: (element, selection) ->
# Return any existing `common-name` attribute for the element and selection

class LocalVariableDialog extends ContentTools.LinkDialog

  # An anchored dialog to support inserting/modifying a <replace-variable> tag

  mount: () ->
    super()

    # Update the name and placeholder for the input field provided by the
    # link dialog.
    @_domInput.setAttribute('name', 'value')
    @_domInput.setAttribute('placeholder', 'Enter the variable name.')

    # Remove the new window target DOM element
    @_domElement.removeChild(@_domTargetButton);

  save: () ->
# Save the value.
    detail = {
      value: @_domInput.value.trim()
    }
    @dispatchEvent(@createEvent('save', detail))

ContentTools.DEFAULT_TOOLS[0].push('local-variable')