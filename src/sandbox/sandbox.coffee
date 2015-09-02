window.onload = () ->

    ContentTools.IMAGE_UPLOADER = ImageUploader.createImageUploader

    # Build a palette of styles
    ContentTools.StylePalette.add([
        new ContentTools.Style('By-line', 'article__by-line', ['p']),
        new ContentTools.Style('Caption', 'article__caption', ['p']),
        new ContentTools.Style('Example', 'example', ['pre']),
        new ContentTools.Style('Example + Good', 'example--good', ['pre']),
        new ContentTools.Style('Example + Bad', 'example--bad', ['pre'])
        ])

    editor = new ContentTools.EditorApp.get()
    editor.init('.editable', 'data-name')

    editor.bind 'save', (regions, autoSave) ->
        # Handle the page being saved

        # Mark the ignition as busy while we save the page
        editor.busy(true)

        # Simulate saving the page
        saved = () =>

            # Save has completed set the app as no longer busy
            editor.busy(false)

            # Trigger a flash to indicate the save has been successful
            new ContentTools.FlashUI('ok')

        setTimeout(saved, 2000)