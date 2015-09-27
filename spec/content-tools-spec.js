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

  describe('ContentTools.FlashUI', function() {
    var div, editor;
    div = null;
    editor = null;
    beforeEach(function() {
      div = document.createElement('div');
      div.setAttribute('class', 'editable');
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
    describe('ContentTools.FlashUI()', function() {
      it('should return an instance of a FlashUI', function() {
        var flash;
        flash = new ContentTools.FlashUI('ok');
        return expect(flash instanceof ContentTools.FlashUI).toBe(true);
      });
      it('should automatically mount the component', function() {
        var flash;
        flash = new ContentTools.FlashUI('ok');
        return expect(flash.isMounted()).toBe(true);
      });
      return it('should automatically unmount the component after X seconds', function(done) {
        var checkUnmounted, flash;
        flash = new ContentTools.FlashUI('ok');
        checkUnmounted = function() {
          expect(flash.isMounted()).toBe(false);
          return done();
        };
        return setTimeout(checkUnmounted, 3000);
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

  describe('ContentTools.Tools.Link.getHref()', function() {
    return it('should return the href for the first anchor tag found in a selection or if the element is an image then for the anchor tag associated with image', function() {
      var element, selection, tool;
      element = new ContentEdit.Text('p', {}, '<a href="#test">te</a><a href="#test2">st</a>');
      tool = ContentTools.Tools.Link;
      selection = new ContentSelect.Range(0, 2);
      expect(tool.getHref(element, selection)).toBe('#test');
      selection = new ContentSelect.Range(2, 4);
      expect(tool.getHref(element, selection)).toBe('#test2');
      selection = new ContentSelect.Range(1, 4);
      return expect(tool.getHref(element, selection)).toBe('#test');
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
