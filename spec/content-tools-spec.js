(function() {
  var CEFactory, editor, toolShelf,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe('ContentTools.getEmbedVideoURL()', function() {
    it('should return a valid video embbed URL from a youtube URL', function() {
      var embedURL, insecureURL, pageURL, shareURL;
      embedURL = 'https://www.youtube.com/embed/t4gjl-uwUHc';
      expect(ContentTools.getEmbedVideoURL(embedURL)).toBe(embedURL);
      shareURL = 'https://youtu.be/t4gjl-uwUHc';
      expect(ContentTools.getEmbedVideoURL(shareURL)).toBe(embedURL);
      pageURL = 'https://www.youtube.com/watch?v=t4gjl-uwUHc';
      expect(ContentTools.getEmbedVideoURL(pageURL)).toBe(embedURL);
      insecureURL = 'http://www.youtube.com/watch?v=t4gjl-uwUHc';
      return expect(ContentTools.getEmbedVideoURL(insecureURL)).toBe(embedURL);
    });
    return it('should return a valid video embbed URL from a vimeo URL', function() {
      var embedURL, insecureURL, pageURL;
      embedURL = 'https://player.vimeo.com/video/1084537';
      expect(ContentTools.getEmbedVideoURL(embedURL)).toBe(embedURL);
      pageURL = 'https://vimeo.com/1084537';
      expect(ContentTools.getEmbedVideoURL(pageURL)).toBe(embedURL);
      insecureURL = 'http://vimeo.com/1084537';
      return expect(ContentTools.getEmbedVideoURL(insecureURL)).toBe(embedURL);
    });
  });

  window.getComputedStyle = null;

  navigator.appVersion = 'Linux';

  describe('ContentTools.ComponentUI()', function() {
    return it('should return an instance of a ComponentUI', function() {
      var component;
      component = new ContentTools.ComponentUI();
      return expect(component instanceof ContentTools.ComponentUI).toBe(true);
    });
  });

  describe('ContentTools.ComponentUI.children()', function() {
    return it('should return a list of children attached to the component', function() {
      var child, parent;
      parent = new ContentTools.ComponentUI();
      child = new ContentTools.ComponentUI();
      parent.attach(child);
      return expect(parent.children()).toEqual([child]);
    });
  });

  describe('ContentTools.ComponentUI.domElement()', function() {
    return it('should return a DOM element for the component if it\'s mounted', function() {
      var component, domElement;
      component = new ContentTools.ComponentUI();
      domElement = document.createElement('div');
      component._domElement = domElement;
      return expect(component.domElement()).toBe(domElement);
    });
  });

  describe('ContentTools.ComponentUI.isMounted()', function() {
    return it('should return true if the component is mounted', function() {
      var component, domElement;
      component = new ContentTools.ComponentUI();
      expect(component.isMounted()).toBe(false);
      domElement = document.createElement('div');
      component._domElement = domElement;
      return expect(component.isMounted()).toBe(true);
    });
  });

  describe('ContentTools.ComponentUI.parent()', function() {
    return it('should return a the parent the component is attached to', function() {
      var child, parent;
      parent = new ContentTools.ComponentUI();
      child = new ContentTools.ComponentUI();
      parent.attach(child);
      return expect(child.parent()).toBe(parent);
    });
  });

  describe('ContentTools.ComponentUI.attach()', function() {
    return it('should attach a component as a child of another component', function() {
      var child, parent;
      parent = new ContentTools.ComponentUI();
      child = new ContentTools.ComponentUI();
      parent.attach(child);
      return expect(parent.children()).toEqual([child]);
    });
  });

  describe('ContentTools.ComponentUI.addCSSClass()', function() {
    return it('should add a CSS class to the component\'s DOM element', function() {
      var component, domElement;
      component = new ContentTools.ComponentUI();
      domElement = document.createElement('div');
      component._domElement = domElement;
      component.addCSSClass('foo');
      return expect(domElement.getAttribute('class')).toBe('foo');
    });
  });

  describe('ContentTools.ComponentUI.detatch()', function() {
    return it('should detatch a child component', function() {
      var child, parent;
      parent = new ContentTools.ComponentUI();
      child = new ContentTools.ComponentUI();
      parent.attach(child);
      parent.detatch(child);
      return expect(parent.children()).toEqual([]);
    });
  });

  describe('ContentTools.ComponentUI.mount()', function() {
    return it('should do nothing, `mount()` is a placeholder method only', function() {
      var component;
      component = new ContentTools.ComponentUI();
      component.mount();
      return expect(component.isMounted()).toBe(false);
    });
  });

  describe('ContentTools.ComponentUI.removeCSSClass()', function() {
    return it('should remove a CSS class from the component\'s DOM element', function() {
      var component, domElement;
      component = new ContentTools.ComponentUI();
      domElement = document.createElement('div');
      component._domElement = domElement;
      component.addCSSClass('foo');
      component.addCSSClass('bar');
      component.removeCSSClass('foo');
      return expect(domElement.getAttribute('class')).toBe('bar');
    });
  });

  describe('ContentTools.ComponentUI.unmount()', function() {
    return it('should remove a CSS class from the component\'s DOM element', function() {
      var component, domElement;
      component = new ContentTools.ComponentUI();
      domElement = document.createElement('div');
      document.body.appendChild(domElement);
      component._domElement = domElement;
      component.unmount();
      return expect(component.isMounted()).toBe(false);
    });
  });

  describe('ContentTools.ComponentUI.addEventListener()', function() {
    return it('should bind a function to be called whenever the named event is dispatched against the component', function() {
      var component, ev, foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      component = new ContentTools.ComponentUI();
      component.addEventListener('foo', foo.handleFoo);
      ev = component.createEvent('foo', {
        'bar': 1
      });
      component.dispatchEvent(ev);
      return expect(foo.handleFoo).toHaveBeenCalledWith(ev);
    });
  });

  describe('ContentTools.ComponentUI.createEvent()', function() {
    return it('should return an new event', function() {
      var component, ev;
      component = new ContentTools.ComponentUI();
      ev = new ContentTools.Event('foo', {
        bar: 1
      });
      expect(ev.name()).toBe('foo');
      return expect(ev.detail()).toEqual({
        bar: 1
      });
    });
  });

  describe('ContentTools.ComponentUI.dispatchEvent()', function() {
    it('should dispatch an event against a component', function() {
      var component, ev, foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      component = new ContentTools.ComponentUI();
      component.addEventListener('foo', foo.handleFoo);
      ev = component.createEvent('foo', {
        'bar': 1
      });
      component.dispatchEvent(ev);
      return expect(foo.handleFoo).toHaveBeenCalledWith(ev);
    });
    it('should return false (prevent the default action) for the event if cancelled', function() {
      var TestComponent, component, ev, foo;
      TestComponent = (function(_super) {
        __extends(TestComponent, _super);

        function TestComponent() {
          return TestComponent.__super__.constructor.apply(this, arguments);
        }

        TestComponent.prototype.foo = function() {
          if (this.triggerEvent('foo')) {
            return this.bar = 1;
          }
        };

        return TestComponent;

      })(ContentTools.ComponentUI);
      foo = {
        handleFoo: function(ev) {
          ev.preventDefault();
        }
      };
      spyOn(foo, 'handleFoo');
      component = new TestComponent();
      component.addEventListener('foo', foo.handleFoo);
      ev = component.createEvent('foo', {
        'bar': 1
      });
      component.dispatchEvent(ev);
      expect(foo.handleFoo).toHaveBeenCalledWith(ev);
      return expect(foo.bar).toBe(void 0);
    });
    return it('should prevent stop calling listener functions once the event has been halted', function() {
      var component, ev, foo;
      foo = {
        handleBar: function() {},
        handleFoo: function() {
          ev.stopImmeditatePropagation();
        }
      };
      spyOn(foo, 'handleBar');
      spyOn(foo, 'handleFoo');
      component = new ContentTools.ComponentUI();
      component.addEventListener('foo', foo.handleFoo);
      component.addEventListener('bar', foo.handleBar);
      ev = component.createEvent('foo', {
        'bar': 1
      });
      component.dispatchEvent(ev);
      expect(foo.handleFoo).toHaveBeenCalledWith(ev);
      return expect(foo.handleBar).not.toHaveBeenCalled();
    });
  });

  describe('ContentTools.ComponentUI.removeEventListener()', function() {
    var component, listeners;
    component = null;
    listeners = null;
    beforeEach(function() {
      listeners = {
        handleBar: function() {},
        handleFoo: function() {},
        handleZee: function() {}
      };
      spyOn(listeners, 'handleBar');
      spyOn(listeners, 'handleFoo');
      spyOn(listeners, 'handleZee');
      component = new ContentTools.ComponentUI();
      component.addEventListener('foo', listeners.handleFoo);
      component.addEventListener('foo', listeners.handleBar);
      return component.addEventListener('zee', listeners.handleZee);
    });
    it('should remove a single event listener against a component if called with an event name and the listener function', function() {
      var ev;
      component.removeEventListener('foo', listeners.handleFoo);
      ev = component.createEvent('foo', {
        'bar': 1
      });
      component.dispatchEvent(ev);
      expect(listeners.handleFoo).not.toHaveBeenCalled();
      expect(listeners.handleBar).toHaveBeenCalled();
      ev = component.createEvent('zee');
      component.dispatchEvent(ev);
      return expect(listeners.handleZee).toHaveBeenCalled();
    });
    it('should remove multiple event listener against a component by name', function() {
      var ev;
      component.removeEventListener('foo');
      ev = component.createEvent('foo');
      component.dispatchEvent(ev);
      expect(listeners.handleFoo).not.toHaveBeenCalled();
      expect(listeners.handleBar).not.toHaveBeenCalled();
      ev = component.createEvent('zee');
      component.dispatchEvent(ev);
      return expect(listeners.handleZee).toHaveBeenCalled();
    });
    return it('should remove all event listener against a component if called without arguments', function() {
      var ev;
      component.removeEventListener();
      ev = component.createEvent('foo');
      component.dispatchEvent(ev);
      expect(listeners.handleFoo).not.toHaveBeenCalled();
      expect(listeners.handleBar).not.toHaveBeenCalled();
      ev = component.createEvent('zee');
      component.dispatchEvent(ev);
      return expect(listeners.handleZee).not.toHaveBeenCalled();
    });
  });

  describe('ContentTools.ComponentUI.createDiv()', function() {
    return it('should create a DOM element with the specified classes, attributes and content', function() {
      var domElement;
      domElement = ContentTools.ComponentUI.createDiv(['foo'], {
        'bar': 'foo'
      }, 'foo bar');
      expect(domElement.getAttribute('class')).toBe('foo');
      expect(domElement.getAttribute('bar')).toBe('foo');
      return expect(domElement.innerHTML).toBe('foo bar');
    });
  });

  describe('ContentTools.WidgetUI()', function() {
    return it('should return an instance of a WidgetUI', function() {
      var widget;
      widget = new ContentTools.WidgetUI();
      return expect(widget instanceof ContentTools.WidgetUI).toBe(true);
    });
  });

  describe('ContentTools.WidgetUI.attach()', function() {
    return it('should attach a widget as a child of another widget and mount it', function() {
      var child, parent;
      parent = new ContentTools.WidgetUI();
      child = new ContentTools.WidgetUI();
      spyOn(child, 'mount');
      parent.attach(child);
      expect(parent.children()).toEqual([child]);
      return expect(child.mount).toHaveBeenCalledWith();
    });
  });

  describe('ContentTools.WidgetUI.detatch()', function() {
    return it('should detatch a child widget and unmount it', function() {
      var child, domElement, parent;
      parent = new ContentTools.WidgetUI();
      child = new ContentTools.WidgetUI();
      spyOn(child, 'unmount');
      parent.attach(child);
      domElement = document.createElement('div');
      document.body.appendChild(domElement);
      parent._domElement = domElement;
      parent.detatch(child);
      expect(parent.children()).toEqual([]);
      return expect(child.unmount).toHaveBeenCalled();
    });
  });

  describe('ContentTools.WidgetUI.show()', function() {
    return it('should add the `--active` CSS modifier class to a widget', function(done) {
      var checkShown, domElement, widget;
      widget = new ContentTools.WidgetUI();
      domElement = document.createElement('div');
      document.body.appendChild(domElement);
      widget._domElement = domElement;
      widget.show();
      checkShown = function() {
        var classes;
        classes = widget.domElement().getAttribute('class').split(' ');
        expect(classes.indexOf('ct-widget--active') > -1).toBe(true);
        return done();
      };
      return setTimeout(checkShown, 500);
    });
  });

  describe('ContentTools.WidgetUI.hide()', function() {
    var widget;
    widget = null;
    beforeEach(function() {
      var domElement;
      widget = new ContentTools.WidgetUI();
      domElement = document.createElement('div');
      domElement.setAttribute('class', 'ct-widget');
      document.body.appendChild(domElement);
      return widget._domElement = domElement;
    });
    it('should remove the `--active` CSS modifier class from a widget', function() {
      var classes;
      widget.hide();
      classes = (widget.domElement().getAttribute('class') || '').split(' ');
      return expect(classes.indexOf('ct-widget--active') === -1).toBe(true);
    });
    return it('should unmount the component after X seconds', function(done) {
      var checkUnmounted;
      widget.hide();
      checkUnmounted = function() {
        expect(widget.isMounted()).toBe(false);
        return done();
      };
      return setTimeout(checkUnmounted, 500);
    });
  });

  describe('ContentTools.AnchoredComponentUI()', function() {
    return it('should return an instance of a AnchoredComponentUI', function() {
      var anchored;
      anchored = new ContentTools.AnchoredComponentUI();
      return expect(anchored instanceof ContentTools.AnchoredComponentUI).toBe(true);
    });
  });

  describe('ContentTools.AnchoredComponentUI.mount()', function() {
    return it('should mount the component to a DOM element', function() {
      var anchored, domElement, parentDOMElement;
      domElement = document.createElement('div');
      parentDOMElement = document.createElement('div');
      anchored = new ContentTools.AnchoredComponentUI();
      anchored._domElement = domElement;
      anchored.mount(parentDOMElement);
      return expect(anchored.domElement().parentNode).toEqual(parentDOMElement);
    });
  });

  describe('ContentTools.Event', function() {
    describe('ContentTools.Event()', function() {
      return it('should return an instance of an Event', function() {
        var ev;
        ev = new ContentTools.Event('test');
        return expect(ev instanceof ContentTools.Event).toBe(true);
      });
    });
    describe('ContentTools.Event.defaultPrevented()', function() {
      return it('should return true if the event is cancelled', function() {
        var ev;
        ev = new ContentTools.Event('test');
        expect(ev.defaultPrevented()).toBe(false);
        ev.preventDefault();
        return expect(ev.defaultPrevented()).toBe(true);
      });
    });
    describe('ContentTools.Event.detail()', function() {
      return it('should return the detail of the event', function() {
        var ev;
        ev = new ContentTools.Event('test', {
          foo: 1
        });
        return expect(ev.detail()).toEqual({
          foo: 1
        });
      });
    });
    describe('ContentTools.Event.name()', function() {
      return it('should return the name of the event', function() {
        var ev;
        ev = new ContentTools.Event('test');
        return expect(ev.name()).toBe('test');
      });
    });
    describe('ContentTools.Event.propagationStopped()', function() {
      return it('should return true if the event has been halted', function() {
        var ev;
        ev = new ContentTools.Event('test');
        expect(ev.propagationStopped()).toBe(false);
        ev.stopImmediatePropagation();
        return expect(ev.propagationStopped()).toBe(true);
      });
    });
    describe('ContentTools.Event.propagationStopped()', function() {
      return it('should return a timestamp of when the event was created', function() {
        var ev;
        ev = new ContentTools.Event('test');
        return expect(ev.timeStamp()).toBeCloseTo(Date.now(), 100);
      });
    });
    describe('ContentTools.Event.preventDefault()', function() {
      return it('should cancel an event', function() {
        var ev;
        ev = new ContentTools.Event('test');
        ev.preventDefault();
        return expect(ev.defaultPrevented()).toBe(true);
      });
    });
    return describe('ContentTools.Event.preventDefault()', function() {
      return it('should halt an event', function() {
        var ev;
        ev = new ContentTools.Event('test');
        ev.stopImmediatePropagation();
        return expect(ev.propagationStopped()).toBe(true);
      });
    });
  });

  describe('ContentTools.FlashUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.FlashUI()', function() {
      it('should return an instance of a FlashUI', function() {
        var flash;
        flash = new ContentTools.FlashUI(editor, 'ok');
        return expect(flash instanceof ContentTools.FlashUI).toBe(true);
      });
      it('should mount the component', function() {
        var flash;
        flash = new ContentTools.FlashUI(editor, 'ok');
        return expect(flash.isMounted()).toBe(true);
      });
      return it('should unmount the component after X seconds', function(done) {
        var checkUnmounted, flash;
        flash = new ContentTools.FlashUI(editor, 'ok');
        checkUnmounted = function() {
          expect(flash.isMounted()).toBe(false);
          return done();
        };
        return setTimeout(checkUnmounted, 500);
      });
    });
    return describe('ContentTools.FlashUI.mount()', function() {
      return it('should mount the component and apply the specified modifier', function() {
        var classes, flash;
        flash = new ContentTools.FlashUI(editor, 'ok');
        expect(flash.isMounted()).toBe(true);
        classes = flash.domElement().getAttribute('class').split(' ');
        return expect(classes.indexOf('ct-flash--ok') > -1).toBe(true);
      });
    });
  });

  describe('ContentTools.IgnitionUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.IgnitionUI()', function() {
      return it('should return an instance of a IgnitionUI', function() {
        var ignition;
        ignition = new ContentTools.IgnitionUI();
        return expect(ignition instanceof ContentTools.IgnitionUI).toBe(true);
      });
    });
    describe('ContentTools.IgnitionUI.busy()', function() {
      return it('should set/unset the ignition to busy', function() {
        var ignition;
        ignition = new ContentTools.IgnitionUI();
        expect(ignition.state()).toBe('ready');
        ignition.busy(true);
        expect(ignition.state()).toBe('busy');
        ignition.busy(false);
        return expect(ignition.state()).toBe('ready');
      });
    });
    describe('ContentTools.IgnitionUI.cancel()', function() {
      return it('should set the ignition to editing and trigger the cancel event', function() {
        var foo, ignition;
        ignition = new ContentTools.IgnitionUI();
        ignition.state('editing');
        foo = {
          handleFoo: function() {}
        };
        spyOn(foo, 'handleFoo');
        ignition.addEventListener('cancel', foo.handleFoo);
        ignition.cancel();
        expect(foo.handleFoo).toHaveBeenCalled();
        return expect(ignition.state()).toBe('ready');
      });
    });
    describe('ContentTools.IgnitionUI.confim()', function() {
      return it('should set the ignition to ready and trigger the confirm event', function() {
        var foo, ignition;
        ignition = new ContentTools.IgnitionUI();
        ignition.state('editing');
        foo = {
          handleFoo: function() {}
        };
        spyOn(foo, 'handleFoo');
        ignition.addEventListener('confirm', foo.handleFoo);
        ignition.confirm();
        expect(foo.handleFoo).toHaveBeenCalled();
        return expect(ignition.state()).toBe('ready');
      });
    });
    describe('ContentTools.IgnitionUI.edit()', function() {
      return it('should set the ignition to editing and trigger the edit event', function() {
        var foo, ignition;
        ignition = new ContentTools.IgnitionUI();
        ignition.state('ready');
        foo = {
          handleFoo: function() {}
        };
        spyOn(foo, 'handleFoo');
        ignition.addEventListener('edit', foo.handleFoo);
        ignition.edit();
        expect(foo.handleFoo).toHaveBeenCalled();
        return expect(ignition.state()).toBe('editing');
      });
    });
    describe('ContentTools.IgnitionUI.mount()', function() {
      return it('should mount the component', function() {
        var ignition;
        ignition = new ContentTools.IgnitionUI();
        editor.attach(ignition);
        ignition.mount();
        return expect(ignition.isMounted()).toBe(true);
      });
    });
    describe('ContentTools.IgnitionUI.state()', function() {
      it('should change the state of the ignition switch', function() {
        var foo, ignition;
        ignition = new ContentTools.IgnitionUI();
        ignition.state('ready');
        foo = {
          handleFoo: function() {}
        };
        spyOn(foo, 'handleFoo');
        ignition.addEventListener('statechange', foo.handleFoo);
        ignition.state('editing');
        expect(foo.handleFoo).toHaveBeenCalled();
        return expect(ignition.state()).toBe('editing');
      });
      return it('should get the state of the iginition switch', function() {
        var ignition;
        ignition = new ContentTools.IgnitionUI();
        expect(ignition.state()).toBe('ready');
        ignition.edit();
        expect(ignition.state()).toBe('editing');
        ignition.busy(true);
        return expect(ignition.state()).toBe('busy');
      });
    });
    describe('ContentTools.IgnitionUI.unmount()', function() {
      return it('should unmount the component', function() {
        var ignition;
        ignition = new ContentTools.IgnitionUI();
        editor.attach(ignition);
        ignition.mount();
        ignition.unmount();
        return expect(ignition.isMounted()).toBe(false);
      });
    });
    return describe('ContentTools.IgnitionUI > Events', function() {
      it('should call `edit` when edit button is clicked', function() {
        var clickEvent, ignition;
        ignition = editor._ignition;
        spyOn(ignition, 'edit');
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        ignition._domEdit.dispatchEvent(clickEvent);
        return expect(ignition.edit).toHaveBeenCalled();
      });
      it('should call `cancel` when cancel button is clicked', function() {
        var clickEvent, ignition;
        ignition = editor._ignition;
        spyOn(ignition, 'cancel');
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        ignition._domCancel.dispatchEvent(clickEvent);
        return expect(ignition.cancel).toHaveBeenCalled();
      });
      return it('should call `confirm` when confirm button is clicked', function() {
        var clickEvent, ignition;
        ignition = editor._ignition;
        spyOn(ignition, 'confirm');
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        ignition._domConfirm.dispatchEvent(clickEvent);
        return expect(ignition.confirm).toHaveBeenCalled();
      });
    });
  });

  describe('ContentTools.InspectorUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      div.setAttribute('id', 'foo');
      document.body.appendChild(div);
      div.innerHTML = '<p>bar</p>\n<ul>\n    <li>zee</li>\n</ul>';
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.InspectorUI()', function() {
      return it('should return an instance of a InspectorUI', function() {
        var inspector;
        inspector = new ContentTools.InspectorUI(editor);
        return expect(inspector instanceof ContentTools.InspectorUI).toBe(true);
      });
    });
    describe('ContentTools.InspectorUI.mount()', function() {
      return it('should mount the component', function() {
        var inspector;
        inspector = new ContentTools.InspectorUI(editor);
        editor.attach(inspector);
        inspector.mount();
        return expect(inspector.isMounted()).toBe(true);
      });
    });
    describe('ContentTools.InspectorUI.unmount()', function() {
      return it('should unmount the component', function() {
        var inspector;
        inspector = new ContentTools.InspectorUI(editor);
        editor.attach(inspector);
        inspector.mount();
        inspector.unmount();
        return expect(inspector.isMounted()).toBe(false);
      });
    });
    return describe('ContentTools.InspectorUI.updateTags()', function() {
      return it('should update the tags displayed to reflect the path to the current element', function() {
        var elements, inspector, region;
        editor.start();
        inspector = editor._inspector;
        region = editor.regions()['foo'];
        elements = region.children;
        elements[0].focus();
        expect(inspector._tagUIs.length).toEqual(1);
        expect(inspector._tagUIs[0].element.tagName()).toEqual('p');
        elements[1].children[0].children[0].focus();
        expect(inspector._tagUIs.length).toEqual(2);
        expect(inspector._tagUIs[0].element.tagName()).toEqual('ul');
        expect(inspector._tagUIs[1].element.tagName()).toEqual('li');
        return editor.stop();
      });
    });
  });

  describe('ContentTools.TagUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      div.setAttribute('id', 'foo');
      document.body.appendChild(div);
      div.innerHTML = '<p>bar</p>\n<ul>\n    <li>zee</li>\n</ul>';
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.TagUI()', function() {
      return it('should return an instance of a TagUI', function() {
        var tag;
        tag = new ContentTools.TagUI(editor);
        return expect(tag instanceof ContentTools.TagUI).toBe(true);
      });
    });
    describe('ContentTools.TagUI.mount()', function() {
      return it('should mount the component', function() {
        var elements, inspector, region, tag;
        editor.start();
        inspector = editor._inspector;
        region = editor.regions()['foo'];
        elements = region.children;
        tag = new ContentTools.TagUI(editor, elements[0]);
        tag.mount(inspector._domTags);
        return expect(tag.isMounted()).toBe(true);
      });
    });
    return describe('ContentTools.TagUI > Interaction', function() {
      return it('should allow the properties dialog to be used', function() {
        var app, dialog, element, inspector, mouseDownEvent, region, tag;
        editor.start();
        inspector = editor._inspector;
        region = editor.regions()['foo'];
        element = region.children[0];
        element.focus();
        tag = inspector._tagUIs[0];
        mouseDownEvent = document.createEvent('CustomEvent');
        mouseDownEvent.initCustomEvent('mousedown', false, false, null);
        tag.domElement().dispatchEvent(mouseDownEvent);
        app = ContentTools.EditorApp.get();
        dialog = app.children()[app.children().length - 1];
        expect(dialog instanceof ContentTools.PropertiesDialog).toBe(true);
        dialog.dispatchEvent(dialog.createEvent('save', {
          changedAttributes: {
            title: 'bar'
          },
          changedStyles: {
            'zee': true
          },
          innerHTML: 'foo'
        }));
        expect(element.attr('title')).toBe('bar');
        expect(element.hasCSSClass('zee')).toBe(true);
        expect(element.content.html()).toBe('foo');
        tag.domElement().dispatchEvent(mouseDownEvent);
        dialog = app.children()[app.children().length - 1];
        dialog.dispatchEvent(dialog.createEvent('save', {
          changedAttributes: {
            title: null
          },
          changedStyles: {
            'zee': false
          },
          innerHTML: 'bar'
        }));
        expect(element.attr('title')).toBe(void 0);
        expect(element.hasCSSClass('zee')).toBe(false);
        return expect(element.content.html()).toBe('bar');
      });
    });
  });

  describe('ContentTools.ModalUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.ModalUI()', function() {
      return it('should return an instance of a ModalUI', function() {
        var modal;
        modal = new ContentTools.ModalUI(true, false);
        return expect(modal instanceof ContentTools.ModalUI).toBe(true);
      });
    });
    describe('ContentTools.ModalUI.mount()', function() {
      it('should mount the component', function() {
        var modal;
        modal = new ContentTools.ModalUI(true, true);
        editor.attach(modal);
        modal.show();
        return expect(modal.isMounted()).toBe(true);
      });
      it('should apply transparent flag', function() {
        var classes, modal;
        modal = new ContentTools.ModalUI(true, true);
        editor.attach(modal);
        modal.show();
        classes = modal.domElement().getAttribute('class').split(' ');
        return expect(classes.indexOf('ct-modal--transparent') > -1).toBe(true);
      });
      return it('should apply no-scrolling flag', function() {
        var classes, modal;
        modal = new ContentTools.ModalUI(true, false);
        editor.attach(modal);
        modal.show();
        classes = (document.body.getAttribute('class') || '').split(' ');
        return expect(classes.indexOf('ct--no-scroll') > -1).toBe(true);
      });
    });
    describe('ContentTools.ModalUI.unmount()', function() {
      it('should unmount the component', function() {
        var modal;
        modal = new ContentTools.ModalUI(true, true);
        editor.attach(modal);
        modal.show();
        modal.unmount();
        return expect(modal.isMounted()).toBe(false);
      });
      return it('should remove no-scrolling flag', function() {
        var classes, modal;
        modal = new ContentTools.ModalUI(true, false);
        editor.attach(modal);
        modal.show();
        modal.unmount();
        classes = (document.body.getAttribute('class') || '').split(' ');
        return expect(classes.indexOf('ct--no-scroll') > -1).toBe(false);
      });
    });
    return describe('ContentTools.ModalUI > Events', function() {
      return it('should trigger a `click` event if clicked', function() {
        var clickEvent, foo, modal;
        modal = new ContentTools.ModalUI(true, true);
        editor.attach(modal);
        modal.show();
        foo = {
          handleFoo: function() {}
        };
        spyOn(foo, 'handleFoo');
        modal.addEventListener('click', foo.handleFoo);
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        modal.domElement().dispatchEvent(clickEvent);
        return expect(foo.handleFoo).toHaveBeenCalled();
      });
    });
  });

  describe('ContentTools.ToolboxUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      div.setAttribute('id', 'foo');
      div.innerHTML = '<p>bar</p><img scr="test.png">';
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      editor.init('.editable');
      return editor.start();
    });
    afterEach(function() {
      editor.stop();
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.ToolboxUI()', function() {
      return it('should return an instance of a ToolboxUI', function() {
        var toolbox;
        toolbox = new ContentTools.ToolboxUI(editor, []);
        return expect(toolbox instanceof ContentTools.ToolboxUI).toBe(true);
      });
    });
    describe('ContentTools.ToolboxUI.isDragging()', function() {
      return it('should return true if the ToolboxUI is currently being dragged', function() {
        var mouseDownEvent, mouseUpEvent, toolbox;
        toolbox = editor._toolbox;
        expect(toolbox.isDragging()).toBe(false);
        mouseDownEvent = document.createEvent('CustomEvent');
        mouseDownEvent.initCustomEvent('mousedown', false, false, null);
        toolbox._domGrip.dispatchEvent(mouseDownEvent);
        expect(toolbox.isDragging()).toBe(true);
        mouseUpEvent = document.createEvent('CustomEvent');
        mouseUpEvent.initCustomEvent('mouseup', false, false, null);
        document.dispatchEvent(mouseUpEvent);
        return expect(toolbox.isDragging()).toBe(false);
      });
    });
    describe('ContentTools.ToolboxUI.hide()', function() {
      return it('should remove all event bindings before the toolbox is hidden', function() {
        var toolbox;
        toolbox = editor._toolbox;
        spyOn(toolbox, '_removeDOMEventListeners');
        toolbox.hide();
        return expect(toolbox._removeDOMEventListeners).toHaveBeenCalled();
      });
    });
    describe('ContentTools.ToolboxUI.tools()', function() {
      it('should return the list of tools that populate the toolbox', function() {
        var toolbox;
        toolbox = editor._toolbox;
        return expect(toolbox.tools()).toEqual(ContentTools.DEFAULT_TOOLS);
      });
      return it('should set the list of tools that populate the toolbox', function() {
        var customTools, toolbox;
        toolbox = editor._toolbox;
        customTools = [['bold', 'italic', 'link']];
        toolbox.tools(customTools);
        return expect(toolbox.tools()).toEqual(customTools);
      });
    });
    describe('ContentTools.ToolboxUI.mount()', function() {
      it('should mount the component', function() {
        var toolbox;
        toolbox = new ContentTools.ToolboxUI(editor, []);
        editor.attach(toolbox);
        toolbox.mount();
        return expect(toolbox.isMounted()).toBe(true);
      });
      it('should restore the position of the component to any previously saved state', function() {
        var toolbox;
        window.localStorage.setItem('ct-toolbox-position', '7,7');
        toolbox = new ContentTools.ToolboxUI(editor, []);
        editor.attach(toolbox);
        toolbox.mount();
        expect(toolbox.domElement().style.left).toBe('7px');
        return expect(toolbox.domElement().style.top).toBe('7px');
      });
      return it('should always be contained within the viewport', function() {
        var toolbox;
        window.localStorage.setItem('ct-toolbox-position', '-7,-7');
        toolbox = new ContentTools.ToolboxUI(editor, []);
        editor.attach(toolbox);
        toolbox.mount();
        expect(toolbox.domElement().style.left).toBe('');
        return expect(toolbox.domElement().style.top).toBe('');
      });
    });
    describe('ContentTools.ToolboxUI.updateTools()', function() {
      return it('should refresh all tool UIs in the toolbox', function(done) {
        var checkUpdated, element, region, toolbox;
        toolbox = editor._toolbox;
        region = editor.regions()['foo'];
        element = region.children[0];
        expect(toolbox._toolUIs['heading'].disabled()).toBe(true);
        element.focus();
        checkUpdated = function() {
          expect(toolbox._toolUIs['heading'].disabled()).toBe(false);
          return done();
        };
        return setTimeout(checkUpdated, 500);
      });
    });
    return describe('ContentTools.ToolboxUI > Keyboard short-cuts', function() {
      it('should allow a non-content element to be removed with the delete key short-cut', function() {
        var element, keyDownEvent, region, toolbox;
        toolbox = editor._toolbox;
        region = editor.regions()['foo'];
        element = region.children[1];
        element.focus();
        keyDownEvent = document.createEvent('CustomEvent');
        keyDownEvent.initCustomEvent('keydown', false, false, null);
        keyDownEvent.keyCode = 46;
        window.dispatchEvent(keyDownEvent);
        return expect(region.children.length).toBe(1);
      });
      it('should allow a undo to be triggered with Ctrl-z key short-cut', function() {
        var element, keyDownEvent, region, toolbox;
        toolbox = editor._toolbox;
        region = editor.regions()['foo'];
        element = region.children[1];
        spyOn(toolbox._toolShelf.get("undo"), 'canApply');
        keyDownEvent = document.createEvent('CustomEvent');
        keyDownEvent.initCustomEvent('keydown', false, false, null);
        keyDownEvent.keyCode = 90;
        keyDownEvent.ctrlKey = true;
        window.dispatchEvent(keyDownEvent);
        return expect(toolbox._toolShelf.get("undo").canApply).toHaveBeenCalled();
      });
      return it('should allow a redo to be triggered with Ctrl-Shift-z key short-cut', function() {
        var element, keyDownEvent, region, toolbox;
        toolbox = editor._toolbox;
        region = editor.regions()['foo'];
        element = region.children[1];
        element.focus();
        spyOn(toolbox._toolShelf.get("redo"), 'canApply');
        keyDownEvent = document.createEvent('CustomEvent');
        keyDownEvent.initCustomEvent('keydown', false, false, null);
        keyDownEvent.keyCode = 90;
        keyDownEvent.ctrlKey = true;
        keyDownEvent.shiftKey = true;
        window.dispatchEvent(keyDownEvent);
        return expect(toolbox._toolShelf.get("redo").canApply).toHaveBeenCalled();
      });
    });
  });

  describe('ContentTools.ToolboxUI', function() {
    var div, editor, toolShelf;
    div = null;
    editor = null;
    toolShelf = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      div.setAttribute('id', 'foo');
      div.innerHTML = '<p>bar</p><img scr="test.png">';
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      editor.init('.editable');
      return toolShelf = new ContentTools.ToolShelf(editor);
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.ToolUI()', function() {
      return it('should return an instance of a ToolUI', function() {
        var tool;
        tool = new ContentTools.ToolUI(editor, toolShelf.get('bold'));
        return expect(tool instanceof ContentTools.ToolUI).toBe(true);
      });
    });
    describe('ContentTools.ToolUI.disabled()', function() {
      return it('should set/get the disabled state for the tool', function() {
        var tool;
        tool = new ContentTools.ToolUI(editor, toolShelf.get('bold'));
        expect(tool.disabled()).toBe(false);
        tool.disabled(true);
        return expect(tool.disabled()).toBe(true);
      });
    });
    describe('ContentTools.ToolUI.apply()', function() {
      return it('should apply the tool associated with the component', function() {
        var element, region, tool;
        tool = new ContentTools.ToolUI(editor, toolShelf.get('heading'));
        region = new editor.CEFactory.Region(document.querySelectorAll('.editable')[0]);
        element = region.children[0];
        tool.apply(element);
        return expect(element.tagName()).toBe('h1');
      });
    });
    describe('ContentTools.Tool.mount()', function() {
      return it('should mount the component', function() {
        var tool;
        tool = new ContentTools.ToolUI(editor, toolShelf.get('bold'));
        editor.attach(tool);
        tool.mount(editor.domElement());
        return expect(tool.isMounted()).toBe(true);
      });
    });
    return describe('ContentTools.Tool.update()', function() {
      return it('should update the state of the tool based on the currently focused element and content selection', function() {
        var element, region, tool;
        tool = new ContentTools.ToolUI(editor, toolShelf.get('heading'));
        region = new editor.CEFactory.Region(document.querySelectorAll('.editable')[0]);
        element = region.children[0];
        tool.update();
        expect(tool.disabled()).toBe(true);
        tool.update(element);
        return expect(tool.disabled()).toBe(false);
      });
    });
  });

  describe('ContentTools.AnchoredDialogUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.AnchoredDialogUI()', function() {
      return it('should return an instance of a AnchoredDialogUI', function() {
        var dialog;
        dialog = new ContentTools.AnchoredDialogUI();
        return expect(dialog instanceof ContentTools.AnchoredDialogUI).toBe(true);
      });
    });
    describe('ContentTools.AnchoredDialogUI.mount()', function() {
      return it('should mount the dialog', function() {
        var dialog;
        dialog = new ContentTools.AnchoredDialogUI();
        editor.attach(dialog);
        dialog.mount();
        return expect(dialog.isMounted()).toBe(true);
      });
    });
    return describe('ContentTools.AnchoredDialogUI.position()', function() {
      return it('should set/get the dialog\'s position', function() {});
    });
  });

  describe('ContentTools.DialogUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.DialogUI()', function() {
      return it('should return an instance of a DialogUI', function() {
        var dialog;
        dialog = new ContentTools.DialogUI('foo');
        return expect(dialog instanceof ContentTools.DialogUI).toBe(true);
      });
    });
    describe('ContentTools.DialogUI.busy()', function() {
      return it('should set/get the busy state for the dialog', function() {
        var classes, dialog;
        dialog = new ContentTools.DialogUI('foo');
        editor.attach(dialog);
        dialog.mount();
        expect(dialog.busy()).toBe(false);
        classes = dialog.domElement().getAttribute('class');
        expect(classes.indexOf('ct-dialog--busy')).toBe(-1);
        dialog.busy(true);
        expect(dialog.busy()).toBe(true);
        classes = dialog.domElement().getAttribute('class');
        return expect(classes.indexOf('ct-dialog--busy') > 0).toBe(true);
      });
    });
    describe('ContentTools.DialogUI.position()', function() {
      return it('should set/get the dialog\'s caption', function() {
        var dialog;
        dialog = new ContentTools.DialogUI('foo');
        editor.attach(dialog);
        dialog.mount();
        expect(dialog.caption()).toEqual('foo');
        expect(dialog._domCaption.textContent).toEqual('foo');
        dialog.caption('bar');
        expect(dialog.caption()).toEqual('bar');
        return expect(dialog._domCaption.textContent).toEqual('bar');
      });
    });
    describe('ContentTools.DialogUI.mount()', function() {
      return it('should mount the dialog', function() {
        var dialog;
        dialog = new ContentTools.DialogUI();
        editor.attach(dialog);
        dialog.mount();
        return expect(dialog.isMounted()).toBe(true);
      });
    });
    return describe('ContentTools.DialogUI.unmount()', function() {
      return it('should unmount the component', function() {
        var dialog;
        dialog = new ContentTools.DialogUI();
        editor.attach(dialog);
        dialog.mount();
        dialog.unmount();
        return expect(dialog.isMounted()).toBe(false);
      });
    });
  });

  describe('ContentTools.ImageDialog', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
      document.body.appendChild(div);
      editor = ContentTools.EditorApp.get();
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.ImageDialog()', function() {
      return it('should return an instance of a ImageDialog', function() {
        var dialog;
        dialog = new ContentTools.ImageDialog();
        return expect(dialog instanceof ContentTools.ImageDialog).toBe(true);
      });
    });
    return describe('ContentTools.ImageDialog.cropRegion()', function() {
      return it('should return the crop region set by the user', function() {
        var dialog;
        dialog = new ContentTools.ImageDialog();
        editor.attach(dialog);
        dialog.mount();
        expect(dialog.cropRegion()).toEqual([0, 0, 1, 1]);
        dialog._domView.style.width = '400px';
        dialog._domView.style.height = '400px';
        dialog.populate('test.png', [400, 400]);
        dialog.addCropMarks();
        dialog._cropMarks._domHandles[1].style.left = '200px';
        dialog._cropMarks._domHandles[1].style.top = '200px';
        return expect(dialog.cropRegion()).toEqual([0, 0, 0.5, 0.5]);
      });
    });
  });

  editor = ContentTools.EditorApp.get();

  editor.init();

  editor.start();

  CEFactory = editor.CEFactory;

  toolShelf = editor._toolbox._toolShelf;

  describe('ContentTools.ToolShelf.stow()', function() {
    return it('should store a `ContentTools.Tool` instance against a name', function() {
      var tool;
      tool = ContentTools.Tool;
      ContentTools.ToolShelf.stow(tool, 'tool');
      return expect(ContentTools.ToolShelf._tools['tool']).toEqual(tool);
    });
  });

  describe('ContentTools.ToolShelf.fetch()', function() {
    return it('should return a `ContentTools.Tool` instance by name', function() {
      var tool;
      tool = ContentTools.Tools.Bold;
      return expect(ContentTools.ToolShelf._tools['bold']).toEqual(tool);
    });
  });

  describe('ContentTools.Tools.Bold.apply()', function() {
    it('should wrap the selected content in a bold tag if the bold tag is not applied to all of the selection', function() {
      var element, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 4);
      tool = toolShelf.get("bold");
      element = new CEFactory.Text('p', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      expect(element.content.html()).toBe('<b>test</b>');
      element = new CEFactory.Text('p', {}, '<b>te</b>st');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('<b>test</b>');
    });
    return it('should remove the bold tag from the selected content if the bold tag is applied to all of the selection', function() {
      var element, region, selection, tool;
      element = new CEFactory.Text('p', {}, '<b>test</b>');
      region = new CEFactory.Region(document.createElement('div'));
      region.attach(element);
      selection = new ContentSelect.Range(0, 4);
      tool = toolShelf.get("bold");
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('test');
    });
  });

  describe('ContentTools.Tools.Bold.canApply()', function() {
    return it('should return true if the element supports content and the selection is not collapsed', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, 'test');
      tool = toolShelf.get("bold");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.canApply(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 0);
      expect(tool.canApply(element, selection)).toBe(false);
      element = new CEFactory.Image();
      return expect(tool.canApply(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Bold.isApplied()', function() {
    return it('should return true if the selected content is wrapped in a bold tag', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, '<b>te</b>st');
      tool = toolShelf.get("bold");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.isApplied(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 4);
      expect(tool.isApplied(element, selection)).toBe(false);
      selection = new ContentSelect.Range(2, 4);
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Italic.apply()', function() {
    it('should wrap the selected content in a italic tag if the italic tag is not applied to all of the selection', function() {
      var element, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 4);
      tool = toolShelf.get("italic");
      element = new CEFactory.Text('p', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      expect(element.content.html()).toBe('<i>test</i>');
      element = new CEFactory.Text('p', {}, '<i>te</i>st');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('<i>test</i>');
    });
    return it('should remove the italic tag from the selected content if the italic tag is applied to all of the selection', function() {
      var element, region, selection, tool;
      element = new CEFactory.Text('p', {}, '<i>test</i>');
      region = new CEFactory.Region(document.createElement('div'));
      region.attach(element);
      selection = new ContentSelect.Range(0, 4);
      tool = toolShelf.get("italic");
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('test');
    });
  });

  describe('ContentTools.Tools.Italic.canApply()', function() {
    return it('should return true if the element supports content and the selection is not collapsed', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, 'test');
      tool = toolShelf.get("italic");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.canApply(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 0);
      expect(tool.canApply(element, selection)).toBe(false);
      element = new CEFactory.Image();
      return expect(tool.canApply(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Italic.isApplied()', function() {
    return it('should return true if the selected content is wrapped in a italic tag', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, '<i>te</i>st');
      tool = toolShelf.get("italic");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.isApplied(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 4);
      expect(tool.isApplied(element, selection)).toBe(false);
      selection = new ContentSelect.Range(2, 4);
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Link.canApply()', function() {
    return it('should return true if the element supports content and the selection is not collapsed or if the element is an image', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, 'test');
      tool = toolShelf.get("link");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.canApply(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 0);
      expect(tool.canApply(element, selection)).toBe(false);
      element = new CEFactory.Image();
      return expect(tool.canApply(element, selection)).toBe(true);
    });
  });

  describe('ContentTools.Tools.Link.getAttr()', function() {
    return it('should return an attribute by name for the first anchor tag found in a selection or if the element is an image then for the anchor tag associated with image', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, '<a href="#test" target="_blank">te</a><a href="#test2">st</a>');
      tool = toolShelf.get("link");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.getAttr('href', element, selection)).toBe('#test');
      selection = new ContentSelect.Range(2, 4);
      expect(tool.getAttr('href', element, selection)).toBe('#test2');
      selection = new ContentSelect.Range(0, 2);
      expect(tool.getAttr('target', element, selection)).toBe('_blank');
      selection = new ContentSelect.Range(2, 4);
      expect(tool.getAttr('target', element, selection)).toBe(void 0);
      selection = new ContentSelect.Range(1, 4);
      return expect(tool.getAttr('href', element, selection)).toBe('#test');
    });
  });

  describe('ContentTools.Tools.Link.isApplied()', function() {
    return it('should return true if the selected content is wrapped in an anchor tag or is an image with an associated anchor tag', function() {
      var element, selection, tool;
      element = new CEFactory.Text('p', {}, '<a href="#test">te</a>st');
      tool = toolShelf.get("link");
      selection = new ContentSelect.Range(0, 2);
      expect(tool.isApplied(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 4);
      expect(tool.isApplied(element, selection)).toBe(false);
      selection = new ContentSelect.Range(2, 4);
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.AlignLeft.apply()', function() {
    return it('should apply the `align-left` class to an element or its parent if it does not directly support the class attribute itself', function() {});
  });

  describe('ContentTools.Tools.AlignLeft.canApply()', function() {
    return it('should return true if the element supports content', function() {});
  });

  describe('ContentTools.Tools.AlignLeft.isApplied()', function() {
    return it('should return true if the element (or relevant parent) has the `align-left` class applied', function() {});
  });

  describe('ContentTools.Tools.Heading.apply()', function() {
    return it('should change the tag name of a top level element supporting content to h1', function() {
      var element, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("heading");
      element = new CEFactory.Text('p', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.tagName()).toBe('h1');
    });
  });

  describe('ContentTools.Tools.Heading.canApply()', function() {
    return it('should return true if the element is a top-level element that supports content', function() {
      var element, image, list, listItem, listItemText, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("heading");
      element = new CEFactory.Text('p', {}, 'test');
      region.attach(element);
      expect(tool.canApply(element, selection)).toBe(true);
      image = new CEFactory.Image();
      region.attach(image);
      expect(tool.canApply(image, selection)).toBe(false);
      list = new CEFactory.List('ul');
      listItem = new CEFactory.ListItem();
      listItemText = new CEFactory.ListItemText('test');
      listItem.attach(listItemText);
      list.attach(listItem);
      region.attach(list);
      return expect(tool.canApply(list, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Heading.isApplied()', function() {
    return it('should return true if the selected element is a h1', function() {
      var element, selection, tool;
      tool = toolShelf.get("heading");
      element = new CEFactory.Text('h1', {}, 'test');
      selection = new ContentSelect.Range(0, 0);
      expect(tool.isApplied(element, selection)).toBe(true);
      element = new CEFactory.Text('p', {}, 'test');
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Subheading.apply()', function() {
    return it('should change the tag name of a top level element supporting content to h2', function() {
      var element, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("subheading");
      element = new CEFactory.Text('p', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.tagName()).toBe('h2');
    });
  });

  describe('ContentTools.Tools.Subheading.canApply()', function() {
    return it('should return true if the element is a top-level element that supports content', function() {
      var element, image, list, listItem, listItemText, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("subheading");
      element = new CEFactory.Text('p', {}, 'test');
      region.attach(element);
      expect(tool.canApply(element, selection)).toBe(true);
      image = new CEFactory.Image();
      region.attach(image);
      expect(tool.canApply(image, selection)).toBe(false);
      list = new CEFactory.List('ul');
      listItem = new CEFactory.ListItem();
      listItemText = new CEFactory.ListItemText('test');
      listItem.attach(listItemText);
      list.attach(listItem);
      region.attach(list);
      return expect(tool.canApply(list, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Subheading.isApplied()', function() {
    return it('should return true if the selected element is a h2', function() {
      var element, selection, tool;
      tool = toolShelf.get("subheading");
      element = new CEFactory.Text('h2', {}, 'test');
      selection = new ContentSelect.Range(0, 0);
      expect(tool.isApplied(element, selection)).toBe(true);
      element = new CEFactory.Text('p', {}, 'test');
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Paragraph.apply()', function() {
    it('should change text/pre-text elements to paragraphs', function() {
      var element, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("paragraph");
      element = new CEFactory.Text('h1', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      expect(element.tagName()).toBe('p');
      element = new CEFactory.Text('pre', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.tagName()).toBe('p');
    });
    return it('should add a paragraph after elements non-text/pre-text elements', function() {
      var image, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("paragraph");
      image = new CEFactory.Image();
      region.attach(image);
      tool.apply(image, selection, (function(_this) {
        return function() {};
      })(this));
      expect(region.children.length).toBe(2);
      return expect(region.children[1].tagName()).toBe('p');
    });
  });

  describe('ContentTools.Tools.Paragraph.canApply()', function() {
    return it('should return true if the element is not fixed', function() {
      var fixed_heading, fixture, fixture_anchor, heading, image, region, selection, tool;
      region = new CEFactory.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = toolShelf.get("paragraph");
      heading = new CEFactory.Text('h1', {}, 'test');
      region.attach(heading);
      expect(tool.canApply(heading, selection)).toBe(true);
      image = new CEFactory.Image();
      region.attach(image);
      expect(tool.canApply(image, selection)).toBe(true);
      fixture_anchor = document.createElement('div');
      fixed_heading = document.createElement('h1');
      fixed_heading.innerHTML = 'test';
      fixture_anchor.appendChild(fixed_heading);
      fixture = new CEFactory.Fixture(fixed_heading);
      return expect(tool.canApply(fixture.children[0], selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Paragraph.apply()', function() {
    return it('should return true if the selected element is a paragraph', function() {
      var element, selection, tool;
      tool = toolShelf.get("paragraph");
      element = new CEFactory.Text('p', {}, 'test');
      selection = new ContentSelect.Range(0, 0);
      expect(tool.isApplied(element, selection)).toBe(true);
      element = new CEFactory.Text('h1', {}, 'test');
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  editor = ContentTools.EditorApp.get();

  editor.init();

  editor.start();

  CEFactory = editor.CEFactory;

  describe('ContentTools.StylePalette.add()', function() {
    afterEach(function() {
      return ContentTools.StylePalette._styles = [];
    });
    return it('should return a `ContentTools.Style` instance', function() {
      var p, style;
      style = new ContentTools.Style('test', 'test', ['p']);
      ContentTools.StylePalette.add(style);
      p = new CEFactory.Text('p', {}, 'foo');
      return expect(ContentTools.StylePalette.styles(p)).toEqual([style]);
    });
  });

  describe('ContentTools.StylePalette.styles()', function() {
    afterEach(function() {
      return ContentTools.StylePalette._styles = [];
    });
    return it('should return a list of `ContentTools.Style` instances by tag name', function() {
      var h1, h2, p, test1, test2, test3;
      test1 = new ContentTools.Style('Test 1', 'test-1', ['p']);
      test2 = new ContentTools.Style('Test 2', 'test-2', ['h1', 'p']);
      test3 = new ContentTools.Style('Test 3', 'test-3', ['h1', 'h2']);
      ContentTools.StylePalette.add(test1);
      ContentTools.StylePalette.add(test2);
      ContentTools.StylePalette.add(test3);
      p = new CEFactory.Text('p', {}, 'foo');
      h1 = new CEFactory.Text('h1', {}, 'foo');
      h2 = new CEFactory.Text('h2', {}, 'foo');
      expect(ContentTools.StylePalette.styles(p)).toEqual([test1, test2]);
      expect(ContentTools.StylePalette.styles(h1)).toEqual([test2, test3]);
      return expect(ContentTools.StylePalette.styles(h2)).toEqual([test3]);
    });
  });

  describe('ContentTools.Style()', function() {
    return it('should create `ContentTools.Style` instance', function() {
      var style;
      style = new ContentTools.Style('Test', 'test', ['p']);
      return expect(style instanceof ContentTools.Style).toBe(true);
    });
  });

  describe('ContentTools.Style.applicableTo()', function() {
    return it('should return a list of tag names the style is applicable to', function() {
      var style, tagNames;
      tagNames = ['p', 'img', 'table'];
      style = new ContentTools.Style('Test', 'test', tagNames);
      return expect(style.applicableTo()).toBe(tagNames);
    });
  });

  describe('ContentTools.Style.cssClass()', function() {
    return it('should return the CSS class name for the style', function() {
      var cssClassName, style;
      cssClassName = 'test';
      style = new ContentTools.Style('Test', cssClassName, 'p');
      return expect(style.cssClass()).toBe(cssClassName);
    });
  });

  describe('ContentTools.Style.name()', function() {
    return it('should return the name of the style', function() {
      var name, style;
      name = 'Test';
      style = new ContentTools.Style(name, 'test', 'p');
      return expect(style.name()).toBe(name);
    });
  });

}).call(this);
