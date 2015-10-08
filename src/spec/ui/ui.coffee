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

        # Component can't mount themselves so we have to fake this by
        # assocaiting a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        component._domElement = domElement

        expect(component.domElement()).toBe domElement


describe 'ContentTools.ComponentUI.isMounted()', () ->

    it 'should return true if the component is mounted', () ->
        component = new ContentTools.ComponentUI()

        # Initially the component isn't mounted
        expect(component.isMounted()).toBe false

        # Component can't mount themselves so we have to fake this by
        # assocaiting a DOM element with the component manually.
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

        # Component can't mount themselves so we have to fake this by
        # assocaiting a DOM element with the component manually.
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

        # Component can't mount themselves so we have to fake this by
        # assocaiting a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        component._domElement = domElement
        component.addCSSClass('foo')
        component.addCSSClass('bar')
        component.removeCSSClass('foo')

        expect(domElement.getAttribute('class')).toBe 'bar'


describe 'ContentTools.ComponentUI.unmount()', () ->

    it 'should remove a CSS class from the component\'s DOM element', () ->

        # Component can't mount themselves so we have to fake this by
        # assocaiting a DOM element with the component manually.
        component = new ContentTools.ComponentUI()
        domElement = document.createElement('div')
        document.body.appendChild(domElement)
        component._domElement = domElement
        component.unmount()

        expect(component.isMounted()).toBe false


describe 'ContentTools.ComponentUI.bind()', () ->

    it 'should bind a function so that it\'s called whenever the event is \
        triggered against the component', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a component and bind the function to an event
        component = new ContentTools.ComponentUI()
        component.bind('foo', foo.handleFoo)

        # Trigger the event
        component.trigger('foo')

        expect(foo.handleFoo).toHaveBeenCalled()


describe 'ContentTools.ComponentUI.trigger()', () ->

    it 'should trigger an event against the component with specified \
        arguments', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Create a component and bind the function to an event
        component = new ContentTools.ComponentUI()
        component.bind('foo', foo.handleFoo)

        # Trigger the event
        component.trigger('foo', 123)

        expect(foo.handleFoo).toHaveBeenCalledWith(123)


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