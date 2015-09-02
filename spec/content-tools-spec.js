(function() {
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
