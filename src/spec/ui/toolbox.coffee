# ToolboxUI

describe 'ContentTools.ToolboxUI', () ->

    div = null
    editor = null

    beforeEach ->
        # Create an editable region
        div = document.createElement('div')
        div.setAttribute('class', 'editable')
        document.body.appendChild(div)

        # Initialize the editor
        editor = ContentTools.EditorApp.get()
        editor.init('.editable')

    afterEach ->
        # Shutdown the editor
        editor.destroy()

        # Remove the editable region
        document.body.removeChild(div)


    describe 'ContentTools.ToolboxUI()', () ->

        it 'should return an instance of a ToolboxUI', () ->

            toolbox = new ContentTools.ToolboxUI()
            expect(toolbox instanceof ContentTools.ToolboxUI).toBe true

# Methods
#
# isDragging
# hide
# tools
# mount
# updateTools
# unmount

# Interactions
#
# Ensures that tools are updated when required
# Is always contained within the browser viewport
# Can be dragged
# Supports Delete/Undo/Redo keyboard shortcuts