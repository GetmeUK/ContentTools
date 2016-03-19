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

        it 'should set/unset the ignition to busy', () ->

            ignition = new ContentTools.IgnitionUI()

            # Check that the default ignition busy state is false
            expect(ignition.state()).toBe 'ready'

            # Check we can change it
            ignition.busy(true)
            expect(ignition.state()).toBe 'busy'

            # Check we can change it back
            ignition.busy(false)
            expect(ignition.state()).toBe 'ready'


    describe 'ContentTools.IgnitionUI.cancel()', () ->

        it 'should set the ignition to editing and trigger the cancel
            event', () ->

            # Set the ignition to editing
            ignition = new ContentTools.IgnitionUI()
            ignition.state('editing')

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: () ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.addEventListener('cancel', foo.handleFoo)

            # Trigger the cancel event
            ignition.cancel()

            expect(foo.handleFoo).toHaveBeenCalled()
            expect(ignition.state()).toBe 'ready'

    describe 'ContentTools.IgnitionUI.confim()', () ->

        it 'should set the ignition to ready and trigger the confirm
            event', () ->

            # Set the ignition to editing
            ignition = new ContentTools.IgnitionUI()
            ignition.state('editing')

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: () ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.addEventListener('confirm', foo.handleFoo)

            # Trigger the confirm event
            ignition.confirm()

            expect(foo.handleFoo).toHaveBeenCalled()
            expect(ignition.state()).toBe 'ready'


    describe 'ContentTools.IgnitionUI.edit()', () ->

        it 'should set the ignition to editing and trigger the edit
            event', () ->

            # Set the ignition to editing
            ignition = new ContentTools.IgnitionUI()
            ignition.state('ready')

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: () ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.addEventListener('edit', foo.handleFoo)

            # Trigger the edit event
            ignition.edit()

            expect(foo.handleFoo).toHaveBeenCalled()
            expect(ignition.state()).toBe 'editing'


    describe 'ContentTools.IgnitionUI.mount()', () ->

        it 'should mount the component', () ->

            ignition = new ContentTools.IgnitionUI()
            editor.attach(ignition)
            ignition.mount()
            expect(ignition.isMounted()).toBe true


    describe 'ContentTools.IgnitionUI.state()', () ->

        it 'should change the state of the ignition switch', () ->

            # Set the ignition to editing
            ignition = new ContentTools.IgnitionUI()
            ignition.state('ready')

            # Create function we can spy on to ensure the event is triggered
            foo = {
                handleFoo: () ->
                    return
            }
            spyOn(foo, 'handleFoo')

            # Bind the spied on function to the event
            ignition.addEventListener('statechange', foo.handleFoo)

            # Trigger the edit event
            ignition.state('editing')

            expect(foo.handleFoo).toHaveBeenCalled()
            expect(ignition.state()).toBe 'editing'

        it 'should get the state of the iginition switch', () ->

            # Set the ignition to editing
            ignition = new ContentTools.IgnitionUI()
            expect(ignition.state()).toBe 'ready'

            ignition.edit()
            expect(ignition.state()).toBe 'editing'

            ignition.busy(true)
            expect(ignition.state()).toBe 'busy'


    describe 'ContentTools.IgnitionUI.unmount()', () ->

        it 'should unmount the component', () ->

            ignition = new ContentTools.IgnitionUI()
            editor.attach(ignition)
            ignition.mount()
            ignition.unmount()
            expect(ignition.isMounted()).toBe false


    # Events

    describe 'ContentTools.IgnitionUI > Events', () ->

        it 'should call `edit` when edit button is clicked', () ->

            ignition = editor._ignition

            # Spy on the edit methof
            spyOn(ignition, 'edit')

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)
            ignition._domEdit.dispatchEvent(clickEvent)

            expect(ignition.edit).toHaveBeenCalled()

        it 'should call `cancel` when cancel button is clicked', () ->

            ignition = editor._ignition

            # Spy on the edit methof
            spyOn(ignition, 'cancel')

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)
            ignition._domCancel.dispatchEvent(clickEvent)

            expect(ignition.cancel).toHaveBeenCalled()

        it 'should call `confirm` when confirm button is clicked', () ->

            ignition = editor._ignition

            # Spy on the edit methof
            spyOn(ignition, 'confirm')

            # Create a fake click event against the modal's DOM element
            clickEvent = document.createEvent('CustomEvent')
            clickEvent.initCustomEvent('click', false, false, null)
            ignition._domConfirm.dispatchEvent(clickEvent)

            expect(ignition.confirm).toHaveBeenCalled()