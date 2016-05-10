window.onload = () ->

    ContentTools.IMAGE_UPLOADER = ImageUploader.createImageUploader

    # Uncomment the following lines to use the cloudinary image uploader
    #CloudinaryImageUploader.CLOUD_NAME = ''
    #CloudinaryImageUploader.UPLOAD_PRESET = ''
    #ContentTools.IMAGE_UPLOADER = (dialog) ->
    #    return CloudinaryImageUploader.createImageUploader(dialog)

    # Build a palette of styles
    ContentTools.StylePalette.add([
        new ContentTools.Style('By-line', 'article__by-line', ['p']),
        new ContentTools.Style('Caption', 'article__caption', ['p']),
        new ContentTools.Style('Example', 'example', ['pre']),
        new ContentTools.Style('Example + Good', 'example--good', ['pre']),
        new ContentTools.Style('Example + Bad', 'example--bad', ['pre'])
        ])

    editor = ContentTools.EditorApp.get()
    editor.init('[data-editable], [data-fixture]', 'data-name')

    editor.addEventListener 'saved', (ev) ->

        # Handle the page being saved
        console.log ev.detail().regions

        if Object.keys(ev.detail().regions).length == 0
            return

        # Mark the ignition as busy while we save the page
        editor.busy(true)

        # Simulate saving the page
        saved = () =>
            # Save has completed set the app as no longer busy
            editor.busy(false)

            # Trigger a flash to indicate the save has been successful
            new ContentTools.FlashUI('ok')

        setTimeout(saved, 2000)

    # Handle tools available to fixtures
    FIXTURE_TOOLS = [['undo', 'redo', 'remove']]
    ContentEdit.Root.get().bind 'focus', (element) ->
        # Determine what tools should be available to the user
        if element.isFixed()
            tools = FIXTURE_TOOLS
        else
            tools = ContentTools.DEFAULT_TOOLS

        # If the tools have changed update the toolboox
        if editor.toolbox().tools() != tools
            editor.toolbox().tools(tools)

    # Translation example
    req = new XMLHttpRequest()
    req.overrideMimeType('application/json')
    req.open(
        'GET',
        'https://raw.githubusercontent.com/GetmeUK/ContentTools/master/translations/lp.json',
        true
        )
    req.onreadystatechange = (ev) ->
        if ev.target.readyState == 4
            translations = JSON.parse(ev.target.responseText)
            ContentEdit.addTranslations('lp', translations)
            ContentEdit.LANGUAGE = 'lp'

    # Uncomment the following line to use the editor with pig latin translation
    #req.send(null)