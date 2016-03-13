class ContentTools.ModalUI extends ContentTools.WidgetUI

    # The modal UI component provides an element over the page. The modal layer
    # prevents the user from interacting with the page whilst allowing them to
    # interact with UI components above the layer, for example a dialog.

    constructor: (transparent, allowScrolling) ->
        super()

        # If true the modal we be displayed completely transparently. This can
        # be useful when displaying an UI component above the page that is
        # close if the user clicks away from it, for example the add link
        # (caption) dialog.
        @_transparent = transparent

        # If true then scrolling the page whilst the modal is open is not
        # disabled (the default behavior is to disable scrolling when a modal is
        # overlayed over the page content).
        @_allowScrolling =  allowScrolling

    # Methods

    mount: () ->
        # Mount the widget to the DOM

        # Modal
        @_domElement = @constructor.createDiv([
            'ct-widget',
            'ct-modal'
            ])
        @parent().domElement().appendChild(@_domElement)

        # If set to transparent add the modifier
        if @_transparent
            @addCSSClass('ct-modal--transparent')

        # Unless scrolling is set as allowed disable page scrolling
        if not @_allowScrolling
            ContentEdit.addCSSClass(document.body, 'ct--no-scroll')

        # Add interaction handlers
        @_addDOMEventListeners()

    unmount: () ->
        # Unmount the widget from the DOM

        # Allow the page to be scrolled again
        if not @_allowScrolling
            ContentEdit.removeCSSClass(document.body, 'ct--no-scroll')

        super()

    # Private methods

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget

        # Trigger a custom event for clicks on the modal
        @_domElement.addEventListener 'click', (ev) =>
            @dispatchEvent(@createEvent('click'))