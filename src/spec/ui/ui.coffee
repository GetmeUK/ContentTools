# HACK: Disable getComputedStyle so that transitions/animations are not
# considered for the purpose of testing.
window.getComputedStyle = null

# HACK: Force the appVersion to be linux for testing
navigator.appVersion = 'Linux'


# UI

# ComponentUI

describe 'ContentTools.ComponentUI()', () ->

    it 'should return an instance of a ComponentUI', () ->

        component = new ContentTools.ComponentUI()
        expect(component instanceof ContentTools.ComponentUI).toBe true


describe 'ContentTools.ComponentUI.children()', () ->

    it 'should return a list of children attached to the component', () ->

        parent = new ContentTools.ComponentUI()
        child = new ContentTools.ComponentUI()
        parent.attach(child)

        expect(parent.children()).toEqual [child]


describe 'ContentTools.ComponentUI.domElement()', () ->

    it 'should return a DOM element for the component if it\'s mounted', () ->

        # Components can't mount themselves so we have to fake this by
        # associating a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        component._domElement = domElement

        expect(component.domElement()).toBe domElement


describe 'ContentTools.ComponentUI.isMounted()', () ->

    it 'should return true if the component is mounted', () ->
        component = new ContentTools.ComponentUI()

        # Initially the component isn't mounted
        expect(component.isMounted()).toBe false

        # Components can't mount themselves so we have to fake this by
        # associating a DOM element with the component manually.
        domElement = document.createElement('div')
        component._domElement = domElement

        expect(component.isMounted()).toBe true


describe 'ContentTools.ComponentUI.parent()', () ->

    it 'should return a the parent the component is attached to', () ->

        parent = new ContentTools.ComponentUI()
        child = new ContentTools.ComponentUI()
        parent.attach(child)

        expect(child.parent()).toBe parent


describe 'ContentTools.ComponentUI.attach()', () ->

    it 'should attach a component as a child of another component', () ->

        # NOTE: Currently this is a duplicate of the test for `children()`.
        parent = new ContentTools.ComponentUI()
        child = new ContentTools.ComponentUI()
        parent.attach(child)

        expect(parent.children()).toEqual [child]


describe 'ContentTools.ComponentUI.addCSSClass()', () ->

    it 'should add a CSS class to the component\'s DOM element', () ->

        # Components can't mount themselves so we have to fake this by
        # associating a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        component._domElement = domElement
        component.addCSSClass('foo')

        expect(domElement.getAttribute('class')).toBe 'foo'


describe 'ContentTools.ComponentUI.detatch()', () ->

    it 'should detatch a child component', () ->

        parent = new ContentTools.ComponentUI()
        child = new ContentTools.ComponentUI()
        parent.attach(child)
        parent.detatch(child)

        expect(parent.children()).toEqual []


describe 'ContentTools.ComponentUI.mount()', () ->

    it 'should do nothing, `mount()` is a placeholder method only', () ->

        component = new ContentTools.ComponentUI()
        component.mount()

        expect(component.isMounted()).toBe false


describe 'ContentTools.ComponentUI.removeCSSClass()', () ->

    it 'should remove a CSS class from the component\'s DOM element', () ->

        # Components can't mount themselves so we have to fake this by
        # associating a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        component._domElement = domElement
        component.addCSSClass('foo')
        component.addCSSClass('bar')
        component.removeCSSClass('foo')

        expect(domElement.getAttribute('class')).toBe 'bar'


describe 'ContentTools.ComponentUI.unmount()', () ->

    it 'should remove a CSS class from the component\'s DOM element', () ->

        # Components can't mount themselves so we have to fake this by
        # associating a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        document.body.appendChild(domElement)
        component._domElement = domElement
        component.unmount()

        expect(component.isMounted()).toBe false


describe 'ContentTools.ComponentUI.addEventListener()', () ->

    it 'should bind a function to be called whenever the named event is
        dispatched against the component', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a component and add an event listner
        component = new ContentTools.ComponentUI()
        component.addEventListener('foo', foo.handleFoo)

        # Dispatch the event
        ev = component.createEvent('foo', {'bar': 1})
        component.dispatchEvent(ev)

        expect(foo.handleFoo).toHaveBeenCalledWith(ev)


describe 'ContentTools.ComponentUI.createEvent()', () ->

    it 'should return an new event', () ->

        # Create a component to create an event against
        component = new ContentTools.ComponentUI()
        ev = new ContentTools.Event('foo', {bar: 1})

        expect(ev.name()).toBe 'foo'
        expect(ev.detail()).toEqual {bar: 1}


describe 'ContentTools.ComponentUI.dispatchEvent()', () ->

    it 'should dispatch an event against a component', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a component and add an event listner
        component = new ContentTools.ComponentUI()
        component.addEventListener('foo', foo.handleFoo)

        # Dispatch the event
        ev = component.createEvent('foo', {'bar': 1})
        component.dispatchEvent(ev)

        expect(foo.handleFoo).toHaveBeenCalledWith(ev)

    it 'should return false (prevent the default action) for the event if
        cancelled', () ->

        # Define a test component class that triggers an event when a method is
        # called.
        class TestComponent extends ContentTools.ComponentUI

            foo: () ->
                if @triggerEvent('foo')
                    @bar = 1

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: (ev) ->
                ev.preventDefault()
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a test component and add an event listner
        component = new TestComponent()
        component.addEventListener('foo', foo.handleFoo)

        # Dispatch the event
        ev = component.createEvent('foo', {'bar': 1})
        component.dispatchEvent(ev)

        expect(foo.handleFoo).toHaveBeenCalledWith(ev)
        expect(foo.bar).toBe undefined

    it 'should prevent stop calling listener functions once the event has been
        halted', () ->

        # Create a set of functions to call when the event is triggered
        foo = {
            handleBar: () ->
                return

            handleFoo: () ->
                ev.stopImmeditatePropagation()
                return
        }
        spyOn(foo, 'handleBar')
        spyOn(foo, 'handleFoo')

        # Create a component and add an event listner
        component = new ContentTools.ComponentUI()
        component.addEventListener('foo', foo.handleFoo)
        component.addEventListener('bar', foo.handleBar)

        # Dispatch the event
        ev = component.createEvent('foo', {'bar': 1})
        component.dispatchEvent(ev)

        expect(foo.handleFoo).toHaveBeenCalledWith(ev)
        expect(foo.handleBar).not.toHaveBeenCalled()


describe 'ContentTools.ComponentUI.removeEventListener()', () ->

    component = null
    listeners = null

    beforeEach ->
        listeners = {
            handleBar: () ->
                return

            handleFoo: () ->
                return

            handleZee: () ->
                return
        }
        spyOn(listeners, 'handleBar')
        spyOn(listeners, 'handleFoo')
        spyOn(listeners, 'handleZee')

        # Create an editable region
        component = new ContentTools.ComponentUI()
        component.addEventListener('foo', listeners.handleFoo)
        component.addEventListener('foo', listeners.handleBar)
        component.addEventListener('zee', listeners.handleZee)

    it 'should remove a single event listener against a component if called with
        an event name and the listener function', () ->

        # Remove an individual event listener
        component.removeEventListener('foo', listeners.handleFoo)

        # Dispatch foo event
        ev = component.createEvent('foo', {'bar': 1})
        component.dispatchEvent(ev)

        expect(listeners.handleFoo).not.toHaveBeenCalled()
        expect(listeners.handleBar).toHaveBeenCalled()

        # Dispatch zee event
        ev = component.createEvent('zee')
        component.dispatchEvent(ev)

        expect(listeners.handleZee).toHaveBeenCalled()

    it 'should remove multiple event listener against a component by
        name', () ->

        # Remove an individual event listener
        component.removeEventListener('foo')

        # Dispatch foo event
        ev = component.createEvent('foo')
        component.dispatchEvent(ev)

        expect(listeners.handleFoo).not.toHaveBeenCalled()
        expect(listeners.handleBar).not.toHaveBeenCalled()

        # Dispatch zee event
        ev = component.createEvent('zee')
        component.dispatchEvent(ev)

        expect(listeners.handleZee).toHaveBeenCalled()

    it 'should remove all event listener against a component if called without
        arguments', () ->

        # Remove an individual event listener
        component.removeEventListener()

        # Dispatch foo event
        ev = component.createEvent('foo')
        component.dispatchEvent(ev)

        expect(listeners.handleFoo).not.toHaveBeenCalled()
        expect(listeners.handleBar).not.toHaveBeenCalled()

        # Dispatch zee event
        ev = component.createEvent('zee')
        component.dispatchEvent(ev)

        expect(listeners.handleZee).not.toHaveBeenCalled()


describe 'ContentTools.ComponentUI.createDiv()', () ->

    it 'should create a DOM element with the specified classes, attributes and
            content', () ->

        domElement = ContentTools.ComponentUI.createDiv(
            ['foo'],
            {'bar': 'foo'},
            'foo bar'
            )

        expect(domElement.getAttribute('class')).toBe 'foo'
        expect(domElement.getAttribute('bar')).toBe 'foo'
        expect(domElement.innerHTML).toBe 'foo bar'


# WidgetUI

describe 'ContentTools.WidgetUI()', () ->

    it 'should return an instance of a WidgetUI', () ->

        widget = new ContentTools.WidgetUI()
        expect(widget instanceof ContentTools.WidgetUI).toBe true


describe 'ContentTools.WidgetUI.attach()', () ->

    it 'should attach a widget as a child of another widget and mount it', () ->

        parent = new ContentTools.WidgetUI()
        child = new ContentTools.WidgetUI()
        spyOn(child, 'mount')
        parent.attach(child)

        # Check the widget was added as a child
        expect(parent.children()).toEqual [child]

        # Check `mount` was called against the widget
        expect(child.mount).toHaveBeenCalledWith()


describe 'ContentTools.WidgetUI.detatch()', () ->

    it 'should detatch a child widget and unmount it', () ->

        parent = new ContentTools.WidgetUI()
        child = new ContentTools.WidgetUI()
        spyOn(child, 'unmount')
        parent.attach(child)

        # Widgets can't mount themselves so we have to fake this by associating
        # a DOM element with the widget manually.
        domElement = document.createElement('div')
        document.body.appendChild(domElement)
        parent._domElement = domElement
        parent.detatch(child)

        # Check the widget was removed as a child
        expect(parent.children()).toEqual []

        # Check `unmount` was called against the widget
        expect(child.unmount).toHaveBeenCalled()


describe 'ContentTools.WidgetUI.show()', () ->

    it 'should add the `--active` CSS modifier class to a widget', (done) ->

        widget = new ContentTools.WidgetUI()

        # Widgets can't mount themselves so we have to fake this by associating
        # a DOM element with the widget manually.
        domElement = document.createElement('div')
        document.body.appendChild(domElement)
        widget._domElement = domElement

        # Attach a fake mount method to allow the widget to remount itself
        widget.mount = () ->
            widget._domElement = domElement

        # Show the widget (there's a delay to allow any CSS transitions to
        # activate).
        widget.show()

        checkShown = () ->
            classes = widget.domElement().getAttribute('class').split(' ')
            expect(classes.indexOf('ct-widget--active') > -1).toBe true
            done();

        setTimeout(checkShown, 500)


describe 'ContentTools.WidgetUI.hide()', () ->

    widget = null

    beforeEach ->
        # Create a widget
        widget = new ContentTools.WidgetUI()

        # Widgets can't mount themselves so we have to fake this by associating
        # a DOM element with the widget manually.
        domElement = document.createElement('div')
        domElement.setAttribute('class', 'ct-widget')
        document.body.appendChild(domElement)
        widget._domElement = domElement

    it 'should remove the `--active` CSS modifier class from a
            widget', () ->

        widget.hide()

        classes = (widget.domElement().getAttribute('class') or '').split(' ')
        expect(classes.indexOf('ct-widget--active') == -1).toBe true

    it 'should unmount the component after X seconds', (done) ->

        widget.hide()

        checkUnmounted = () ->
            expect(widget.isMounted()).toBe false
            done();

        setTimeout(checkUnmounted, 500)


# AnchoredComponentUI

describe 'ContentTools.AnchoredComponentUI()', () ->

    it 'should return an instance of a AnchoredComponentUI', () ->

        anchored = new ContentTools.AnchoredComponentUI()
        expect(anchored instanceof ContentTools.AnchoredComponentUI).toBe true


describe 'ContentTools.AnchoredComponentUI.mount()', () ->

    it 'should mount the component to a DOM element', () ->

        domElement = document.createElement('div')
        parentDOMElement = document.createElement('div')

        anchored = new ContentTools.AnchoredComponentUI()

        # Components can't mount themselves so we have to fake this by
        # associating a DOM element with the component manually.
        anchored._domElement = domElement

        anchored.mount(parentDOMElement)

        expect(anchored.domElement().parentNode).toEqual parentDOMElement