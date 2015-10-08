class ContentTools.FlashUI extends ContentTools.AnchoredComponentUI

    # A flash is a visual indicator displayed typically once a task has been
    # completed, for example it might show that a save has been successful (or
    # failed).
    #
    # Flashes are short lived instances, they display as soon as mounted and are
    # unmount as soon as they're animation has finished. As such references to
    # flash instances should not be stored, e.g:
    #
    # new ContentTools.FlashUI('ok')

    constructor: (modifier) ->
        super()
        @mount(modifier)

    # Methods

    mount: (modifier) ->
        # Mount the flash to the interface, the specified modifier will be
        # applied as a CSS modifier class to change the icon displayed in the
        # flash.

        # Create the flash
        @_domElement = @constructor.createDiv([
            'ct-flash',
            'ct-flash--active',
            "ct-flash--#{ modifier }",
            'ct-widget',
            'ct-widget--active',
            ])

        # Anchor it to the app
        super(ContentTools.EditorApp.get().domElement())

        # Monitor for when the element is no long visible, at which point we can
        # remove it.
        monitorForHidden = () =>

            # If there's no support for `getComputedStyle` then we fallback to
            # unmounting the widget immediately.
            unless window.getComputedStyle
                @unmount()
                return

            # If the widget is now hidden we unmount it
            if parseFloat(window.getComputedStyle(@_domElement).opacity) < 0.01
                @unmount()
            else
                setTimeout(monitorForHidden, 250)

        setTimeout(monitorForHidden, 250)