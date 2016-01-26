(function() {
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

  describe('ContentTools.ComponentUI.bind()', function() {
    return it('should bind a function so that it\'s called whenever the event is triggered against the component', function() {
      var component, foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      component = new ContentTools.ComponentUI();
      component.bind('foo', foo.handleFoo);
      component.trigger('foo');
      return expect(foo.handleFoo).toHaveBeenCalled();
    });
  });

  describe('ContentTools.ComponentUI.trigger()', function() {
    return it('should trigger an event against the component with specified arguments', function() {
      var component, foo;
      foo = {
        handleFoo: function() {}
      };
      spyOn(foo, 'handleFoo');
      component = new ContentTools.ComponentUI();
      component.bind('foo', foo.handleFoo);
      component.trigger('foo', 123);
      return expect(foo.handleFoo).toHaveBeenCalledWith(123);
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
        flash = new ContentTools.FlashUI('ok');
        return expect(flash instanceof ContentTools.FlashUI).toBe(true);
      });
      it('should mount the component', function() {
        var flash;
        flash = new ContentTools.FlashUI('ok');
        return expect(flash.isMounted()).toBe(true);
      });
      return it('should unmount the component after X seconds', function(done) {
        var checkUnmounted, flash;
        flash = new ContentTools.FlashUI('ok');
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
        flash = new ContentTools.FlashUI('ok');
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
      return it('should set/get the busy state for the ignition', function() {
        var ignition;
        ignition = new ContentTools.IgnitionUI();
        expect(ignition.busy()).toBe(false);
        ignition.busy(true);
        return expect(ignition.busy()).toBe(true);
      });
    });
    describe('ContentTools.IgnitionUI.changeState()', function() {
      it('should change the state of the ignition switch to editing', function() {
        var classes, ignition;
        ignition = editor._ignition;
        ignition.changeState('editing');
        classes = ignition.domElement().getAttribute('class').split(' ');
        return expect(classes.indexOf('ct-ignition--editing') > -1).toBe(true);
      });
      return it('should change the state of the ignition switch to ready', function() {
        var classes, ignition;
        ignition = editor._ignition;
        ignition.changeState('editing');
        ignition.changeState('ready');
        classes = ignition.domElement().getAttribute('class').split(' ');
        return expect(classes.indexOf('ct-ignition--ready') > -1).toBe(true);
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
      it('should trigger a `start` event if edit button clicked', function() {
        var clickEvent, foo, ignition;
        ignition = editor._ignition;
        foo = {
          handleFoo: function() {}
        };
        spyOn(foo, 'handleFoo');
        ignition.bind('start', foo.handleFoo);
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        ignition._domEdit.dispatchEvent(clickEvent);
        return expect(foo.handleFoo).toHaveBeenCalled();
      });
      it('should trigger a `stop` event with a value of true if confirm button button clicked', function() {
        var clickEvent, foo, ignition;
        ignition = editor._ignition;
        foo = {
          handleFoo: function(confirmed) {}
        };
        spyOn(foo, 'handleFoo');
        ignition.bind('stop', foo.handleFoo);
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        ignition._domConfirm.dispatchEvent(clickEvent);
        return expect(foo.handleFoo).toHaveBeenCalledWith(true);
      });
      return it('should trigger a `stop` event with a value of false if cancel button clicked', function() {
        var clickEvent, foo, ignition;
        ignition = editor._ignition;
        foo = {
          handleFoo: function(confirmed) {}
        };
        spyOn(foo, 'handleFoo');
        ignition.bind('stop', foo.handleFoo);
        clickEvent = document.createEvent('CustomEvent');
        clickEvent.initCustomEvent('click', false, false, null);
        ignition._domEdit.dispatchEvent(clickEvent);
        ContentEdit.Root.get().commit();
        ignition._domCancel.dispatchEvent(clickEvent);
        return expect(foo.handleFoo).toHaveBeenCalledWith(false);
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
        inspector = new ContentTools.InspectorUI();
        return expect(inspector instanceof ContentTools.InspectorUI).toBe(true);
      });
    });
    describe('ContentTools.InspectorUI.mount()', function() {
      return it('should mount the component', function() {
        var inspector;
        inspector = new ContentTools.InspectorUI();
        editor.attach(inspector);
        inspector.mount();
        return expect(inspector.isMounted()).toBe(true);
      });
    });
    describe('ContentTools.InspectorUI.unmount()', function() {
      return it('should unmount the component', function() {
        var inspector;
        inspector = new ContentTools.InspectorUI();
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
        tag = new ContentTools.TagUI();
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
        tag = new ContentTools.TagUI(elements[0]);
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
        dialog.trigger('save', {
          title: 'bar'
        }, {
          'zee': true
        }, 'foo');
        expect(element.attr('title')).toBe('bar');
        expect(element.hasCSSClass('zee')).toBe(true);
        expect(element.content.html()).toBe('foo');
        tag.domElement().dispatchEvent(mouseDownEvent);
        dialog = app.children()[app.children().length - 1];
        dialog.trigger('save', {
          title: null
        }, {
          'zee': false
        }, 'bar');
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
        modal.bind('click', foo.handleFoo);
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
        toolbox = new ContentTools.ToolboxUI([]);
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
        toolbox = new ContentTools.ToolboxUI([]);
        editor.attach(toolbox);
        toolbox.mount();
        return expect(toolbox.isMounted()).toBe(true);
      });
      it('should restore the position of the component to any previously saved state', function() {
        var toolbox;
        window.localStorage.setItem('ct-toolbox-position', '7,7');
        toolbox = new ContentTools.ToolboxUI([]);
        editor.attach(toolbox);
        toolbox.mount();
        expect(toolbox.domElement().style.left).toBe('7px');
        return expect(toolbox.domElement().style.top).toBe('7px');
      });
      return it('should always be contained within the viewport', function() {
        var toolbox;
        window.localStorage.setItem('ct-toolbox-position', '-7,-7');
        toolbox = new ContentTools.ToolboxUI([]);
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
        region.detach(element);
        spyOn(ContentTools.Tools.Undo, 'canApply');
        keyDownEvent = document.createEvent('CustomEvent');
        keyDownEvent.initCustomEvent('keydown', false, false, null);
        keyDownEvent.keyCode = 90;
        keyDownEvent.ctrlKey = true;
        window.dispatchEvent(keyDownEvent);
        return expect(ContentTools.Tools.Undo.canApply).toHaveBeenCalled();
      });
      return it('should allow a redo to be triggered with Ctrl-Shift-z key short-cut', function() {
        var element, keyDownEvent, region, toolbox;
        toolbox = editor._toolbox;
        region = editor.regions()['foo'];
        element = region.children[1];
        region.detach(element);
        ContentTools.Tools.Undo.apply(null, null, function() {});
        region = editor.regions()['foo'];
        expect(region.children.length).toBe(2);
        spyOn(ContentTools.Tools.Redo, 'canApply');
        keyDownEvent = document.createEvent('CustomEvent');
        keyDownEvent.initCustomEvent('keydown', false, false, null);
        keyDownEvent.keyCode = 90;
        keyDownEvent.ctrlKey = true;
        keyDownEvent.shiftKey = true;
        window.dispatchEvent(keyDownEvent);
        return expect(ContentTools.Tools.Redo.canApply).toHaveBeenCalled();
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
      return editor.init('.editable');
    });
    afterEach(function() {
      editor.destroy();
      return document.body.removeChild(div);
    });
    describe('ContentTools.ToolUI()', function() {
      return it('should return an instance of a ToolUI', function() {
        var tool;
        tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('bold'));
        return expect(tool instanceof ContentTools.ToolUI).toBe(true);
      });
    });
    describe('ContentTools.ToolUI.disabled()', function() {
      return it('should set/get the disabled state for the tool', function() {
        var tool;
        tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('bold'));
        expect(tool.disabled()).toBe(false);
        tool.disabled(true);
        return expect(tool.disabled()).toBe(true);
      });
    });
    describe('ContentTools.ToolUI.apply()', function() {
      return it('should apply the tool associated with the component', function() {
        var element, region, tool;
        tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('heading'));
        region = new ContentEdit.Region(document.querySelectorAll('.editable')[0]);
        element = region.children[0];
        tool.apply(element);
        return expect(element.tagName()).toBe('h1');
      });
    });
    describe('ContentTools.Tool.mount()', function() {
      return it('should mount the component', function() {
        var tool;
        tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('bold'));
        editor.attach(tool);
        tool.mount(editor.domElement());
        return expect(tool.isMounted()).toBe(true);
      });
    });
    return describe('ContentTools.Tool.update()', function() {
      return it('should update the state of the tool based on the currently focused element and content selection', function() {
        var element, region, tool;
        tool = new ContentTools.ToolUI(ContentTools.ToolShelf.fetch('heading'));
        region = new ContentEdit.Region(document.querySelectorAll('.editable')[0]);
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
      return it('should set/get the dialog\'s position', function() {
        var dialog, style;
        dialog = new ContentTools.AnchoredDialogUI();
        editor.attach(dialog);
        dialog.mount();
        expect(dialog.position()).toEqual([0, 0]);
        dialog.position([7, 7]);
        style = dialog.domElement().style;
        expect(dialog.position()).toEqual([7, 7]);
        expect(style.top).toBe('7px');
        return expect(style.left).toBe('7px');
      });
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

  describe('ContentTools.ToolShelf.stow()', function() {
    return it('should store a `ContentTools.Tool` instance against a name', function() {
      var tool;
      tool = ContentTools.Tool;
      ContentTools.ToolShelf.stow(tool, 'tool');
      return expect(ContentTools.ToolShelf.fetch('tool')).toEqual(tool);
    });
  });

  describe('ContentTools.ToolShelf.fetch()', function() {
    return it('should return a `ContentTools.Tool` instance by name', function() {
      var tool;
      tool = ContentTools.Tools.Bold;
      return expect(ContentTools.ToolShelf.fetch('bold')).toEqual(tool);
    });
  });

  describe('ContentTools.Tools.Bold.apply()', function() {
    it('should wrap the selected content in a bold tag if the bold tag is not applied to all of the selection', function() {
      var element, region, selection, tool;
      region = new ContentEdit.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 4);
      tool = ContentTools.Tools.Bold;
      element = new ContentEdit.Text('p', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      expect(element.content.html()).toBe('<b>test</b>');
      element = new ContentEdit.Text('p', {}, '<b>te</b>st');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('<b>test</b>');
    });
    return it('should remove the bold tag from the selected content if the bold tag is applied to all of the selection', function() {
      var element, region, selection, tool;
      element = new ContentEdit.Text('p', {}, '<b>test</b>');
      region = new ContentEdit.Region(document.createElement('div'));
      region.attach(element);
      selection = new ContentSelect.Range(0, 4);
      tool = ContentTools.Tools.Bold;
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('test');
    });
  });

  describe('ContentTools.Tools.Bold.canApply()', function() {
    return it('should return true if the element supports content and the selection is not collapsed', function() {
      var element, selection, tool;
      element = new ContentEdit.Text('p', {}, 'test');
      tool = ContentTools.Tools.Bold;
      selection = new ContentSelect.Range(0, 2);
      expect(tool.canApply(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 0);
      expect(tool.canApply(element, selection)).toBe(false);
      element = new ContentEdit.Image();
      return expect(tool.canApply(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Bold.isApplied()', function() {
    return it('should return true if the selected content is wrapped in a bold tag', function() {
      var element, selection, tool;
      element = new ContentEdit.Text('p', {}, '<b>te</b>st');
      tool = ContentTools.Tools.Bold;
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
      region = new ContentEdit.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 4);
      tool = ContentTools.Tools.Italic;
      element = new ContentEdit.Text('p', {}, 'test');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      expect(element.content.html()).toBe('<i>test</i>');
      element = new ContentEdit.Text('p', {}, '<i>te</i>st');
      region.attach(element);
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('<i>test</i>');
    });
    return it('should remove the italic tag from the selected content if the italic tag is applied to all of the selection', function() {
      var element, region, selection, tool;
      element = new ContentEdit.Text('p', {}, '<i>test</i>');
      region = new ContentEdit.Region(document.createElement('div'));
      region.attach(element);
      selection = new ContentSelect.Range(0, 4);
      tool = ContentTools.Tools.Italic;
      tool.apply(element, selection, (function(_this) {
        return function() {};
      })(this));
      return expect(element.content.html()).toBe('test');
    });
  });

  describe('ContentTools.Tools.Italic.canApply()', function() {
    return it('should return true if the element supports content and the selection is not collapsed', function() {
      var element, selection, tool;
      element = new ContentEdit.Text('p', {}, 'test');
      tool = ContentTools.Tools.Italic;
      selection = new ContentSelect.Range(0, 2);
      expect(tool.canApply(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 0);
      expect(tool.canApply(element, selection)).toBe(false);
      element = new ContentEdit.Image();
      return expect(tool.canApply(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Italic.isApplied()', function() {
    return it('should return true if the selected content is wrapped in a italic tag', function() {
      var element, selection, tool;
      element = new ContentEdit.Text('p', {}, '<i>te</i>st');
      tool = ContentTools.Tools.Italic;
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
      element = new ContentEdit.Text('p', {}, 'test');
      tool = ContentTools.Tools.Link;
      selection = new ContentSelect.Range(0, 2);
      expect(tool.canApply(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 0);
      expect(tool.canApply(element, selection)).toBe(false);
      element = new ContentEdit.Image();
      return expect(tool.canApply(element, selection)).toBe(true);
    });
  });

  describe('ContentTools.Tools.Link.getAttr()', function() {
    return it('should return an attribute by name for the first anchor tag found in a selection or if the element is an image then for the anchor tag associated with image', function() {
      var element, selection, tool;
      element = new ContentEdit.Text('p', {}, '<a href="#test" target="_blank">te</a><a href="#test2">st</a>');
      tool = ContentTools.Tools.Link;
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
      element = new ContentEdit.Text('p', {}, '<a href="#test">te</a>st');
      tool = ContentTools.Tools.Link;
      selection = new ContentSelect.Range(0, 2);
      expect(tool.isApplied(element, selection)).toBe(true);
      selection = new ContentSelect.Range(0, 4);
      expect(tool.isApplied(element, selection)).toBe(false);
      selection = new ContentSelect.Range(2, 4);
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Heading.apply()', function() {
    return it('should change the tag name of a top level element supporting content to h1', function() {
      var element, region, selection, tool;
      region = new ContentEdit.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = ContentTools.Tools.Heading;
      element = new ContentEdit.Text('p', {}, 'test');
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
      region = new ContentEdit.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = ContentTools.Tools.Heading;
      element = new ContentEdit.Text('p', {}, 'test');
      region.attach(element);
      expect(tool.canApply(element, selection)).toBe(true);
      image = new ContentEdit.Image();
      region.attach(image);
      expect(tool.canApply(image, selection)).toBe(false);
      list = new ContentEdit.List('ul');
      listItem = new ContentEdit.ListItem();
      listItemText = new ContentEdit.ListItemText('test');
      listItem.attach(listItemText);
      list.attach(listItem);
      region.attach(list);
      return expect(tool.canApply(list, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Heading.isApplied()', function() {
    return it('should return false, tool does not support toggling', function() {
      var element, selection, tool;
      tool = ContentTools.Tools.Heading;
      element = new ContentEdit.Text('p', {}, 'test');
      selection = new ContentSelect.Range(0, 0);
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Subheading.apply()', function() {
    return it('should change the tag name of a top level element supporting content to h2', function() {
      var element, region, selection, tool;
      region = new ContentEdit.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = ContentTools.Tools.Subheading;
      element = new ContentEdit.Text('p', {}, 'test');
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
      region = new ContentEdit.Region(document.createElement('div'));
      selection = new ContentSelect.Range(0, 0);
      tool = ContentTools.Tools.Subheading;
      element = new ContentEdit.Text('p', {}, 'test');
      region.attach(element);
      expect(tool.canApply(element, selection)).toBe(true);
      image = new ContentEdit.Image();
      region.attach(image);
      expect(tool.canApply(image, selection)).toBe(false);
      list = new ContentEdit.List('ul');
      listItem = new ContentEdit.ListItem();
      listItemText = new ContentEdit.ListItemText('test');
      listItem.attach(listItemText);
      list.attach(listItem);
      region.attach(list);
      return expect(tool.canApply(list, selection)).toBe(false);
    });
  });

  describe('ContentTools.Tools.Subheading.isApplied()', function() {
    return it('should return false, tool does not support toggling', function() {
      var element, selection, tool;
      tool = ContentTools.Tools.Subheading;
      element = new ContentEdit.Text('p', {}, 'test');
      selection = new ContentSelect.Range(0, 0);
      return expect(tool.isApplied(element, selection)).toBe(false);
    });
  });

  describe('ContentTools.StylePalette.add()', function() {
    return it('should return a `ContentTools.Style` instance', function() {
      var style;
      style = new ContentTools.Style('test', 'test', ['test']);
      ContentTools.StylePalette.add(style);
      return expect(ContentTools.StylePalette.styles('test')).toEqual([style]);
    });
  });

  describe('ContentTools.StylePalette.styles()', function() {
    return it('should return a list of `ContentTools.Style` instances by tag name', function() {
      var test1, test2, test3;
      test1 = new ContentTools.Style('Test 1', 'test-1', ['p']);
      test2 = new ContentTools.Style('Test 2', 'test-2', ['h1', 'p']);
      test3 = new ContentTools.Style('Test 3', 'test-3', ['h1', 'h2']);
      ContentTools.StylePalette.add(test1);
      ContentTools.StylePalette.add(test2);
      ContentTools.StylePalette.add(test3);
      expect(ContentTools.StylePalette.styles('p')).toEqual([test1, test2]);
      expect(ContentTools.StylePalette.styles('h1')).toEqual([test2, test3]);
      return expect(ContentTools.StylePalette.styles('h2')).toEqual([test3]);
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
