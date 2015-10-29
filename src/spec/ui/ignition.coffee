# IgnitionUI

describe 'ContentTools.IgnitionUI', () ->

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


    describe 'ContentTools.IgnitionUI()', () ->

        it 'should return an instance of a IgnitionUI', () ->

            ignition = new ContentTools.IgnitionUI()
            expect(ignition instanceof ContentTools.IgnitionUI).toBe true


    describe 'ContentTools.IgnitionUI.busy()', () ->

        it 'should set/get the busy state for the ignition', () ->

            ignition = new ContentTools.IgnitionUI()

            # Check that the default ignition busy state is false
            expect(ignition.busy()).toBe false

            # Check we can change it
            ignition.busy(true)
            expect(ignition.busy()).toBe true


    describe 'ContentTools.IgnitionUI.changeState()', () ->

        it 'should change the state of the ignition switch to editing', () ->

            ignition = editor._ignition
            ignition.changeState('editing')

            # Check the correct modifier class has been applied
            classes = ignition.domElement().getAttribute('class').split(' ')
            expect(classes.indexOf('ct-ignition--editing') > -1).toBe true

        it 'should change the state of the ignition switch to ready', () ->

            ignition = editor._ignition
            ignition.changeState('editing')
            ignition.changeState('ready')

            # Check the correct modifier class has been applied
            classes = ignition.domElement().getAttribute('class').split(' ')
            expect(classes.indexOf('ct-ignition--ready') > -1).toBe true


    describe 'ContentTools.IgnitionUI.mount()', () ->

        it 'should mount the component', () ->

            ignition = new ContentTools.IgnitionUI()
            editor.attach(ignition)
            ignition.mount()
            expect(ignition.isMounted()).toBe true


    describe 'ContentTools.IgnitionUI.unmount()', () ->

        it 'should unmount the component', () ->

            ignition = new ContentTools.IgnitionUI()
            editor.attach(ignition)
            ignition.mount()
            ignition.unmount()
            expect(ignition.isMounted()).toBe false


    # Events

    describe 'ContentTools.IgnitionUI > Events', () ->

        it 'should trigger a `start` event if edit button clicked', () ->

            ignition = editor._ignition

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: () ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.bind('start', foo.handleFoo)

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)
            ignition._domEdit.dispatchEvent(clickEvent)

            expect(foo.handleFoo).toHaveBeenCalled()

        it 'should trigger a `stop` event with a value of true if confirm button
                button clicked', () ->

            ignition = editor._ignition

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: (confirmed) ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.bind('stop', foo.handleFoo)

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)
            ignition._domConfirm.dispatchEvent(clickEvent)

            expect(foo.handleFoo).toHaveBeenCalledWith(true)

        it 'should trigger a `stop` event with a value of false if cancel button
                clicked', () ->

            ignition = editor._ignition

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: (confirmed) ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.bind('stop', foo.handleFoo)

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)

            ignition._domEdit.dispatchEvent(clickEvent)
            ContentEdit.Root.get().commit()
            ignition._domCancel.dispatchEvent(clickEvent)

            expect(foo.handleFoo).toHaveBeenCalledWith(false)