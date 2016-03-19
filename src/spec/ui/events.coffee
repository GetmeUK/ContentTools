# UI

# Events

describe 'ContentTools.Event', () ->

    describe 'ContentTools.Event()', () ->

        it 'should return an instance of an Event', () ->

            ev = new ContentTools.Event('test')
            expect(ev instanceof ContentTools.Event).toBe true


    describe 'ContentTools.Event.defaultPrevented()', () ->

        it 'should return true if the event is cancelled', () ->

            ev = new ContentTools.Event('test')
            expect(ev.defaultPrevented()).toBe false
            ev.preventDefault()
            expect(ev.defaultPrevented()).toBe true


    describe 'ContentTools.Event.detail()', () ->

        it 'should return the detail of the event', () ->

            ev = new ContentTools.Event('test', {foo: 1})
            expect(ev.detail()).toEqual {foo: 1}


    describe 'ContentTools.Event.name()', () ->

        it 'should return the name of the event', () ->

            ev = new ContentTools.Event('test')
            expect(ev.name()).toBe 'test'


    describe 'ContentTools.Event.propagationStopped()', () ->

        it 'should return true if the event has been halted', () ->

            ev = new ContentTools.Event('test')
            expect(ev.propagationStopped()).toBe false
            ev.stopImmediatePropagation()
            expect(ev.propagationStopped()).toBe true

    describe 'ContentTools.Event.propagationStopped()', () ->

        it 'should return a timestamp of when the event was created', () ->

            ev = new ContentTools.Event('test')
            expect(ev.timeStamp()).toBeCloseTo Date.now(), 100


    describe 'ContentTools.Event.preventDefault()', () ->

        it 'should cancel an event', () ->

            ev = new ContentTools.Event('test')
            ev.preventDefault()
            expect(ev.defaultPrevented()).toBe true


    describe 'ContentTools.Event.preventDefault()', () ->

        it 'should halt an event', () ->

            ev = new ContentTools.Event('test')
            ev.stopImmediatePropagation()
            expect(ev.propagationStopped()).toBe true