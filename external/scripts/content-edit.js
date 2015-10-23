(function() {
  window.FSM = {};

  FSM.Machine = (function() {
    function Machine(context) {
      this.context = context;
      this._stateTransitions = {};
      this._stateTransitionsAny = {};
      this._defaultTransition = null;
      this._initialState = null;
      this._currentState = null;
    }

    Machine.prototype.addTransition = function(action, state, nextState, callback) {
      if (!nextState) {
        nextState = state;
      }
      return this._stateTransitions[[action, state]] = [nextState, callback];
    };

    Machine.prototype.addTransitions = function(actions, state, nextState, callback) {
      var action, _i, _len, _results;
      if (!nextState) {
        nextState = state;
      }
      _results = [];
      for (_i = 0, _len = actions.length; _i < _len; _i++) {
        action = actions[_i];
        _results.push(this.addTransition(action, state, nextState, callback));
      }
      return _results;
    };

    Machine.prototype.addTransitionAny = function(state, nextState, callback) {
      if (!nextState) {
        nextState = state;
      }
      return this._stateTransitionsAny[state] = [nextState, callback];
    };

    Machine.prototype.setDefaultTransition = function(state, callback) {
      return this._defaultTransition = [state, callback];
    };

    Machine.prototype.getTransition = function(action, state) {
      if (this._stateTransitions[[action, state]]) {
        return this._stateTransitions[[action, state]];
      } else if (this._stateTransitionsAny[state]) {
        return this._stateTransitionsAny[state];
      } else if (this._defaultTransition) {
        return this._defaultTransition;
      }
      throw new Error("Transition is undefined: (" + action + ", " + state + ")");
    };

    Machine.prototype.getCurrentState = function() {
      return this._currentState;
    };

    Machine.prototype.setInitialState = function(state) {
      this._initialState = state;
      if (!this._currentState) {
        return this.reset();
      }
    };

    Machine.prototype.reset = function() {
      return this._currentState = this._initialState;
    };

    Machine.prototype.process = function(action) {
      var result;
      result = this.getTransition(action, this._currentState);
      if (result[1]) {
        result[1].call(this.context || (this.context = this), action);
      }
      return this._currentState = result[0];
    };

    return Machine;

  })();

}).call(this);

(function() {
  var ALPHA_CHARS, ALPHA_NUMERIC_CHARS, ATTR_DELIM, ATTR_ENTITY_DOUBLE_DELIM, ATTR_ENTITY_NO_DELIM, ATTR_ENTITY_SINGLE_DELIM, ATTR_NAME, ATTR_NAME_FIND_VALUE, ATTR_OR_TAG_END, ATTR_VALUE_DOUBLE_DELIM, ATTR_VALUE_NO_DELIM, ATTR_VALUE_SINGLE_DELIM, CHAR_OR_ENTITY_OR_TAG, CLOSING_TAG, ENTITY, ENTITY_CHARS, OPENING_TAG, OPENNING_OR_CLOSING_TAG, TAG_NAME_CLOSING, TAG_NAME_MUST_CLOSE, TAG_NAME_OPENING, TAG_OPENING_SELF_CLOSING, _Parser,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.HTMLString = {};

  HTMLString.String = (function() {
    String._parser = null;

    function String(html, preserveWhitespace) {
      if (preserveWhitespace == null) {
        preserveWhitespace = false;
      }
      this._preserveWhitespace = preserveWhitespace;
      if (html) {
        if (HTMLString.String._parser === null) {
          HTMLString.String._parser = new _Parser();
        }
        this.characters = HTMLString.String._parser.parse(html, this._preserveWhitespace).characters;
      } else {
        this.characters = [];
      }
    }

    String.prototype.isWhitespace = function() {
      var c, _i, _len, _ref;
      _ref = this.characters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if (!c.isWhitespace()) {
          return false;
        }
      }
      return true;
    };

    String.prototype.length = function() {
      return this.characters.length;
    };

    String.prototype.preserveWhitespace = function() {
      return this._preserveWhitespace;
    };

    String.prototype.capitalize = function() {
      var c, newString;
      newString = this.copy();
      if (newString.length()) {
        c = newString.characters[0]._c.toUpperCase();
        newString.characters[0]._c = c;
      }
      return newString;
    };

    String.prototype.charAt = function(index) {
      return this.characters[index].copy();
    };

    String.prototype.concat = function() {
      var c, indexChar, inheritFormat, inheritedTags, newString, string, strings, tail, _i, _j, _k, _l, _len, _len1, _len2, _ref, _ref1;
      strings = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), inheritFormat = arguments[_i++];
      if (!(typeof inheritFormat === 'undefined' || typeof inheritFormat === 'boolean')) {
        strings.push(inheritFormat);
        inheritFormat = true;
      }
      newString = this.copy();
      for (_j = 0, _len = strings.length; _j < _len; _j++) {
        string = strings[_j];
        if (string.length === 0) {
          continue;
        }
        tail = string;
        if (typeof string === 'string') {
          tail = new HTMLString.String(string, this._preserveWhitespace);
        }
        if (inheritFormat && newString.length()) {
          indexChar = newString.charAt(newString.length() - 1);
          inheritedTags = indexChar.tags();
          if (indexChar.isTag()) {
            inheritedTags.shift();
          }
          if (typeof string !== 'string') {
            tail = tail.copy();
          }
          _ref = tail.characters;
          for (_k = 0, _len1 = _ref.length; _k < _len1; _k++) {
            c = _ref[_k];
            c.addTags.apply(c, inheritedTags);
          }
        }
        _ref1 = tail.characters;
        for (_l = 0, _len2 = _ref1.length; _l < _len2; _l++) {
          c = _ref1[_l];
          newString.characters.push(c);
        }
      }
      return newString;
    };

    String.prototype.contains = function(substring) {
      var c, found, from, i, _i, _len, _ref;
      if (typeof substring === 'string') {
        return this.text().indexOf(substring) > -1;
      }
      from = 0;
      while (from <= (this.length() - substring.length())) {
        found = true;
        _ref = substring.characters;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          c = _ref[i];
          if (!c.eq(this.characters[i + from])) {
            found = false;
            break;
          }
        }
        if (found) {
          return true;
        }
        from++;
      }
      return false;
    };

    String.prototype.endsWith = function(substring) {
      var c, characters, i, _i, _len, _ref;
      if (typeof substring === 'string') {
        return substring === '' || this.text().slice(-substring.length) === substring;
      }
      characters = this.characters.slice().reverse();
      _ref = substring.characters.slice().reverse();
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        c = _ref[i];
        if (!c.eq(characters[i])) {
          return false;
        }
      }
      return true;
    };

    String.prototype.format = function() {
      var c, from, i, newString, tags, to, _i;
      from = arguments[0], to = arguments[1], tags = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (to < 0) {
        to = this.length() + to + 1;
      }
      if (from < 0) {
        from = this.length() + from;
      }
      newString = this.copy();
      for (i = _i = from; from <= to ? _i < to : _i > to; i = from <= to ? ++_i : --_i) {
        c = newString.characters[i];
        c.addTags.apply(c, tags);
      }
      return newString;
    };

    String.prototype.hasTags = function() {
      var c, found, strict, tags, _i, _j, _len, _ref;
      tags = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), strict = arguments[_i++];
      if (!(typeof strict === 'undefined' || typeof strict === 'boolean')) {
        tags.push(strict);
        strict = false;
      }
      found = false;
      _ref = this.characters;
      for (_j = 0, _len = _ref.length; _j < _len; _j++) {
        c = _ref[_j];
        if (c.hasTags.apply(c, tags)) {
          found = true;
        } else {
          if (strict) {
            return false;
          }
        }
      }
      return found;
    };

    String.prototype.html = function() {
      var c, closingTag, closingTags, head, html, openHeads, openTag, openTags, tag, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3;
      html = '';
      openTags = [];
      openHeads = [];
      closingTags = [];
      _ref = this.characters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        closingTags = [];
        _ref1 = openTags.slice().reverse();
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          openTag = _ref1[_j];
          closingTags.push(openTag);
          if (!c.hasTags(openTag)) {
            for (_k = 0, _len2 = closingTags.length; _k < _len2; _k++) {
              closingTag = closingTags[_k];
              html += closingTag.tail();
              openTags.pop();
              openHeads.pop();
            }
            closingTags = [];
          }
        }
        _ref2 = c._tags;
        for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
          tag = _ref2[_l];
          if (openHeads.indexOf(tag.head()) === -1) {
            if (!tag.selfClosing()) {
              head = tag.head();
              html += head;
              openTags.push(tag);
              openHeads.push(head);
            }
          }
        }
        if (c._tags.length > 0 && c._tags[0].selfClosing()) {
          html += c._tags[0].head();
        }
        html += c.c();
      }
      _ref3 = openTags.reverse();
      for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
        tag = _ref3[_m];
        html += tag.tail();
      }
      return html;
    };

    String.prototype.indexOf = function(substring, from) {
      var c, found, i, skip, _i, _j, _len, _len1, _ref;
      if (from == null) {
        from = 0;
      }
      if (from < 0) {
        from = 0;
      }
      if (typeof substring === 'string') {
        if (!this.contains(substring)) {
          return -1;
        }
        substring = substring.split('');
        while (from <= (this.length() - substring.length)) {
          found = true;
          skip = 0;
          for (i = _i = 0, _len = substring.length; _i < _len; i = ++_i) {
            c = substring[i];
            if (this.characters[i + from].isTag()) {
              skip += 1;
            }
            if (c !== this.characters[skip + i + from].c()) {
              found = false;
              break;
            }
          }
          if (found) {
            return from;
          }
          from++;
        }
        return -1;
      }
      while (from <= (this.length() - substring.length())) {
        found = true;
        _ref = substring.characters;
        for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
          c = _ref[i];
          if (!c.eq(this.characters[i + from])) {
            found = false;
            break;
          }
        }
        if (found) {
          return from;
        }
        from++;
      }
      return -1;
    };

    String.prototype.insert = function(index, substring, inheritFormat) {
      var c, head, indexChar, inheritedTags, middle, newString, tail, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      if (inheritFormat == null) {
        inheritFormat = true;
      }
      head = this.slice(0, index);
      tail = this.slice(index);
      if (index < 0) {
        index = this.length() + index;
      }
      middle = substring;
      if (typeof substring === 'string') {
        middle = new HTMLString.String(substring, this._preserveWhitespace);
      }
      if (inheritFormat && index > 0) {
        indexChar = this.charAt(index - 1);
        inheritedTags = indexChar.tags();
        if (indexChar.isTag()) {
          inheritedTags.shift();
        }
        if (typeof substring !== 'string') {
          middle = middle.copy();
        }
        _ref = middle.characters;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          c.addTags.apply(c, inheritedTags);
        }
      }
      newString = head;
      _ref1 = middle.characters;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        c = _ref1[_j];
        newString.characters.push(c);
      }
      _ref2 = tail.characters;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        c = _ref2[_k];
        newString.characters.push(c);
      }
      return newString;
    };

    String.prototype.lastIndexOf = function(substring, from) {
      var c, characters, found, i, skip, _i, _j, _len, _len1;
      if (from == null) {
        from = 0;
      }
      if (from < 0) {
        from = 0;
      }
      characters = this.characters.slice(from).reverse();
      from = 0;
      if (typeof substring === 'string') {
        if (!this.contains(substring)) {
          return -1;
        }
        substring = substring.split('').reverse();
        while (from <= (characters.length - substring.length)) {
          found = true;
          skip = 0;
          for (i = _i = 0, _len = substring.length; _i < _len; i = ++_i) {
            c = substring[i];
            if (characters[i + from].isTag()) {
              skip += 1;
            }
            if (c !== characters[skip + i + from].c()) {
              found = false;
              break;
            }
          }
          if (found) {
            return from;
          }
          from++;
        }
        return -1;
      }
      substring = substring.characters.slice().reverse();
      while (from <= (characters.length - substring.length)) {
        found = true;
        for (i = _j = 0, _len1 = substring.length; _j < _len1; i = ++_j) {
          c = substring[i];
          if (!c.eq(characters[i + from])) {
            found = false;
            break;
          }
        }
        if (found) {
          return from;
        }
        from++;
      }
      return -1;
    };

    String.prototype.optimize = function() {
      var c, closingTag, closingTags, head, lastC, len, openHeads, openTag, openTags, runLength, runLengthSort, runLengths, run_length, t, tag, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _m, _n, _o, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results;
      openTags = [];
      openHeads = [];
      lastC = null;
      _ref = this.characters.slice().reverse();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        c._runLengthMap = {};
        c._runLengthMapSize = 0;
        closingTags = [];
        _ref1 = openTags.slice().reverse();
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          openTag = _ref1[_j];
          closingTags.push(openTag);
          if (!c.hasTags(openTag)) {
            for (_k = 0, _len2 = closingTags.length; _k < _len2; _k++) {
              closingTag = closingTags[_k];
              openTags.pop();
              openHeads.pop();
            }
            closingTags = [];
          }
        }
        _ref2 = c._tags;
        for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
          tag = _ref2[_l];
          if (openHeads.indexOf(tag.head()) === -1) {
            if (!tag.selfClosing()) {
              openTags.push(tag);
              openHeads.push(tag.head());
            }
          }
        }
        for (_m = 0, _len4 = openTags.length; _m < _len4; _m++) {
          tag = openTags[_m];
          head = tag.head();
          if (!lastC) {
            c._runLengthMap[head] = [tag, 1];
            continue;
          }
          if (!c._runLengthMap[head]) {
            c._runLengthMap[head] = [tag, 0];
          }
          run_length = 0;
          if (lastC._runLengthMap[head]) {
            run_length = lastC._runLengthMap[head][1];
          }
          c._runLengthMap[head][1] = run_length + 1;
        }
        lastC = c;
      }
      runLengthSort = function(a, b) {
        return b[1] - a[1];
      };
      _ref3 = this.characters;
      _results = [];
      for (_n = 0, _len5 = _ref3.length; _n < _len5; _n++) {
        c = _ref3[_n];
        len = c._tags.length;
        if ((len > 0 && c._tags[0].selfClosing() && len < 3) || len < 2) {
          continue;
        }
        runLengths = [];
        _ref4 = c._runLengthMap;
        for (tag in _ref4) {
          runLength = _ref4[tag];
          runLengths.push(runLength);
        }
        runLengths.sort(runLengthSort);
        _ref5 = c._tags.slice();
        for (_o = 0, _len6 = _ref5.length; _o < _len6; _o++) {
          tag = _ref5[_o];
          if (!tag.selfClosing()) {
            c.removeTags(tag);
          }
        }
        _results.push(c.addTags.apply(c, (function() {
          var _len7, _p, _results1;
          _results1 = [];
          for (_p = 0, _len7 = runLengths.length; _p < _len7; _p++) {
            t = runLengths[_p];
            _results1.push(t[0]);
          }
          return _results1;
        })()));
      }
      return _results;
    };

    String.prototype.slice = function(from, to) {
      var c, newString;
      newString = new HTMLString.String('', this._preserveWhitespace);
      newString.characters = (function() {
        var _i, _len, _ref, _results;
        _ref = this.characters.slice(from, to);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c.copy());
        }
        return _results;
      }).call(this);
      return newString;
    };

    String.prototype.split = function(separator, limit) {
      var count, i, index, indexes, lastIndex, substrings, _i, _ref;
      if (separator == null) {
        separator = '';
      }
      if (limit == null) {
        limit = 0;
      }
      lastIndex = 0;
      count = 0;
      indexes = [0];
      while (true) {
        if (limit > 0 && count > limit) {
          break;
        }
        index = this.indexOf(separator, lastIndex);
        if (index === -1 || index === (this.length() - 1)) {
          break;
        }
        indexes.push(index);
        lastIndex = index + 1;
      }
      indexes.push(this.length());
      substrings = [];
      for (i = _i = 0, _ref = indexes.length - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        substrings.push(this.slice(indexes[i], indexes[i + 1]));
      }
      return substrings;
    };

    String.prototype.startsWith = function(substring) {
      var c, i, _i, _len, _ref;
      if (typeof substring === 'string') {
        return this.text().slice(0, substring.length) === substring;
      }
      _ref = substring.characters;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        c = _ref[i];
        if (!c.eq(this.characters[i])) {
          return false;
        }
      }
      return true;
    };

    String.prototype.substr = function(from, length) {
      if (length <= 0) {
        return new HTMLString.String('', this._preserveWhitespace);
      }
      if (from < 0) {
        from = this.length() + from;
      }
      if (length === void 0) {
        length = this.length() - from;
      }
      return this.slice(from, from + length);
    };

    String.prototype.substring = function(from, to) {
      if (to === void 0) {
        to = this.length();
      }
      return this.slice(from, to);
    };

    String.prototype.text = function() {
      var c, text, _i, _len, _ref;
      text = '';
      _ref = this.characters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if (c.isTag()) {
          if (c.isTag('br')) {
            text += '\n';
          }
          continue;
        }
        if (c.c() === '&nbsp;') {
          text += c.c();
          continue;
        }
        text += c.c();
      }
      return this.constructor.decode(text);
    };

    String.prototype.toLowerCase = function() {
      var c, newString, _i, _len, _ref;
      newString = this.copy();
      _ref = newString.characters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if (c._c.length === 1) {
          c._c = c._c.toLowerCase();
        }
      }
      return newString;
    };

    String.prototype.toUpperCase = function() {
      var c, newString, _i, _len, _ref;
      newString = this.copy();
      _ref = newString.characters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if (c._c.length === 1) {
          c._c = c._c.toUpperCase();
        }
      }
      return newString;
    };

    String.prototype.trim = function() {
      var c, from, newString, to, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.characters;
      for (from = _i = 0, _len = _ref.length; _i < _len; from = ++_i) {
        c = _ref[from];
        if (!c.isWhitespace()) {
          break;
        }
      }
      _ref1 = this.characters.slice().reverse();
      for (to = _j = 0, _len1 = _ref1.length; _j < _len1; to = ++_j) {
        c = _ref1[to];
        if (!c.isWhitespace()) {
          break;
        }
      }
      to = this.length() - to - 1;
      newString = new HTMLString.String('', this._preserveWhitespace);
      newString.characters = (function() {
        var _k, _len2, _ref2, _results;
        _ref2 = this.characters.slice(from, +to + 1 || 9e9);
        _results = [];
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          c = _ref2[_k];
          _results.push(c.copy());
        }
        return _results;
      }).call(this);
      return newString;
    };

    String.prototype.trimLeft = function() {
      var c, from, newString, to, _i, _len, _ref;
      to = this.length() - 1;
      _ref = this.characters;
      for (from = _i = 0, _len = _ref.length; _i < _len; from = ++_i) {
        c = _ref[from];
        if (!c.isWhitespace()) {
          break;
        }
      }
      newString = new HTMLString.String('', this._preserveWhitespace);
      newString.characters = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = this.characters.slice(from, +to + 1 || 9e9);
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          c = _ref1[_j];
          _results.push(c.copy());
        }
        return _results;
      }).call(this);
      return newString;
    };

    String.prototype.trimRight = function() {
      var c, from, newString, to, _i, _len, _ref;
      from = 0;
      _ref = this.characters.slice().reverse();
      for (to = _i = 0, _len = _ref.length; _i < _len; to = ++_i) {
        c = _ref[to];
        if (!c.isWhitespace()) {
          break;
        }
      }
      to = this.length() - to - 1;
      newString = new HTMLString.String('', this._preserveWhitespace);
      newString.characters = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = this.characters.slice(from, +to + 1 || 9e9);
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          c = _ref1[_j];
          _results.push(c.copy());
        }
        return _results;
      }).call(this);
      return newString;
    };

    String.prototype.unformat = function() {
      var c, from, i, newString, tags, to, _i;
      from = arguments[0], to = arguments[1], tags = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (to < 0) {
        to = this.length() + to + 1;
      }
      if (from < 0) {
        from = this.length() + from;
      }
      newString = this.copy();
      for (i = _i = from; from <= to ? _i < to : _i > to; i = from <= to ? ++_i : --_i) {
        c = newString.characters[i];
        c.removeTags.apply(c, tags);
      }
      return newString;
    };

    String.prototype.copy = function() {
      var c, stringCopy;
      stringCopy = new HTMLString.String('', this._preserveWhitespace);
      stringCopy.characters = (function() {
        var _i, _len, _ref, _results;
        _ref = this.characters;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c.copy());
        }
        return _results;
      }).call(this);
      return stringCopy;
    };

    String.encode = function(string) {
      var textarea;
      textarea = document.createElement('textarea');
      textarea.textContent = string;
      return textarea.innerHTML;
    };

    String.decode = function(string) {
      var textarea;
      textarea = document.createElement('textarea');
      textarea.innerHTML = string;
      return textarea.textContent;
    };

    return String;

  })();

  ALPHA_CHARS = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz-_$'.split('');

  ALPHA_NUMERIC_CHARS = ALPHA_CHARS.concat('1234567890'.split(''));

  ENTITY_CHARS = ALPHA_NUMERIC_CHARS.concat(['#']);

  CHAR_OR_ENTITY_OR_TAG = 1;

  ENTITY = 2;

  OPENNING_OR_CLOSING_TAG = 3;

  OPENING_TAG = 4;

  CLOSING_TAG = 5;

  TAG_NAME_OPENING = 6;

  TAG_NAME_CLOSING = 7;

  TAG_OPENING_SELF_CLOSING = 8;

  TAG_NAME_MUST_CLOSE = 9;

  ATTR_OR_TAG_END = 10;

  ATTR_NAME = 11;

  ATTR_NAME_FIND_VALUE = 12;

  ATTR_DELIM = 13;

  ATTR_VALUE_SINGLE_DELIM = 14;

  ATTR_VALUE_DOUBLE_DELIM = 15;

  ATTR_VALUE_NO_DELIM = 16;

  ATTR_ENTITY_NO_DELIM = 17;

  ATTR_ENTITY_SINGLE_DELIM = 18;

  ATTR_ENTITY_DOUBLE_DELIM = 19;

  _Parser = (function() {
    function _Parser() {
      this.fsm = new FSM.Machine(this);
      this.fsm.setInitialState(CHAR_OR_ENTITY_OR_TAG);
      this.fsm.addTransitionAny(CHAR_OR_ENTITY_OR_TAG, null, function(c) {
        return this._pushChar(c);
      });
      this.fsm.addTransition('<', CHAR_OR_ENTITY_OR_TAG, OPENNING_OR_CLOSING_TAG);
      this.fsm.addTransition('&', CHAR_OR_ENTITY_OR_TAG, ENTITY);
      this.fsm.addTransitions(ENTITY_CHARS, ENTITY, null, function(c) {
        return this.entity += c;
      });
      this.fsm.addTransition(';', ENTITY, CHAR_OR_ENTITY_OR_TAG, function() {
        this._pushChar("&" + this.entity + ";");
        return this.entity = '';
      });
      this.fsm.addTransitions([' ', '\n'], OPENNING_OR_CLOSING_TAG);
      this.fsm.addTransitions(ALPHA_CHARS, OPENNING_OR_CLOSING_TAG, OPENING_TAG, function() {
        return this._back();
      });
      this.fsm.addTransition('/', OPENNING_OR_CLOSING_TAG, CLOSING_TAG);
      this.fsm.addTransitions([' ', '\n'], OPENING_TAG);
      this.fsm.addTransitions(ALPHA_CHARS, OPENING_TAG, TAG_NAME_OPENING, function() {
        return this._back();
      });
      this.fsm.addTransitions([' ', '\n'], CLOSING_TAG);
      this.fsm.addTransitions(ALPHA_CHARS, CLOSING_TAG, TAG_NAME_CLOSING, function() {
        return this._back();
      });
      this.fsm.addTransitions(ALPHA_NUMERIC_CHARS, TAG_NAME_OPENING, null, function(c) {
        return this.tagName += c;
      });
      this.fsm.addTransitions([' ', '\n'], TAG_NAME_OPENING, ATTR_OR_TAG_END);
      this.fsm.addTransition('/', TAG_NAME_OPENING, TAG_OPENING_SELF_CLOSING, function() {
        return this.selfClosing = true;
      });
      this.fsm.addTransition('>', TAG_NAME_OPENING, CHAR_OR_ENTITY_OR_TAG, function() {
        return this._pushTag();
      });
      this.fsm.addTransitions([' ', '\n'], TAG_OPENING_SELF_CLOSING);
      this.fsm.addTransition('>', TAG_OPENING_SELF_CLOSING, CHAR_OR_ENTITY_OR_TAG, function() {
        return this._pushTag();
      });
      this.fsm.addTransitions([' ', '\n'], ATTR_OR_TAG_END);
      this.fsm.addTransition('/', ATTR_OR_TAG_END, TAG_OPENING_SELF_CLOSING, function() {
        return this.selfClosing = true;
      });
      this.fsm.addTransition('>', ATTR_OR_TAG_END, CHAR_OR_ENTITY_OR_TAG, function() {
        return this._pushTag();
      });
      this.fsm.addTransitions(ALPHA_CHARS, ATTR_OR_TAG_END, ATTR_NAME, function() {
        return this._back();
      });
      this.fsm.addTransitions(ALPHA_NUMERIC_CHARS, TAG_NAME_CLOSING, null, function(c) {
        return this.tagName += c;
      });
      this.fsm.addTransitions([' ', '\n'], TAG_NAME_CLOSING, TAG_NAME_MUST_CLOSE);
      this.fsm.addTransition('>', TAG_NAME_CLOSING, CHAR_OR_ENTITY_OR_TAG, function() {
        return this._popTag();
      });
      this.fsm.addTransitions([' ', '\n'], TAG_NAME_MUST_CLOSE);
      this.fsm.addTransition('>', TAG_NAME_MUST_CLOSE, CHAR_OR_ENTITY_OR_TAG, function() {
        return this._popTag();
      });
      this.fsm.addTransitions(ALPHA_NUMERIC_CHARS, ATTR_NAME, null, function(c) {
        return this.attributeName += c;
      });
      this.fsm.addTransitions([' ', '\n'], ATTR_NAME, ATTR_NAME_FIND_VALUE);
      this.fsm.addTransition('=', ATTR_NAME, ATTR_DELIM);
      this.fsm.addTransitions([' ', '\n'], ATTR_NAME_FIND_VALUE);
      this.fsm.addTransition('=', ATTR_NAME_FIND_VALUE, ATTR_DELIM);
      this.fsm.addTransitions('>', ATTR_NAME, ATTR_OR_TAG_END, function() {
        this._pushAttribute();
        return this._back();
      });
      this.fsm.addTransitionAny(ATTR_NAME_FIND_VALUE, ATTR_OR_TAG_END, function() {
        this._pushAttribute();
        return this._back();
      });
      this.fsm.addTransitions([' ', '\n'], ATTR_DELIM);
      this.fsm.addTransition('\'', ATTR_DELIM, ATTR_VALUE_SINGLE_DELIM);
      this.fsm.addTransition('"', ATTR_DELIM, ATTR_VALUE_DOUBLE_DELIM);
      this.fsm.addTransitions(ALPHA_NUMERIC_CHARS.concat(['&'], ATTR_DELIM, ATTR_VALUE_NO_DELIM, function() {
        return this._back();
      }));
      this.fsm.addTransition(' ', ATTR_VALUE_NO_DELIM, ATTR_OR_TAG_END, function() {
        return this._pushAttribute();
      });
      this.fsm.addTransitions(['/', '>'], ATTR_VALUE_NO_DELIM, ATTR_OR_TAG_END, function() {
        this._back();
        return this._pushAttribute();
      });
      this.fsm.addTransition('&', ATTR_VALUE_NO_DELIM, ATTR_ENTITY_NO_DELIM);
      this.fsm.addTransitionAny(ATTR_VALUE_NO_DELIM, null, function(c) {
        return this.attributeValue += c;
      });
      this.fsm.addTransition('\'', ATTR_VALUE_SINGLE_DELIM, ATTR_OR_TAG_END, function() {
        return this._pushAttribute();
      });
      this.fsm.addTransition('&', ATTR_VALUE_SINGLE_DELIM, ATTR_ENTITY_SINGLE_DELIM);
      this.fsm.addTransitionAny(ATTR_VALUE_SINGLE_DELIM, null, function(c) {
        return this.attributeValue += c;
      });
      this.fsm.addTransition('"', ATTR_VALUE_DOUBLE_DELIM, ATTR_OR_TAG_END, function() {
        return this._pushAttribute();
      });
      this.fsm.addTransition('&', ATTR_VALUE_DOUBLE_DELIM, ATTR_ENTITY_DOUBLE_DELIM);
      this.fsm.addTransitionAny(ATTR_VALUE_DOUBLE_DELIM, null, function(c) {
        return this.attributeValue += c;
      });
      this.fsm.addTransitions(ENTITY_CHARS, ATTR_ENTITY_NO_DELIM, null, function(c) {
        return this.entity += c;
      });
      this.fsm.addTransitions(ENTITY_CHARS, ATTR_ENTITY_SINGLE_DELIM, function(c) {
        return this.entity += c;
      });
      this.fsm.addTransitions(ENTITY_CHARS, ATTR_ENTITY_DOUBLE_DELIM, null, function(c) {
        return this.entity += c;
      });
      this.fsm.addTransition(';', ATTR_ENTITY_NO_DELIM, ATTR_VALUE_NO_DELIM, function() {
        this.attributeValue += "&" + this.entity + ";";
        return this.entity = '';
      });
      this.fsm.addTransition(';', ATTR_ENTITY_SINGLE_DELIM, ATTR_VALUE_SINGLE_DELIM, function() {
        this.attributeValue += "&" + this.entity + ";";
        return this.entity = '';
      });
      this.fsm.addTransition(';', ATTR_ENTITY_DOUBLE_DELIM, ATTR_VALUE_DOUBLE_DELIM, function() {
        this.attributeValue += "&" + this.entity + ";";
        return this.entity = '';
      });
    }

    _Parser.prototype._back = function() {
      return this.head--;
    };

    _Parser.prototype._pushAttribute = function() {
      this.attributes[this.attributeName] = this.attributeValue;
      this.attributeName = '';
      return this.attributeValue = '';
    };

    _Parser.prototype._pushChar = function(c) {
      var character, lastCharacter;
      character = new HTMLString.Character(c, this.tags);
      if (this._preserveWhitespace) {
        this.string.characters.push(character);
        return;
      }
      if (this.string.length() && !character.isTag() && !character.isEntity() && character.isWhitespace()) {
        lastCharacter = this.string.characters[this.string.length() - 1];
        if (lastCharacter.isWhitespace() && !lastCharacter.isTag() && !lastCharacter.isEntity()) {
          return;
        }
      }
      return this.string.characters.push(character);
    };

    _Parser.prototype._pushTag = function() {
      var tag, _ref;
      tag = new HTMLString.Tag(this.tagName, this.attributes);
      this.tags.push(tag);
      if (tag.selfClosing()) {
        this._pushChar('');
        this.tags.pop();
        if (!this.selfClosed && (_ref = this.tagName, __indexOf.call(HTMLString.Tag.SELF_CLOSING, _ref) >= 0)) {
          this.fsm.reset();
        }
      }
      this.tagName = '';
      this.selfClosed = false;
      return this.attributes = [];
    };

    _Parser.prototype._popTag = function() {
      var character, tag;
      while (true) {
        tag = this.tags.pop();
        if (this.string.length()) {
          character = this.string.characters[this.string.length() - 1];
          if (!character.isTag() && character.isWhitespace()) {
            character.removeTags(tag);
          }
        }
        if (tag.name() === this.tagName.toLowerCase()) {
          break;
        }
      }
      return this.tagName = '';
    };

    _Parser.prototype.parse = function(html, preserveWhitespace) {
      var character, error;
      this._preserveWhitespace = preserveWhitespace;
      this.reset();
      html = this.preprocess(html);
      this.fsm.parser = this;
      while (this.head < html.length) {
        character = html[this.head];
        try {
          this.fsm.process(character);
        } catch (_error) {
          error = _error;
          throw new Error("Error at char " + this.head + " >> " + error);
        }
        this.head++;
      }
      return this.string;
    };

    _Parser.prototype.preprocess = function(html) {
      html = html.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
      html = html.replace(/<!--[\s\S]*?-->/g, '');
      if (!this._preserveWhitespace) {
        html = html.replace(/\s+/g, ' ');
      }
      return html;
    };

    _Parser.prototype.reset = function() {
      this.fsm.reset();
      this.head = 0;
      this.string = new HTMLString.String();
      this.entity = '';
      this.tags = [];
      this.tagName = '';
      this.selfClosing = false;
      this.attributes = {};
      this.attributeName = '';
      return this.attributeValue = '';
    };

    return _Parser;

  })();

  HTMLString.Tag = (function() {
    function Tag(name, attributes) {
      var k, v;
      this._name = name.toLowerCase();
      this._selfClosing = HTMLString.Tag.SELF_CLOSING[this._name] === true;
      this._head = null;
      this._attributes = {};
      for (k in attributes) {
        v = attributes[k];
        this._attributes[k] = v;
      }
    }

    Tag.SELF_CLOSING = {
      'area': true,
      'base': true,
      'br': true,
      'hr': true,
      'img': true,
      'input': true,
      'link meta': true,
      'wbr': true
    };

    Tag.prototype.head = function() {
      var components, k, v, _ref;
      if (!this._head) {
        components = [];
        _ref = this._attributes;
        for (k in _ref) {
          v = _ref[k];
          if (v) {
            components.push("" + k + "=\"" + v + "\"");
          } else {
            components.push("" + k);
          }
        }
        components.sort();
        components.unshift(this._name);
        this._head = "<" + (components.join(' ')) + ">";
      }
      return this._head;
    };

    Tag.prototype.name = function() {
      return this._name;
    };

    Tag.prototype.selfClosing = function() {
      return this._selfClosing;
    };

    Tag.prototype.tail = function() {
      if (this._selfClosing) {
        return '';
      }
      return "</" + this._name + ">";
    };

    Tag.prototype.attr = function(name, value) {
      if (value === void 0) {
        return this._attributes[name];
      }
      this._attributes[name] = value;
      return this._head = null;
    };

    Tag.prototype.removeAttr = function(name) {
      if (this._attributes[name] === void 0) {
        return;
      }
      return delete this._attributes[name];
    };

    Tag.prototype.copy = function() {
      return new HTMLString.Tag(this._name, this._attributes);
    };

    return Tag;

  })();

  HTMLString.Character = (function() {
    function Character(c, tags) {
      this._c = c;
      if (c.length > 1) {
        this._c = c.toLowerCase();
      }
      this._tags = [];
      this.addTags.apply(this, tags);
    }

    Character.prototype.c = function() {
      return this._c;
    };

    Character.prototype.isEntity = function() {
      return this._c.length > 1;
    };

    Character.prototype.isTag = function(tagName) {
      if (this._tags.length === 0 || !this._tags[0].selfClosing()) {
        return false;
      }
      if (tagName && this._tags[0].name() !== tagName) {
        return false;
      }
      return true;
    };

    Character.prototype.isWhitespace = function() {
      var _ref;
      return ((_ref = this._c) === ' ' || _ref === '\n' || _ref === '&nbsp;') || this.isTag('br');
    };

    Character.prototype.tags = function() {
      var t;
      return (function() {
        var _i, _len, _ref, _results;
        _ref = this._tags;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          _results.push(t.copy());
        }
        return _results;
      }).call(this);
    };

    Character.prototype.addTags = function() {
      var tag, tags, _i, _len, _results;
      tags = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = tags.length; _i < _len; _i++) {
        tag = tags[_i];
        if (tag.selfClosing()) {
          if (!this.isTag()) {
            this._tags.unshift(tag.copy());
          }
          continue;
        }
        _results.push(this._tags.push(tag.copy()));
      }
      return _results;
    };

    Character.prototype.eq = function(c) {
      var tag, tags, _i, _j, _len, _len1, _ref, _ref1;
      if (this.c() !== c.c()) {
        return false;
      }
      if (this._tags.length !== c._tags.length) {
        return false;
      }
      tags = {};
      _ref = this._tags;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tag = _ref[_i];
        tags[tag.head()] = true;
      }
      _ref1 = c._tags;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        tag = _ref1[_j];
        if (!tags[tag.head()]) {
          return false;
        }
      }
      return true;
    };

    Character.prototype.hasTags = function() {
      var tag, tagHeads, tagNames, tags, _i, _j, _len, _len1, _ref;
      tags = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      tagNames = {};
      tagHeads = {};
      _ref = this._tags;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tag = _ref[_i];
        tagNames[tag.name()] = true;
        tagHeads[tag.head()] = true;
      }
      for (_j = 0, _len1 = tags.length; _j < _len1; _j++) {
        tag = tags[_j];
        if (typeof tag === 'string') {
          if (tagNames[tag] === void 0) {
            return false;
          }
        } else {
          if (tagHeads[tag.head()] === void 0) {
            return false;
          }
        }
      }
      return true;
    };

    Character.prototype.removeTags = function() {
      var heads, names, newTags, tag, tags, _i, _len;
      tags = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (tags.length === 0) {
        this._tags = [];
        return;
      }
      names = {};
      heads = {};
      for (_i = 0, _len = tags.length; _i < _len; _i++) {
        tag = tags[_i];
        if (typeof tag === 'string') {
          names[tag] = tag;
        } else {
          heads[tag.head()] = tag;
        }
      }
      newTags = [];
      return this._tags = this._tags.filter(function(tag) {
        if (!heads[tag.head()] && !names[tag.name()]) {
          return tag;
        }
      });
    };

    Character.prototype.copy = function() {
      var t;
      return new HTMLString.Character(this._c, (function() {
        var _i, _len, _ref, _results;
        _ref = this._tags;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          _results.push(t.copy());
        }
        return _results;
      }).call(this));
    };

    return Character;

  })();

}).call(this);

(function() {
  var SELF_CLOSING_NODE_NAMES, _containedBy, _getChildNodeAndOffset, _getNodeRange, _getOffsetOfChildNode,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.ContentSelect = {};

  ContentSelect.Range = (function() {
    function Range(from, to) {
      this.set(from, to);
    }

    Range.prototype.isCollapsed = function() {
      return this._from === this._to;
    };

    Range.prototype.span = function() {
      return this._to - this._from;
    };

    Range.prototype.collapse = function() {
      return this._to = this._from;
    };

    Range.prototype.eq = function(range) {
      return this.get()[0] === range.get()[0] && this.get()[1] === range.get()[1];
    };

    Range.prototype.get = function() {
      return [this._from, this._to];
    };

    Range.prototype.select = function(element) {
      var docRange, endNode, endOffset, startNode, startOffset, _ref, _ref1;
      ContentSelect.Range.unselectAll();
      docRange = document.createRange();
      _ref = _getChildNodeAndOffset(element, this._from), startNode = _ref[0], startOffset = _ref[1];
      _ref1 = _getChildNodeAndOffset(element, this._to), endNode = _ref1[0], endOffset = _ref1[1];
      docRange.setStart(startNode, startOffset);
      docRange.setEnd(endNode, endOffset);
      return window.getSelection().addRange(docRange);
    };

    Range.prototype.set = function(from, to) {
      from = Math.max(0, from);
      to = Math.max(0, to);
      this._from = Math.min(from, to);
      return this._to = Math.max(from, to);
    };

    Range.prepareElement = function(element) {
      var i, node, selfClosingNodes, _i, _len, _results;
      selfClosingNodes = element.querySelectorAll(SELF_CLOSING_NODE_NAMES.join(', '));
      _results = [];
      for (i = _i = 0, _len = selfClosingNodes.length; _i < _len; i = ++_i) {
        node = selfClosingNodes[i];
        node.parentNode.insertBefore(document.createTextNode(''), node);
        if (i < selfClosingNodes.length - 1) {
          _results.push(node.parentNode.insertBefore(document.createTextNode(''), node.nextSibling));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Range.query = function(element) {
      var docRange, endNode, endOffset, range, startNode, startOffset, _ref;
      range = new ContentSelect.Range(0, 0);
      try {
        docRange = window.getSelection().getRangeAt(0);
      } catch (_error) {
        return range;
      }
      if (element.firstChild === null && element.lastChild === null) {
        return range;
      }
      if (!_containedBy(docRange.startContainer, element)) {
        return range;
      }
      if (!_containedBy(docRange.endContainer, element)) {
        return range;
      }
      _ref = _getNodeRange(element, docRange), startNode = _ref[0], startOffset = _ref[1], endNode = _ref[2], endOffset = _ref[3];
      range.set(_getOffsetOfChildNode(element, startNode) + startOffset, _getOffsetOfChildNode(element, endNode) + endOffset);
      return range;
    };

    Range.rect = function() {
      var docRange, marker, rect;
      try {
        docRange = window.getSelection().getRangeAt(0);
      } catch (_error) {
        return null;
      }
      if (docRange.collapsed) {
        marker = document.createElement('span');
        docRange.insertNode(marker);
        rect = marker.getBoundingClientRect();
        marker.parentNode.removeChild(marker);
        return rect;
      } else {
        return docRange.getBoundingClientRect();
      }
    };

    Range.unselectAll = function() {
      if (window.getSelection()) {
        return window.getSelection().removeAllRanges();
      }
    };

    return Range;

  })();

  SELF_CLOSING_NODE_NAMES = ['br', 'img', 'input'];

  _containedBy = function(nodeA, nodeB) {
    while (nodeA) {
      if (nodeA === nodeB) {
        return true;
      }
      nodeA = nodeA.parentNode;
    }
    return false;
  };

  _getChildNodeAndOffset = function(parentNode, parentOffset) {
    var childNode, childOffset, childStack, n, _ref;
    if (parentNode.childNodes.length === 0) {
      return [parentNode, parentOffset];
    }
    childNode = null;
    childOffset = parentOffset;
    childStack = (function() {
      var _i, _len, _ref, _results;
      _ref = parentNode.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push(n);
      }
      return _results;
    })();
    while (childStack.length > 0) {
      childNode = childStack.shift();
      switch (childNode.nodeType) {
        case Node.TEXT_NODE:
          if (childNode.textContent.length >= childOffset) {
            return [childNode, childOffset];
          }
          childOffset -= childNode.textContent.length;
          break;
        case Node.ELEMENT_NODE:
          if (_ref = childNode.nodeName.toLowerCase(), __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref) >= 0) {
            if (childOffset === 0) {
              return [childNode, 0];
            } else {
              childOffset = Math.max(0, childOffset - 1);
            }
          } else {
            if (childNode.childNodes) {
              Array.prototype.unshift.apply(childStack, (function() {
                var _i, _len, _ref1, _results;
                _ref1 = childNode.childNodes;
                _results = [];
                for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                  n = _ref1[_i];
                  _results.push(n);
                }
                return _results;
              })());
            }
          }
      }
    }
    return [childNode, childOffset];
  };

  _getOffsetOfChildNode = function(parentNode, childNode) {
    var childStack, n, offset, otherChildNode, _ref, _ref1;
    if (parentNode.childNodes.length === 0) {
      return 0;
    }
    offset = 0;
    childStack = (function() {
      var _i, _len, _ref, _results;
      _ref = parentNode.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push(n);
      }
      return _results;
    })();
    while (childStack.length > 0) {
      otherChildNode = childStack.shift();
      if (otherChildNode === childNode) {
        if (_ref = otherChildNode.nodeName.toLowerCase(), __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref) >= 0) {
          return offset + 1;
        }
        return offset;
      }
      switch (otherChildNode.nodeType) {
        case Node.TEXT_NODE:
          offset += otherChildNode.textContent.length;
          break;
        case Node.ELEMENT_NODE:
          if (_ref1 = otherChildNode.nodeName.toLowerCase(), __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref1) >= 0) {
            offset += 1;
          } else {
            if (otherChildNode.childNodes) {
              Array.prototype.unshift.apply(childStack, (function() {
                var _i, _len, _ref2, _results;
                _ref2 = otherChildNode.childNodes;
                _results = [];
                for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                  n = _ref2[_i];
                  _results.push(n);
                }
                return _results;
              })());
            }
          }
      }
    }
    return offset;
  };

  _getNodeRange = function(element, docRange) {
    var childNode, childNodes, endNode, endOffset, endRange, i, startNode, startOffset, startRange, _i, _j, _len, _len1, _ref;
    childNodes = element.childNodes;
    startRange = docRange.cloneRange();
    startRange.collapse(true);
    endRange = docRange.cloneRange();
    endRange.collapse(false);
    startNode = startRange.startContainer;
    startOffset = startRange.startOffset;
    endNode = endRange.endContainer;
    endOffset = endRange.endOffset;
    if (!startRange.comparePoint) {
      return [startNode, startOffset, endNode, endOffset];
    }
    if (startNode === element) {
      startNode = childNodes[childNodes.length - 1];
      startOffset = startNode.textContent.length;
      for (i = _i = 0, _len = childNodes.length; _i < _len; i = ++_i) {
        childNode = childNodes[i];
        if (startRange.comparePoint(childNode, 0) !== 1) {
          continue;
        }
        if (i === 0) {
          startNode = childNode;
          startOffset = 0;
        } else {
          startNode = childNodes[i - 1];
          startOffset = childNode.textContent.length;
        }
        if (_ref = startNode.nodeName.toLowerCase, __indexOf.call(SELF_CLOSING_NODE_NAMES, _ref) >= 0) {
          startOffset = 1;
        }
        break;
      }
    }
    if (docRange.collapsed) {
      return [startNode, startOffset, startNode, startOffset];
    }
    if (endNode === element) {
      endNode = childNodes[childNodes.length - 1];
      endOffset = endNode.textContent.length;
      for (i = _j = 0, _len1 = childNodes.length; _j < _len1; i = ++_j) {
        childNode = childNodes[i];
        if (endRange.comparePoint(childNode, 0) !== 1) {
          continue;
        }
        if (i === 0) {
          endNode = childNode;
        } else {
          endNode = childNodes[i - 1];
        }
        endOffset = childNode.textContent.length + 1;
      }
    }
    return [startNode, startOffset, endNode, endOffset];
  };

}).call(this);

(function() {
  var C, _Root, _TagNames, _mergers,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ContentEdit = {
    DEFAULT_MAX_ELEMENT_WIDTH: 800,
    DEFAULT_MIN_ELEMENT_WIDTH: 80,
    DRAG_HOLD_DURATION: 500,
    DROP_EDGE_SIZE: 50,
    HELPER_CHAR_LIMIT: 250,
    INDENT: '    ',
    LANGUAGE: 'en',
    RESIZE_CORNER_SIZE: 15,
    _translations: {},
    _: function(s) {
      var lang;
      lang = ContentEdit.LANGUAGE;
      if (ContentEdit._translations[lang] && ContentEdit._translations[lang][s]) {
        return ContentEdit._translations[lang][s];
      }
      return s;
    },
    addTranslations: function(language, translations) {
      return ContentEdit._translations[language] = translations;
    },
    addCSSClass: function(domElement, className) {
      var c, classAttr, classNames;
      if (domElement.classList) {
        domElement.classList.add(className);
        return;
      }
      classAttr = domElement.getAttribute('class');
      if (classAttr) {
        classNames = (function() {
          var _i, _len, _ref, _results;
          _ref = classAttr.split(' ');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(c);
          }
          return _results;
        })();
        if (classNames.indexOf(className) === -1) {
          return domElement.setAttribute('class', "" + classAttr + " " + className);
        }
      } else {
        return domElement.setAttribute('class', className);
      }
    },
    attributesToString: function(attributes) {
      var attributeStrings, name, names, value, _i, _len;
      if (!attributes) {
        return '';
      }
      names = (function() {
        var _results;
        _results = [];
        for (name in attributes) {
          _results.push(name);
        }
        return _results;
      })();
      names.sort();
      attributeStrings = [];
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        value = attributes[name];
        if (value === '') {
          attributeStrings.push(name);
        } else {
          attributeStrings.push("" + name + "=\"" + value + "\"");
        }
      }
      return attributeStrings.join(' ');
    },
    removeCSSClass: function(domElement, className) {
      var c, classAttr, classNameIndex, classNames;
      if (domElement.classList) {
        domElement.classList.remove(className);
        if (domElement.classList.length === 0) {
          domElement.removeAttribute('class');
        }
        return;
      }
      classAttr = domElement.getAttribute('class');
      if (classAttr) {
        classNames = (function() {
          var _i, _len, _ref, _results;
          _ref = classAttr.split(' ');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(c);
          }
          return _results;
        })();
        classNameIndex = classNames.indexOf(className);
        if (classNameIndex > -1) {
          classNames.splice(classNameIndex, 1);
          if (classNames.length) {
            return domElement.setAttribute('class', classNames.join(' '));
          } else {
            return domElement.removeAttribute('class');
          }
        }
      } else {
        return domElement.setAttribute('class', className);
      }
    }
  };

  if (!(C = (function() {
    function C() {}

    return C;

  })()).name) {
    Object.defineProperty(Function.prototype, 'name', {
      get: function() {
        var name;
        name = this.toString().match(/^\s*function\s*(\S*)\s*\(/)[1];
        Object.defineProperty(this, 'name', {
          value: name
        });
        return name;
      }
    });
  }

  _TagNames = (function() {
    function _TagNames() {
      this._tagNames = {};
    }

    _TagNames.prototype.register = function() {
      var cls, tagName, tagNames, _i, _len, _results;
      cls = arguments[0], tagNames = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _results = [];
      for (_i = 0, _len = tagNames.length; _i < _len; _i++) {
        tagName = tagNames[_i];
        _results.push(this._tagNames[tagName.toLowerCase()] = cls);
      }
      return _results;
    };

    _TagNames.prototype.match = function(tagName) {
      if (this._tagNames[tagName.toLowerCase()]) {
        return this._tagNames[tagName.toLowerCase()];
      }
      return ContentEdit.Static;
    };

    return _TagNames;

  })();

  ContentEdit.TagNames = (function() {
    var instance;

    function TagNames() {}

    instance = null;

    TagNames.get = function() {
      return instance != null ? instance : instance = new _TagNames();
    };

    return TagNames;

  })();

  ContentEdit.Node = (function() {
    function Node() {
      this._bindings = {};
      this._parent = null;
      this._modified = null;
    }

    Node.prototype.lastModified = function() {
      return this._modified;
    };

    Node.prototype.parent = function() {
      return this._parent;
    };

    Node.prototype.parents = function() {
      var parent, parents;
      parents = [];
      parent = this._parent;
      while (parent) {
        parents.push(parent);
        parent = parent._parent;
      }
      return parents;
    };

    Node.prototype.html = function(indent) {
      if (indent == null) {
        indent = '';
      }
      throw new Error('`html` not implemented');
    };

    Node.prototype.bind = function(eventName, callback) {
      if (this._bindings[eventName] === void 0) {
        this._bindings[eventName] = [];
      }
      this._bindings[eventName].push(callback);
      return callback;
    };

    Node.prototype.trigger = function() {
      var args, callback, eventName, _i, _len, _ref, _results;
      eventName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!this._bindings[eventName]) {
        return;
      }
      _ref = this._bindings[eventName];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        if (!callback) {
          continue;
        }
        _results.push(callback.call.apply(callback, [this].concat(__slice.call(args))));
      }
      return _results;
    };

    Node.prototype.unbind = function(eventName, callback) {
      var i, suspect, _i, _len, _ref, _results;
      if (!eventName) {
        this._bindings = {};
        return;
      }
      if (!callback) {
        this._bindings[eventName] = void 0;
        return;
      }
      if (!this._bindings[eventName]) {
        return;
      }
      _ref = this._bindings[eventName];
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        suspect = _ref[i];
        if (suspect === callback) {
          _results.push(this._bindings[eventName].splice(i, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Node.prototype.commit = function() {
      this._modified = null;
      return ContentEdit.Root.get().trigger('commit', this);
    };

    Node.prototype.taint = function() {
      var now, parent, root, _i, _len, _ref;
      now = Date.now();
      this._modified = now;
      _ref = this.parents();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        parent = _ref[_i];
        parent._modified = now;
      }
      root = ContentEdit.Root.get();
      root._modified = now;
      return root.trigger('taint', this);
    };

    Node.prototype.closest = function(testFunc) {
      var parent;
      parent = this.parent();
      while (parent && !testFunc(parent)) {
        if (parent.parent) {
          parent = parent.parent();
        } else {
          parent = null;
        }
      }
      return parent;
    };

    Node.prototype.next = function() {
      var children, index, node, _i, _len, _ref;
      if (this.children && this.children.length > 0) {
        return this.children[0];
      }
      _ref = [this].concat(this.parents());
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (!node.parent()) {
          return null;
        }
        children = node.parent().children;
        index = children.indexOf(node);
        if (index < children.length - 1) {
          return children[index + 1];
        }
      }
    };

    Node.prototype.nextContent = function() {
      return this.nextWithTest(function(node) {
        return node.content !== void 0;
      });
    };

    Node.prototype.nextSibling = function() {
      var index;
      index = this.parent().children.indexOf(this);
      if (index === this.parent().children.length - 1) {
        return null;
      }
      return this.parent().children[index + 1];
    };

    Node.prototype.nextWithTest = function(testFunc) {
      var node;
      node = this;
      while (node) {
        node = node.next();
        if (node && testFunc(node)) {
          return node;
        }
      }
    };

    Node.prototype.previous = function() {
      var children, node;
      if (!this.parent()) {
        return null;
      }
      children = this.parent().children;
      if (children[0] === this) {
        return this.parent();
      }
      node = children[children.indexOf(this) - 1];
      while (node.children && node.children.length) {
        node = node.children[node.children.length - 1];
      }
      return node;
    };

    Node.prototype.previousContent = function() {
      var node;
      return node = this.previousWithTest(function(node) {
        return node.content !== void 0;
      });
    };

    Node.prototype.previousSibling = function() {
      var index;
      index = this.parent().children.indexOf(this);
      if (index === 0) {
        return null;
      }
      return this.parent().children[index - 1];
    };

    Node.prototype.previousWithTest = function(testFunc) {
      var node;
      node = this;
      while (node) {
        node = node.previous();
        if (node && testFunc(node)) {
          return node;
        }
      }
    };

    Node.extend = function(cls) {
      var key, value, _ref;
      _ref = cls.prototype;
      for (key in _ref) {
        value = _ref[key];
        if (key === 'constructor') {
          continue;
        }
        this.prototype[key] = value;
      }
      for (key in cls) {
        value = cls[key];
        if (__indexOf.call('__super__', key) >= 0) {
          continue;
        }
        this.prototype[key] = value;
      }
      return this;
    };

    Node.fromDOMElement = function(domElement) {
      throw new Error('`fromDOMElement` not implemented');
    };

    return Node;

  })();

  ContentEdit.NodeCollection = (function(_super) {
    __extends(NodeCollection, _super);

    function NodeCollection() {
      NodeCollection.__super__.constructor.call(this);
      this.children = [];
    }

    NodeCollection.prototype.descendants = function() {
      var descendants, node, nodeStack;
      descendants = [];
      nodeStack = this.children.slice();
      while (nodeStack.length > 0) {
        node = nodeStack.shift();
        descendants.push(node);
        if (node.children && node.children.length > 0) {
          nodeStack = node.children.slice().concat(nodeStack);
        }
      }
      return descendants;
    };

    NodeCollection.prototype.isMounted = function() {
      return false;
    };

    NodeCollection.prototype.attach = function(node, index) {
      if (node.parent()) {
        node.parent().detach(node);
      }
      node._parent = this;
      if (index !== void 0) {
        this.children.splice(index, 0, node);
      } else {
        this.children.push(node);
      }
      if (node.mount && this.isMounted()) {
        node.mount();
      }
      this.taint();
      return ContentEdit.Root.get().trigger('attach', this, node);
    };

    NodeCollection.prototype.commit = function() {
      var descendant, _i, _len, _ref;
      _ref = this.descendants();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        descendant = _ref[_i];
        descendant._modified = null;
      }
      this._modified = null;
      return ContentEdit.Root.get().trigger('commit', this);
    };

    NodeCollection.prototype.detach = function(node) {
      var nodeIndex;
      nodeIndex = this.children.indexOf(node);
      if (nodeIndex === -1) {
        return;
      }
      if (node.unmount && this.isMounted() && node.isMounted()) {
        node.unmount();
      }
      this.children.splice(nodeIndex, 1);
      node._parent = null;
      this.taint();
      return ContentEdit.Root.get().trigger('detach', this, node);
    };

    return NodeCollection;

  })(ContentEdit.Node);

  ContentEdit.Element = (function(_super) {
    __extends(Element, _super);

    function Element(tagName, attributes) {
      Element.__super__.constructor.call(this);
      this._tagName = tagName.toLowerCase();
      this._attributes = attributes ? attributes : {};
      this._domElement = null;
    }

    Element.prototype.attributes = function() {
      var attributes, name, value, _ref;
      attributes = {};
      _ref = this._attributes;
      for (name in _ref) {
        value = _ref[name];
        attributes[name] = value;
      }
      return attributes;
    };

    Element.prototype.cssTypeName = function() {
      return 'element';
    };

    Element.prototype.domElement = function() {
      return this._domElement;
    };

    Element.prototype.isFocused = function() {
      return ContentEdit.Root.get().focused() === this;
    };

    Element.prototype.isMounted = function() {
      return this._domElement !== null;
    };

    Element.prototype.typeName = function() {
      return 'Element';
    };

    Element.prototype.addCSSClass = function(className) {
      var modified;
      modified = false;
      if (!this.hasCSSClass(className)) {
        modified = true;
        if (this.attr('class')) {
          this.attr('class', "" + (this.attr('class')) + " " + className);
        } else {
          this.attr('class', className);
        }
      }
      this._addCSSClass(className);
      if (modified) {
        return this.taint();
      }
    };

    Element.prototype.attr = function(name, value) {
      name = name.toLowerCase();
      if (value === void 0) {
        return this._attributes[name];
      }
      this._attributes[name] = value;
      if (this.isMounted() && name.toLowerCase() !== 'class') {
        this._domElement.setAttribute(name, value);
      }
      return this.taint();
    };

    Element.prototype.blur = function() {
      var root;
      root = ContentEdit.Root.get();
      if (this.isFocused()) {
        this._removeCSSClass('ce-element--focused');
        root._focused = null;
        return root.trigger('blur', this);
      }
    };

    Element.prototype.createDraggingDOMElement = function() {
      var helper;
      if (!this.isMounted()) {
        return;
      }
      helper = document.createElement('div');
      helper.setAttribute('class', "ce-drag-helper ce-drag-helper--type-" + (this.cssTypeName()));
      helper.setAttribute('data-ce-type', ContentEdit._(this.typeName()));
      return helper;
    };

    Element.prototype.drag = function(x, y) {
      var root;
      if (!this.isMounted()) {
        return;
      }
      root = ContentEdit.Root.get();
      root.startDragging(this, x, y);
      return root.trigger('drag', this);
    };

    Element.prototype.drop = function(element, placement) {
      var root;
      root = ContentEdit.Root.get();
      if (element) {
        element._removeCSSClass('ce-element--drop');
        element._removeCSSClass("ce-element--drop-" + placement[0]);
        element._removeCSSClass("ce-element--drop-" + placement[1]);
        if (this.constructor.droppers[element.constructor.name]) {
          this.constructor.droppers[element.constructor.name](this, element, placement);
          root.trigger('drop', this, element, placement);
          return;
        } else if (element.constructor.droppers[this.constructor.name]) {
          element.constructor.droppers[this.constructor.name](this, element, placement);
          root.trigger('drop', this, element, placement);
          return;
        }
      }
      return root.trigger('drop', this, null, null);
    };

    Element.prototype.focus = function(supressDOMFocus) {
      var root;
      root = ContentEdit.Root.get();
      if (this.isFocused()) {
        return;
      }
      if (root.focused()) {
        root.focused().blur();
      }
      this._addCSSClass('ce-element--focused');
      root._focused = this;
      if (this.isMounted() && !supressDOMFocus) {
        this.domElement().focus();
      }
      return root.trigger('focus', this);
    };

    Element.prototype.hasCSSClass = function(className) {
      var c, classNames;
      if (this.attr('class')) {
        classNames = (function() {
          var _i, _len, _ref, _results;
          _ref = this.attr('class').split(' ');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(c);
          }
          return _results;
        }).call(this);
        if (classNames.indexOf(className) > -1) {
          return true;
        }
      }
      return false;
    };

    Element.prototype.merge = function(element) {
      if (this.constructor.mergers[element.constructor.name]) {
        return this.constructor.mergers[element.constructor.name](element, this);
      } else if (element.constructor.mergers[this.constructor.name]) {
        return element.constructor.mergers[this.constructor.name](element, this);
      }
    };

    Element.prototype.mount = function() {
      var sibling;
      if (!this._domElement) {
        this._domElement = document.createElement(this.tagName());
      }
      sibling = this.nextSibling();
      if (sibling) {
        this.parent().domElement().insertBefore(this._domElement, sibling.domElement());
      } else {
        this.parent().domElement().appendChild(this._domElement);
      }
      this._addDOMEventListeners();
      this._addCSSClass('ce-element');
      this._addCSSClass("ce-element--type-" + (this.cssTypeName()));
      if (this.isFocused()) {
        this._addCSSClass('ce-element--focused');
      }
      return ContentEdit.Root.get().trigger('mount', this);
    };

    Element.prototype.removeAttr = function(name) {
      name = name.toLowerCase();
      if (!this._attributes[name]) {
        return;
      }
      delete this._attributes[name];
      if (this.isMounted() && name.toLowerCase() !== 'class') {
        this._domElement.removeAttribute(name);
      }
      return this.taint();
    };

    Element.prototype.removeCSSClass = function(className) {
      var c, classNameIndex, classNames;
      if (!this.hasCSSClass(className)) {
        return;
      }
      classNames = (function() {
        var _i, _len, _ref, _results;
        _ref = this.attr('class').split(' ');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      }).call(this);
      classNameIndex = classNames.indexOf(className);
      if (classNameIndex > -1) {
        classNames.splice(classNameIndex, 1);
      }
      if (classNames.length) {
        this.attr('class', classNames.join(' '));
      } else {
        this.removeAttr('class');
      }
      this._removeCSSClass(className);
      return this.taint();
    };

    Element.prototype.tagName = function(name) {
      if (name === void 0) {
        return this._tagName;
      }
      this._tagName = name.toLowerCase();
      if (this.isMounted()) {
        this.unmount();
        this.mount();
      }
      return this.taint();
    };

    Element.prototype.unmount = function() {
      this._removeDOMEventListeners();
      if (this._domElement.parentNode) {
        this._domElement.parentNode.removeChild(this._domElement);
      }
      this._domElement = null;
      return ContentEdit.Root.get().trigger('unmount', this);
    };

    Element.prototype._addDOMEventListeners = function() {
      this._domElement.addEventListener('focus', (function(_this) {
        return function(ev) {
          return ev.preventDefault();
        };
      })(this));
      this._domElement.addEventListener('dragstart', (function(_this) {
        return function(ev) {
          return ev.preventDefault();
        };
      })(this));
      this._domElement.addEventListener('keydown', (function(_this) {
        return function(ev) {
          return _this._onKeyDown(ev);
        };
      })(this));
      this._domElement.addEventListener('keyup', (function(_this) {
        return function(ev) {
          return _this._onKeyUp(ev);
        };
      })(this));
      this._domElement.addEventListener('mousedown', (function(_this) {
        return function(ev) {
          if (ev.button === 0) {
            return _this._onMouseDown(ev);
          }
        };
      })(this));
      this._domElement.addEventListener('mousemove', (function(_this) {
        return function(ev) {
          return _this._onMouseMove(ev);
        };
      })(this));
      this._domElement.addEventListener('mouseover', (function(_this) {
        return function(ev) {
          return _this._onMouseOver(ev);
        };
      })(this));
      this._domElement.addEventListener('mouseout', (function(_this) {
        return function(ev) {
          return _this._onMouseOut(ev);
        };
      })(this));
      this._domElement.addEventListener('mouseup', (function(_this) {
        return function(ev) {
          if (ev.button === 0) {
            return _this._onMouseUp(ev);
          }
        };
      })(this));
      return this._domElement.addEventListener('paste', (function(_this) {
        return function(ev) {
          return _this._onPaste(ev);
        };
      })(this));
    };

    Element.prototype._onKeyDown = function(ev) {};

    Element.prototype._onKeyUp = function(ev) {};

    Element.prototype._onMouseDown = function(ev) {
      if (this.focus) {
        return this.focus(true);
      }
    };

    Element.prototype._onMouseMove = function(ev) {};

    Element.prototype._onMouseOver = function(ev) {
      var dragging, root;
      this._addCSSClass('ce-element--over');
      root = ContentEdit.Root.get();
      dragging = root.dragging();
      if (!dragging) {
        return;
      }
      if (dragging === this) {
        return;
      }
      if (root._dropTarget) {
        return;
      }
      if (this.constructor.droppers[dragging.constructor.name] || dragging.constructor.droppers[this.constructor.name]) {
        this._addCSSClass('ce-element--drop');
        return root._dropTarget = this;
      }
    };

    Element.prototype._onMouseOut = function(ev) {
      var dragging, root;
      this._removeCSSClass('ce-element--over');
      root = ContentEdit.Root.get();
      dragging = root.dragging();
      if (dragging) {
        this._removeCSSClass('ce-element--drop');
        this._removeCSSClass('ce-element--drop-above');
        this._removeCSSClass('ce-element--drop-below');
        this._removeCSSClass('ce-element--drop-center');
        this._removeCSSClass('ce-element--drop-left');
        this._removeCSSClass('ce-element--drop-right');
        return root._dropTarget = null;
      }
    };

    Element.prototype._onMouseUp = function(ev) {};

    Element.prototype._onPaste = function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      return ContentEdit.Root.get().trigger('paste', this, ev);
    };

    Element.prototype._removeDOMEventListeners = function() {};

    Element.prototype._addCSSClass = function(className) {
      if (!this.isMounted()) {
        return;
      }
      return ContentEdit.addCSSClass(this._domElement, className);
    };

    Element.prototype._attributesToString = function() {
      if (!(Object.getOwnPropertyNames(this._attributes).length > 0)) {
        return '';
      }
      return ' ' + ContentEdit.attributesToString(this._attributes);
    };

    Element.prototype._removeCSSClass = function(className) {
      if (!this.isMounted()) {
        return;
      }
      return ContentEdit.removeCSSClass(this._domElement, className);
    };

    Element.droppers = {};

    Element.mergers = {};

    Element.placements = ['above', 'below'];

    Element.getDOMElementAttributes = function(domElement) {
      var attribute, attributes, _i, _len, _ref;
      if (!domElement.hasAttributes()) {
        return {};
      }
      attributes = {};
      _ref = domElement.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        attributes[attribute.name.toLowerCase()] = attribute.value;
      }
      return attributes;
    };

    Element._dropVert = function(element, target, placement) {
      var insertIndex;
      element.parent().detach(element);
      insertIndex = target.parent().children.indexOf(target);
      if (placement[0] === 'below') {
        insertIndex += 1;
      }
      return target.parent().attach(element, insertIndex);
    };

    Element._dropBoth = function(element, target, placement) {
      var aClassNames, className, insertIndex, _i, _len, _ref;
      element.parent().detach(element);
      insertIndex = target.parent().children.indexOf(target);
      if (placement[0] === 'below' && placement[1] === 'center') {
        insertIndex += 1;
      }
      if (element.a) {
        element._removeCSSClass('align-left');
        element._removeCSSClass('align-right');
        if (element.a['class']) {
          aClassNames = [];
          _ref = element.a['class'].split(' ');
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            className = _ref[_i];
            if (className === 'align-left' || className === 'align-right') {
              continue;
            }
            aClassNames.push(className);
          }
          if (aClassNames.length) {
            element.a['class'] = aClassNames.join(' ');
          } else {
            delete element.a['class'];
          }
        }
      } else {
        element.removeCSSClass('align-left');
        element.removeCSSClass('align-right');
      }
      if (placement[1] === 'left') {
        if (element.a) {
          if (element.a['class']) {
            element.a['class'] += ' align-left';
          } else {
            element.a['class'] = 'align-left';
          }
          element._addCSSClass('align-left');
        } else {
          element.addCSSClass('align-left');
        }
      }
      if (placement[1] === 'right') {
        if (element.a) {
          if (element.a['class']) {
            element.a['class'] += ' align-right';
          } else {
            element.a['class'] = 'align-right';
          }
          element._addCSSClass('align-right');
        } else {
          element.addCSSClass('align-right');
        }
      }
      return target.parent().attach(element, insertIndex);
    };

    return Element;

  })(ContentEdit.Node);

  ContentEdit.ElementCollection = (function(_super) {
    __extends(ElementCollection, _super);

    ElementCollection.extend(ContentEdit.NodeCollection);

    function ElementCollection(tagName, attributes) {
      ElementCollection.__super__.constructor.call(this, tagName, attributes);
      ContentEdit.NodeCollection.prototype.constructor.call(this);
    }

    ElementCollection.prototype.cssTypeName = function() {
      return 'element-collection';
    };

    ElementCollection.prototype.isMounted = function() {
      return this._domElement !== null;
    };

    ElementCollection.prototype.createDraggingDOMElement = function() {
      var helper, text;
      if (!this.isMounted()) {
        return;
      }
      helper = ElementCollection.__super__.createDraggingDOMElement.call(this);
      text = this._domElement.textContent;
      if (text.length > ContentEdit.HELPER_CHAR_LIMIT) {
        text = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT);
      }
      helper.innerHTML = text;
      return helper;
    };

    ElementCollection.prototype.detach = function(element) {
      ContentEdit.NodeCollection.prototype.detach.call(this, element);
      if (this.children.length === 0 && this.parent()) {
        return this.parent().detach(this);
      }
    };

    ElementCollection.prototype.html = function(indent) {
      var c, children;
      if (indent == null) {
        indent = '';
      }
      children = (function() {
        var _i, _len, _ref, _results;
        _ref = this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c.html(indent + ContentEdit.INDENT));
        }
        return _results;
      }).call(this);
      return ("" + indent + "<" + (this.tagName()) + (this._attributesToString()) + ">\n") + ("" + (children.join('\n')) + "\n") + ("" + indent + "</" + (this.tagName()) + ">");
    };

    ElementCollection.prototype.mount = function() {
      var child, name, value, _i, _len, _ref, _ref1, _results;
      this._domElement = document.createElement(this._tagName);
      _ref = this._attributes;
      for (name in _ref) {
        value = _ref[name];
        this._domElement.setAttribute(name, value);
      }
      ElementCollection.__super__.mount.call(this);
      _ref1 = this.children;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        child = _ref1[_i];
        _results.push(child.mount());
      }
      return _results;
    };

    ElementCollection.prototype.unmount = function() {
      var child, _i, _len, _ref;
      _ref = this.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        child.unmount();
      }
      return ElementCollection.__super__.unmount.call(this);
    };

    ElementCollection.prototype.blur = void 0;

    ElementCollection.prototype.focus = void 0;

    return ElementCollection;

  })(ContentEdit.Element);

  ContentEdit.ResizableElement = (function(_super) {
    __extends(ResizableElement, _super);

    function ResizableElement(tagName, attributes) {
      ResizableElement.__super__.constructor.call(this, tagName, attributes);
      this._domSizeInfoElement = null;
      this._aspectRatio = 1;
    }

    ResizableElement.prototype.aspectRatio = function() {
      return this._aspectRatio;
    };

    ResizableElement.prototype.maxSize = function() {
      var maxWidth;
      maxWidth = parseInt(this.attr('data-ce-max-width') || 0);
      if (!maxWidth) {
        maxWidth = ContentEdit.DEFAULT_MAX_ELEMENT_WIDTH;
      }
      maxWidth = Math.max(maxWidth, this.size()[0]);
      return [maxWidth, maxWidth * this.aspectRatio()];
    };

    ResizableElement.prototype.minSize = function() {
      var minWidth;
      minWidth = parseInt(this.attr('data-ce-min-width') || 0);
      if (!minWidth) {
        minWidth = ContentEdit.DEFAULT_MIN_ELEMENT_WIDTH;
      }
      minWidth = Math.min(minWidth, this.size()[0]);
      return [minWidth, minWidth * this.aspectRatio()];
    };

    ResizableElement.prototype.mount = function() {
      ResizableElement.__super__.mount.call(this);
      return this._domElement.setAttribute('data-ce-size', this._getSizeInfo());
    };

    ResizableElement.prototype.resize = function(corner, x, y) {
      if (!this.isMounted()) {
        return;
      }
      return ContentEdit.Root.get().startResizing(this, corner, x, y, true);
    };

    ResizableElement.prototype.size = function(newSize) {
      var height, maxSize, minSize, width;
      if (!newSize) {
        width = parseInt(this.attr('width') || 1);
        height = parseInt(this.attr('height') || 1);
        return [width, height];
      }
      newSize[0] = parseInt(newSize[0]);
      newSize[1] = parseInt(newSize[1]);
      minSize = this.minSize();
      newSize[0] = Math.max(newSize[0], minSize[0]);
      newSize[1] = Math.max(newSize[1], minSize[1]);
      maxSize = this.maxSize();
      newSize[0] = Math.min(newSize[0], maxSize[0]);
      newSize[1] = Math.min(newSize[1], maxSize[1]);
      this.attr('width', parseInt(newSize[0]));
      this.attr('height', parseInt(newSize[1]));
      if (this.isMounted()) {
        this._domElement.style.width = "" + newSize[0] + "px";
        this._domElement.style.height = "" + newSize[1] + "px";
        return this._domElement.setAttribute('data-ce-size', this._getSizeInfo());
      }
    };

    ResizableElement.prototype._onMouseDown = function(ev) {
      var corner;
      ResizableElement.__super__._onMouseDown.call(this);
      corner = this._getResizeCorner(ev.clientX, ev.clientY);
      if (corner) {
        return this.resize(corner, ev.clientX, ev.clientY);
      } else {
        clearTimeout(this._dragTimeout);
        return this._dragTimeout = setTimeout((function(_this) {
          return function() {
            return _this.drag(ev.pageX, ev.pageY);
          };
        })(this), 150);
      }
    };

    ResizableElement.prototype._onMouseMove = function(ev) {
      var corner;
      ResizableElement.__super__._onMouseMove.call(this);
      this._removeCSSClass('ce-element--resize-top-left');
      this._removeCSSClass('ce-element--resize-top-right');
      this._removeCSSClass('ce-element--resize-bottom-left');
      this._removeCSSClass('ce-element--resize-bottom-right');
      corner = this._getResizeCorner(ev.clientX, ev.clientY);
      if (corner) {
        return this._addCSSClass("ce-element--resize-" + corner[0] + "-" + corner[1]);
      }
    };

    ResizableElement.prototype._onMouseOut = function(ev) {
      ResizableElement.__super__._onMouseOut.call(this);
      this._removeCSSClass('ce-element--resize-top-left');
      this._removeCSSClass('ce-element--resize-top-right');
      this._removeCSSClass('ce-element--resize-bottom-left');
      return this._removeCSSClass('ce-element--resize-bottom-right');
    };

    ResizableElement.prototype._onMouseUp = function(ev) {
      ResizableElement.__super__._onMouseUp.call(this);
      if (this._dragTimeout) {
        return clearTimeout(this._dragTimeout);
      }
    };

    ResizableElement.prototype._getResizeCorner = function(x, y) {
      var corner, cornerSize, rect, size, _ref;
      rect = this._domElement.getBoundingClientRect();
      _ref = [x - rect.left, y - rect.top], x = _ref[0], y = _ref[1];
      size = this.size();
      cornerSize = ContentEdit.RESIZE_CORNER_SIZE;
      cornerSize = Math.min(cornerSize, Math.max(parseInt(size[0] / 4), 1));
      cornerSize = Math.min(cornerSize, Math.max(parseInt(size[1] / 4), 1));
      corner = null;
      if (x < cornerSize) {
        if (y < cornerSize) {
          corner = ['top', 'left'];
        } else if (y > rect.height - cornerSize) {
          corner = ['bottom', 'left'];
        }
      } else if (x > rect.width - cornerSize) {
        if (y < cornerSize) {
          corner = ['top', 'right'];
        } else if (y > rect.height - cornerSize) {
          corner = ['bottom', 'right'];
        }
      }
      return corner;
    };

    ResizableElement.prototype._getSizeInfo = function() {
      var size;
      size = this.size();
      return "w " + size[0] + " × h " + size[1];
    };

    return ResizableElement;

  })(ContentEdit.Element);

  ContentEdit.Region = (function(_super) {
    __extends(Region, _super);

    function Region(domElement) {
      var c, childNode, childNodes, cls, element, tagNames, _i, _len;
      Region.__super__.constructor.call(this);
      this._domElement = domElement;
      tagNames = ContentEdit.TagNames.get();
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = this._domElement.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      }).call(this);
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        childNode = childNodes[_i];
        if (childNode.nodeType !== 1) {
          continue;
        }
        if (childNode.getAttribute("data-ce-tag")) {
          cls = tagNames.match(childNode.getAttribute("data-ce-tag"));
        } else {
          cls = tagNames.match(childNode.tagName);
        }
        element = cls.fromDOMElement(childNode);
        this._domElement.removeChild(childNode);
        if (element) {
          this.attach(element);
        }
      }
    }

    Region.prototype.domElement = function() {
      return this._domElement;
    };

    Region.prototype.isMounted = function() {
      return true;
    };

    Region.prototype.html = function(indent) {
      var c;
      if (indent == null) {
        indent = '';
      }
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c.html(indent));
        }
        return _results;
      }).call(this)).join('\n').trim();
    };

    return Region;

  })(ContentEdit.NodeCollection);

  _Root = (function(_super) {
    __extends(_Root, _super);

    function _Root() {
      this._onStopResizing = __bind(this._onStopResizing, this);
      this._onResize = __bind(this._onResize, this);
      this._onStopDragging = __bind(this._onStopDragging, this);
      this._onDrag = __bind(this._onDrag, this);
      _Root.__super__.constructor.call(this);
      this._focused = null;
      this._dragging = null;
      this._dropTarget = null;
      this._draggingDOMElement = null;
      this._resizing = null;
      this._resizingInit = null;
    }

    _Root.prototype.dragging = function() {
      return this._dragging;
    };

    _Root.prototype.dropTarget = function() {
      return this._dropTarget;
    };

    _Root.prototype.focused = function() {
      return this._focused;
    };

    _Root.prototype.resizing = function() {
      return this._resizing;
    };

    _Root.prototype.cancelDragging = function() {
      if (!this._dragging) {
        return;
      }
      document.body.removeChild(this._draggingDOMElement);
      document.removeEventListener('mousemove', this._onDrag);
      document.removeEventListener('mouseup', this._onStopDragging);
      this._dragging._removeCSSClass('ce-element--dragging');
      this._dragging = null;
      this._dropTarget = null;
      return ContentEdit.removeCSSClass(document.body, 'ce--dragging');
    };

    _Root.prototype.startDragging = function(element, x, y) {
      if (this._dragging) {
        return;
      }
      this._dragging = element;
      this._dragging._addCSSClass('ce-element--dragging');
      this._draggingDOMElement = this._dragging.createDraggingDOMElement();
      document.body.appendChild(this._draggingDOMElement);
      this._draggingDOMElement.style.left = "" + x + "px";
      this._draggingDOMElement.style.top = "" + y + "px";
      document.addEventListener('mousemove', this._onDrag);
      document.addEventListener('mouseup', this._onStopDragging);
      return ContentEdit.addCSSClass(document.body, 'ce--dragging');
    };

    _Root.prototype._getDropPlacement = function(x, y) {
      var horz, rect, vert, _ref;
      if (!this._dropTarget) {
        return null;
      }
      rect = this._dropTarget.domElement().getBoundingClientRect();
      _ref = [x - rect.left, y - rect.top], x = _ref[0], y = _ref[1];
      horz = 'center';
      if (x < ContentEdit.DROP_EDGE_SIZE) {
        horz = 'left';
      } else if (x > rect.width - ContentEdit.DROP_EDGE_SIZE) {
        horz = 'right';
      }
      vert = 'above';
      if (y > rect.height / 2) {
        vert = 'below';
      }
      return [vert, horz];
    };

    _Root.prototype._onDrag = function(ev) {
      var placement, _ref, _ref1;
      ContentSelect.Range.unselectAll();
      this._draggingDOMElement.style.left = "" + ev.pageX + "px";
      this._draggingDOMElement.style.top = "" + ev.pageY + "px";
      if (this._dropTarget) {
        placement = this._getDropPlacement(ev.clientX, ev.clientY);
        this._dropTarget._removeCSSClass('ce-element--drop-above');
        this._dropTarget._removeCSSClass('ce-element--drop-below');
        this._dropTarget._removeCSSClass('ce-element--drop-center');
        this._dropTarget._removeCSSClass('ce-element--drop-left');
        this._dropTarget._removeCSSClass('ce-element--drop-right');
        if (_ref = placement[0], __indexOf.call(this._dragging.constructor.placements, _ref) >= 0) {
          this._dropTarget._addCSSClass("ce-element--drop-" + placement[0]);
        }
        if (_ref1 = placement[1], __indexOf.call(this._dragging.constructor.placements, _ref1) >= 0) {
          return this._dropTarget._addCSSClass("ce-element--drop-" + placement[1]);
        }
      }
    };

    _Root.prototype._onStopDragging = function(ev) {
      var placement;
      placement = this._getDropPlacement(ev.clientX, ev.clientY);
      this._dragging.drop(this._dropTarget, placement);
      return this.cancelDragging();
    };

    _Root.prototype.startResizing = function(element, corner, x, y, fixed) {
      var measureDom, parentDom;
      if (this._resizing) {
        return;
      }
      this._resizing = element;
      this._resizingInit = {
        corner: corner,
        fixed: fixed,
        origin: [x, y],
        size: element.size()
      };
      this._resizing._addCSSClass('ce-element--resizing');
      parentDom = this._resizing.parent().domElement();
      measureDom = document.createElement('div');
      measureDom.setAttribute('class', 'ce-measure');
      parentDom.appendChild(measureDom);
      this._resizingParentWidth = measureDom.getBoundingClientRect().width;
      parentDom.removeChild(measureDom);
      document.addEventListener('mousemove', this._onResize);
      document.addEventListener('mouseup', this._onStopResizing);
      return ContentEdit.addCSSClass(document.body, 'ce--resizing');
    };

    _Root.prototype._onResize = function(ev) {
      var height, width, x, y;
      ContentSelect.Range.unselectAll();
      x = this._resizingInit.origin[0] - ev.clientX;
      if (this._resizingInit.corner[1] === 'right') {
        x = -x;
      }
      width = this._resizingInit.size[0] + x;
      width = Math.min(width, this._resizingParentWidth);
      if (this._resizingInit.fixed) {
        height = width * this._resizing.aspectRatio();
      } else {
        y = this._resizingInit.origin[1] - ev.clientY;
        if (this._resizingInit.corner[0] === 'bottom') {
          y = -y;
        }
        height = this._resizingInit.size[1] + y;
      }
      return this._resizing.size([width, height]);
    };

    _Root.prototype._onStopResizing = function(ev) {
      document.removeEventListener('mousemove', this._onResize);
      document.removeEventListener('mouseup', this._onStopResizing);
      this._resizing._removeCSSClass('ce-element--resizing');
      this._resizing = null;
      this._resizingInit = null;
      this._resizingParentWidth = null;
      return ContentEdit.removeCSSClass(document.body, 'ce--resizing');
    };

    return _Root;

  })(ContentEdit.Node);

  ContentEdit.Root = (function() {
    var instance;

    function Root() {}

    instance = null;

    Root.get = function() {
      return instance != null ? instance : instance = new _Root();
    };

    return Root;

  })();

  ContentEdit.Static = (function(_super) {
    __extends(Static, _super);

    function Static(tagName, attributes, content) {
      Static.__super__.constructor.call(this, tagName, attributes);
      this._content = content;
    }

    Static.prototype.cssTypeName = function() {
      return 'static';
    };

    Static.prototype.typeName = function() {
      return 'Static';
    };

    Static.prototype.createDraggingDOMElement = function() {
      var helper, text;
      if (!this.isMounted()) {
        return;
      }
      helper = Static.__super__.createDraggingDOMElement.call(this);
      text = this._domElement.textContent;
      if (text.length > ContentEdit.HELPER_CHAR_LIMIT) {
        text = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT);
      }
      helper.innerHTML = text;
      return helper;
    };

    Static.prototype.html = function(indent) {
      if (indent == null) {
        indent = '';
      }
      return ("" + indent + "<" + this._tagName + (this._attributesToString()) + ">") + ("" + this._content) + ("" + indent + "</" + this._tagName + ">");
    };

    Static.prototype.mount = function() {
      var name, value, _ref;
      this._domElement = document.createElement(this._tagName);
      _ref = this._attributes;
      for (name in _ref) {
        value = _ref[name];
        this._domElement.setAttribute(name, value);
      }
      this._domElement.innerHTML = this._content;
      return Static.__super__.mount.call(this);
    };

    Static.prototype.blur = void 0;

    Static.prototype.focus = void 0;

    Static.prototype._onMouseDown = function(ev) {
      Static.__super__._onMouseDown.call(this);
      if (this.attr('data-ce-moveable') !== void 0) {
        clearTimeout(this._dragTimeout);
        return this._dragTimeout = setTimeout((function(_this) {
          return function() {
            return _this.drag(ev.pageX, ev.pageY);
          };
        })(this), 150);
      }
    };

    Static.prototype._onMouseOver = function(ev) {
      Static.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    Static.prototype._onMouseUp = function(ev) {
      Static.__super__._onMouseUp.call(this);
      if (this._dragTimeout) {
        return clearTimeout(this._dragTimeout);
      }
    };

    Static.droppers = {
      'Static': ContentEdit.Element._dropVert
    };

    Static.fromDOMElement = function(domElement) {
      return new this(domElement.tagName, this.getDOMElementAttributes(domElement), domElement.innerHTML);
    };

    return Static;

  })(ContentEdit.Element);

  ContentEdit.TagNames.get().register(ContentEdit.Static, 'static');

  ContentEdit.Text = (function(_super) {
    __extends(Text, _super);

    function Text(tagName, attributes, content) {
      Text.__super__.constructor.call(this, tagName, attributes);
      if (content instanceof HTMLString.String) {
        this.content = content;
      } else {
        this.content = new HTMLString.String(content).trim();
      }
    }

    Text.prototype.cssTypeName = function() {
      return 'text';
    };

    Text.prototype.typeName = function() {
      return 'Text';
    };

    Text.prototype.blur = function() {
      var error;
      if (this.content.isWhitespace()) {
        if (this.parent()) {
          this.parent().detach(this);
        }
      } else if (this.isMounted()) {
        try {
          this._domElement.blur();
        } catch (_error) {
          error = _error;
        }
        this._domElement.removeAttribute('contenteditable');
      }
      return Text.__super__.blur.call(this);
    };

    Text.prototype.createDraggingDOMElement = function() {
      var helper, text;
      if (!this.isMounted()) {
        return;
      }
      helper = Text.__super__.createDraggingDOMElement.call(this);
      text = this._domElement.textContent;
      if (text.length > ContentEdit.HELPER_CHAR_LIMIT) {
        text = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT);
      }
      helper.innerHTML = text;
      return helper;
    };

    Text.prototype.drag = function(x, y) {
      this.storeState();
      this._domElement.removeAttribute('contenteditable');
      return Text.__super__.drag.call(this, x, y);
    };

    Text.prototype.drop = function(element, placement) {
      Text.__super__.drop.call(this, element, placement);
      return this.restoreState();
    };

    Text.prototype.focus = function(supressDOMFocus) {
      if (this.isMounted()) {
        this._domElement.setAttribute('contenteditable', '');
      }
      return Text.__super__.focus.call(this, supressDOMFocus);
    };

    Text.prototype.html = function(indent) {
      var content;
      if (indent == null) {
        indent = '';
      }
      if (!this._lastCached || this._lastCached < this._modified) {
        content = this.content.copy();
        content.optimize();
        this._lastCached = Date.now();
        this._cached = content.html();
      }
      return ("" + indent + "<" + this._tagName + (this._attributesToString()) + ">\n") + ("" + indent + ContentEdit.INDENT + this._cached + "\n") + ("" + indent + "</" + this._tagName + ">");
    };

    Text.prototype.mount = function() {
      var name, value, _ref;
      this._domElement = document.createElement(this._tagName);
      _ref = this._attributes;
      for (name in _ref) {
        value = _ref[name];
        this._domElement.setAttribute(name, value);
      }
      this.updateInnerHTML();
      return Text.__super__.mount.call(this);
    };

    Text.prototype.restoreState = function() {
      if (!this._savedSelection) {
        return;
      }
      if (!(this.isMounted() && this.isFocused())) {
        this._savedSelection = void 0;
        return;
      }
      this._domElement.setAttribute('contenteditable', '');
      this._addCSSClass('ce-element--focused');
      this._savedSelection.select(this._domElement);
      return this._savedSelection = void 0;
    };

    Text.prototype.selection = function(selection) {
      if (selection === void 0) {
        if (this.isMounted()) {
          return ContentSelect.Range.query(this._domElement);
        } else {
          return new ContentSelect.Range(0, 0);
        }
      }
      return selection.select(this._domElement);
    };

    Text.prototype.storeState = function() {
      if (!(this.isMounted() && this.isFocused())) {
        return;
      }
      return this._savedSelection = ContentSelect.Range.query(this._domElement);
    };

    Text.prototype.updateInnerHTML = function() {
      this._domElement.innerHTML = this.content.html();
      ContentSelect.Range.prepareElement(this._domElement);
      return this._flagIfEmpty();
    };

    Text.prototype._onKeyDown = function(ev) {
      switch (ev.keyCode) {
        case 40:
          return this._keyDown(ev);
        case 37:
          return this._keyLeft(ev);
        case 39:
          return this._keyRight(ev);
        case 38:
          return this._keyUp(ev);
        case 9:
          return this._keyTab(ev);
        case 8:
          return this._keyBack(ev);
        case 46:
          return this._keyDelete(ev);
        case 13:
          return this._keyReturn(ev);
      }
    };

    Text.prototype._onKeyUp = function(ev) {
      var newSnaphot, snapshot;
      snapshot = this.content.html();
      this.content = new HTMLString.String(this._domElement.innerHTML, this.content.preserveWhitespace());
      newSnaphot = this.content.html();
      if (snapshot !== newSnaphot) {
        this.taint();
      }
      return this._flagIfEmpty();
    };

    Text.prototype._onMouseDown = function(ev) {
      Text.__super__._onMouseDown.call(this);
      clearTimeout(this._dragTimeout);
      return this._dragTimeout = setTimeout((function(_this) {
        return function() {
          return _this.drag(ev.pageX, ev.pageY);
        };
      })(this), ContentEdit.DRAG_HOLD_DURATION);
    };

    Text.prototype._onMouseMove = function(ev) {
      if (this._dragTimeout) {
        clearTimeout(this._dragTimeout);
      }
      return Text.__super__._onMouseMove.call(this);
    };

    Text.prototype._onMouseOut = function(ev) {
      if (this._dragTimeout) {
        clearTimeout(this._dragTimeout);
      }
      return Text.__super__._onMouseOut.call(this);
    };

    Text.prototype._onMouseUp = function(ev) {
      if (this._dragTimeout) {
        clearTimeout(this._dragTimeout);
      }
      return Text.__super__._onMouseUp.call(this);
    };

    Text.prototype._keyBack = function(ev) {
      var previous, selection;
      selection = ContentSelect.Range.query(this._domElement);
      if (!(selection.get()[0] === 0 && selection.isCollapsed())) {
        return;
      }
      ev.preventDefault();
      previous = this.previousContent();
      if (previous) {
        return previous.merge(this);
      }
    };

    Text.prototype._keyDelete = function(ev) {
      var next, selection;
      selection = ContentSelect.Range.query(this._domElement);
      if (!(this._atEnd(selection) && selection.isCollapsed())) {
        return;
      }
      ev.preventDefault();
      next = this.nextContent();
      if (next) {
        return this.merge(next);
      }
    };

    Text.prototype._keyDown = function(ev) {
      return this._keyRight(ev);
    };

    Text.prototype._keyLeft = function(ev) {
      var previous, selection;
      selection = ContentSelect.Range.query(this._domElement);
      if (!(selection.get()[0] === 0 && selection.isCollapsed())) {
        return;
      }
      ev.preventDefault();
      previous = this.previousContent();
      if (previous) {
        previous.focus();
        selection = new ContentSelect.Range(previous.content.length(), previous.content.length());
        return selection.select(previous.domElement());
      } else {
        return ContentEdit.Root.get().trigger('previous-region', this.closest(function(node) {
          return node.constructor.name === 'Region';
        }));
      }
    };

    Text.prototype._keyReturn = function(ev) {
      var element, selection, tail, tip;
      ev.preventDefault();
      if (this.content.isWhitespace()) {
        return;
      }
      ContentSelect.Range.query(this._domElement);
      selection = ContentSelect.Range.query(this._domElement);
      tip = this.content.substring(0, selection.get()[0]);
      tail = this.content.substring(selection.get()[1]);
      this.content = tip.trim();
      this.updateInnerHTML();
      element = new this.constructor('p', {}, tail.trim());
      this.parent().attach(element, this.parent().children.indexOf(this) + 1);
      if (tip.length()) {
        element.focus();
        selection = new ContentSelect.Range(0, 0);
        selection.select(element.domElement());
      } else {
        selection = new ContentSelect.Range(0, tip.length());
        selection.select(this._domElement);
      }
      return this.taint();
    };

    Text.prototype._keyRight = function(ev) {
      var next, selection;
      selection = ContentSelect.Range.query(this._domElement);
      if (!(this._atEnd(selection) && selection.isCollapsed())) {
        return;
      }
      ev.preventDefault();
      next = this.nextContent();
      if (next) {
        next.focus();
        selection = new ContentSelect.Range(0, 0);
        return selection.select(next.domElement());
      } else {
        return ContentEdit.Root.get().trigger('next-region', this.closest(function(node) {
          return node.constructor.name === 'Region';
        }));
      }
    };

    Text.prototype._keyTab = function(ev) {
      return ev.preventDefault();
    };

    Text.prototype._keyUp = function(ev) {
      return this._keyLeft(ev);
    };

    Text.prototype._atEnd = function(selection) {
      var atEnd;
      atEnd = selection.get()[0] === this.content.length();
      if (selection.get()[0] === this.content.length() - 1 && this.content.characters[this.content.characters.length - 1].isTag('br')) {
        atEnd = true;
      }
      return atEnd;
    };

    Text.prototype._flagIfEmpty = function() {
      if (this.content.length() === 0) {
        return this._addCSSClass('ce-element--empty');
      } else {
        return this._removeCSSClass('ce-element--empty');
      }
    };

    Text.droppers = {
      'Static': ContentEdit.Element._dropVert,
      'Text': ContentEdit.Element._dropVert
    };

    Text.mergers = {
      'Text': function(element, target) {
        var offset;
        offset = target.content.length();
        if (element.content.length()) {
          target.content = target.content.concat(element.content);
        }
        if (target.isMounted()) {
          target.updateInnerHTML();
        }
        target.focus();
        new ContentSelect.Range(offset, offset).select(target._domElement);
        if (element.parent()) {
          element.parent().detach(element);
        }
        return target.taint();
      }
    };

    Text.fromDOMElement = function(domElement) {
      return new this(domElement.tagName, this.getDOMElementAttributes(domElement), domElement.innerHTML.replace(/^\s+|\s+$/g, ''));
    };

    return Text;

  })(ContentEdit.Element);

  ContentEdit.TagNames.get().register(ContentEdit.Text, 'address', 'blockquote', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p');

  ContentEdit.PreText = (function(_super) {
    __extends(PreText, _super);

    function PreText(tagName, attributes, content) {
      if (content instanceof HTMLString.String) {
        this.content = content;
      } else {
        this.content = new HTMLString.String(content, true);
      }
      ContentEdit.Element.call(this, tagName, attributes);
    }

    PreText.prototype.cssTypeName = function() {
      return 'pre-text';
    };

    PreText.prototype.typeName = function() {
      return 'Preformatted';
    };

    PreText.prototype.html = function(indent) {
      var content;
      if (indent == null) {
        indent = '';
      }
      if (!this._lastCached || this._lastCached < this._modified) {
        content = this.content.copy();
        content.optimize();
        this._lastCached = Date.now();
        this._cached = content.html();
      }
      return ("" + indent + "<" + this._tagName + (this._attributesToString()) + ">") + ("" + this._cached + "</" + this._tagName + ">");
    };

    PreText.prototype.updateInnerHTML = function() {
      var html;
      html = this.content.html();
      html += '\n';
      this._domElement.innerHTML = html;
      ContentSelect.Range.prepareElement(this._domElement);
      return this._flagIfEmpty();
    };

    PreText.prototype._onKeyUp = function(ev) {
      var html, newSnaphot, snapshot;
      snapshot = this.content.html();
      html = this._domElement.innerHTML.replace(/[\n]$/, '');
      this.content = new HTMLString.String(html, this.content.preserveWhitespace());
      newSnaphot = this.content.html();
      if (snapshot !== newSnaphot) {
        this.taint();
      }
      return this._flagIfEmpty();
    };

    PreText.prototype._keyReturn = function(ev) {
      var cursor, selection, tail, tip;
      ev.preventDefault();
      selection = ContentSelect.Range.query(this._domElement);
      cursor = selection.get()[0] + 1;
      if (selection.get()[0] === 0 && selection.isCollapsed()) {
        this.content = new HTMLString.String('\n', true).concat(this.content);
      } else if (this._atEnd(selection) && selection.isCollapsed()) {
        this.content = this.content.concat(new HTMLString.String('\n', true));
      } else if (selection.get()[0] === 0 && selection.get()[1] === this.content.length()) {
        this.content = new HTMLString.String('\n', true);
        cursor = 0;
      } else {
        tip = this.content.substring(0, selection.get()[0]);
        tail = this.content.substring(selection.get()[1]);
        this.content = tip.concat(new HTMLString.String('\n', true), tail);
      }
      this.updateInnerHTML();
      selection.set(cursor, cursor);
      selection.select(this._domElement);
      return this.taint();
    };

    PreText.droppers = {
      'PreText': ContentEdit.Element._dropVert,
      'Static': ContentEdit.Element._dropVert,
      'Text': ContentEdit.Element._dropVert
    };

    PreText.mergers = {};

    PreText.fromDOMElement = function(domElement) {
      return new this(domElement.tagName, this.getDOMElementAttributes(domElement), domElement.innerHTML);
    };

    return PreText;

  })(ContentEdit.Text);

  ContentEdit.TagNames.get().register(ContentEdit.PreText, 'pre');

  ContentEdit.Image = (function(_super) {
    __extends(Image, _super);

    function Image(attributes, a) {
      var size;
      Image.__super__.constructor.call(this, 'img', attributes);
      this.a = a ? a : null;
      size = this.size();
      this._aspectRatio = size[1] / size[0];
    }

    Image.prototype.cssTypeName = function() {
      return 'image';
    };

    Image.prototype.typeName = function() {
      return 'Image';
    };

    Image.prototype.createDraggingDOMElement = function() {
      var helper;
      if (!this.isMounted()) {
        return;
      }
      helper = Image.__super__.createDraggingDOMElement.call(this);
      helper.style.backgroundImage = "url(" + this._attributes['src'] + ")";
      return helper;
    };

    Image.prototype.html = function(indent) {
      var attributes, img;
      if (indent == null) {
        indent = '';
      }
      img = "" + indent + "<img" + (this._attributesToString()) + ">";
      if (this.a) {
        attributes = ContentEdit.attributesToString(this.a);
        attributes = "" + attributes + " data-ce-tag=\"img\"";
        return ("" + indent + "<a " + attributes + ">\n") + ("" + ContentEdit.INDENT + img + "\n") + ("" + indent + "</a>");
      } else {
        return img;
      }
    };

    Image.prototype.mount = function() {
      var style;
      this._domElement = document.createElement('div');
      if (this.a && this.a['class']) {
        this._domElement.setAttribute('class', this.a['class']);
      } else if (this._attributes['class']) {
        this._domElement.setAttribute('class', this._attributes['class']);
      }
      style = this._attributes['style'] ? this._attributes['style'] : '';
      style += "background-image:url(" + this._attributes['src'] + ");";
      if (this._attributes['width']) {
        style += "width:" + this._attributes['width'] + "px;";
      }
      if (this._attributes['height']) {
        style += "height:" + this._attributes['height'] + "px;";
      }
      this._domElement.setAttribute('style', style);
      return Image.__super__.mount.call(this);
    };

    Image.droppers = {
      'Image': ContentEdit.Element._dropBoth,
      'PreText': ContentEdit.Element._dropBoth,
      'Static': ContentEdit.Element._dropBoth,
      'Text': ContentEdit.Element._dropBoth
    };

    Image.placements = ['above', 'below', 'left', 'right', 'center'];

    Image.fromDOMElement = function(domElement) {
      var a, attributes, c, childNode, childNodes, _i, _len;
      a = null;
      if (domElement.tagName.toLowerCase() === 'a') {
        a = this.getDOMElementAttributes(domElement);
        childNodes = (function() {
          var _i, _len, _ref, _results;
          _ref = domElement.childNodes;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(c);
          }
          return _results;
        })();
        for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
          childNode = childNodes[_i];
          if (childNode.nodeType === 1 && childNode.tagName.toLowerCase() === 'img') {
            domElement = childNode;
            break;
          }
        }
        if (domElement.tagName.toLowerCase() === 'a') {
          domElement = document.createElement('img');
        }
      }
      attributes = this.getDOMElementAttributes(domElement);
      if (attributes['width'] === void 0) {
        if (attributes['height'] === void 0) {
          attributes['width'] = domElement.naturalWidth;
        } else {
          attributes['width'] = domElement.clientWidth;
        }
      }
      if (attributes['height'] === void 0) {
        if (attributes['width'] === void 0) {
          attributes['height'] = domElement.naturalHeight;
        } else {
          attributes['height'] = domElement.clientHeight;
        }
      }
      return new this(attributes, a);
    };

    return Image;

  })(ContentEdit.ResizableElement);

  ContentEdit.TagNames.get().register(ContentEdit.Image, 'img');

  ContentEdit.Video = (function(_super) {
    __extends(Video, _super);

    function Video(tagName, attributes, sources) {
      var size;
      if (sources == null) {
        sources = [];
      }
      Video.__super__.constructor.call(this, tagName, attributes);
      this.sources = sources;
      size = this.size();
      this._aspectRatio = size[1] / size[0];
    }

    Video.prototype.cssTypeName = function() {
      return 'video';
    };

    Video.prototype.typeName = function() {
      return 'Video';
    };

    Video.prototype._title = function() {
      var src;
      src = '';
      if (this.attr('src')) {
        src = this.attr('src');
      } else {
        if (this.sources.length) {
          src = this.sources[0]['src'];
        }
      }
      if (!src) {
        src = 'No video source set';
      }
      if (src.length > ContentEdit.HELPER_CHAR_LIMIT) {
        src = text.substr(0, ContentEdit.HELPER_CHAR_LIMIT);
      }
      return src;
    };

    Video.prototype.createDraggingDOMElement = function() {
      var helper;
      if (!this.isMounted()) {
        return;
      }
      helper = Video.__super__.createDraggingDOMElement.call(this);
      helper.innerHTML = this._title();
      return helper;
    };

    Video.prototype.html = function(indent) {
      var attributes, source, sourceStrings, _i, _len, _ref;
      if (indent == null) {
        indent = '';
      }
      if (this.tagName() === 'video') {
        sourceStrings = [];
        _ref = this.sources;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          source = _ref[_i];
          attributes = ContentEdit.attributesToString(source);
          sourceStrings.push("" + indent + ContentEdit.INDENT + "<source " + attributes + ">");
        }
        return ("" + indent + "<video" + (this._attributesToString()) + ">\n") + sourceStrings.join('\n') + ("\n" + indent + "</video>");
      } else {
        return ("" + indent + "<" + this._tagName + (this._attributesToString()) + ">") + ("</" + this._tagName + ">");
      }
    };

    Video.prototype.mount = function() {
      var style;
      this._domElement = document.createElement('div');
      if (this.a && this.a['class']) {
        this._domElement.setAttribute('class', this.a['class']);
      } else if (this._attributes['class']) {
        this._domElement.setAttribute('class', this._attributes['class']);
      }
      style = this._attributes['style'] ? this._attributes['style'] : '';
      if (this._attributes['width']) {
        style += "width:" + this._attributes['width'] + "px;";
      }
      if (this._attributes['height']) {
        style += "height:" + this._attributes['height'] + "px;";
      }
      this._domElement.setAttribute('style', style);
      this._domElement.setAttribute('data-ce-title', this._title());
      return Video.__super__.mount.call(this);
    };

    Video.droppers = {
      'Image': ContentEdit.Element._dropBoth,
      'PreText': ContentEdit.Element._dropBoth,
      'Static': ContentEdit.Element._dropBoth,
      'Text': ContentEdit.Element._dropBoth,
      'Video': ContentEdit.Element._dropBoth
    };

    Video.placements = ['above', 'below', 'left', 'right', 'center'];

    Video.fromDOMElement = function(domElement) {
      var c, childNode, childNodes, sources, _i, _len;
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = domElement.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      })();
      sources = [];
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        childNode = childNodes[_i];
        if (childNode.nodeType === 1 && childNode.tagName.toLowerCase() === 'source') {
          sources.push(this.getDOMElementAttributes(childNode));
        }
      }
      return new this(domElement.tagName, this.getDOMElementAttributes(domElement), sources);
    };

    return Video;

  })(ContentEdit.ResizableElement);

  ContentEdit.TagNames.get().register(ContentEdit.Video, 'iframe', 'video');

  ContentEdit.List = (function(_super) {
    __extends(List, _super);

    function List(tagName, attributes) {
      List.__super__.constructor.call(this, tagName, attributes);
    }

    List.prototype.cssTypeName = function() {
      return 'list';
    };

    List.prototype.typeName = function() {
      return 'List';
    };

    List.prototype._onMouseOver = function(ev) {
      if (this.parent().constructor.name === 'ListItem') {
        return;
      }
      List.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    List.droppers = {
      'Image': ContentEdit.Element._dropBoth,
      'List': ContentEdit.Element._dropVert,
      'PreText': ContentEdit.Element._dropVert,
      'Static': ContentEdit.Element._dropVert,
      'Text': ContentEdit.Element._dropVert,
      'Video': ContentEdit.Element._dropBoth
    };

    List.fromDOMElement = function(domElement) {
      var c, childNode, childNodes, list, _i, _len;
      list = new this(domElement.tagName, this.getDOMElementAttributes(domElement));
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = domElement.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      })();
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        childNode = childNodes[_i];
        if (childNode.nodeType !== 1) {
          continue;
        }
        if (childNode.tagName.toLowerCase() !== 'li') {
          continue;
        }
        list.attach(ContentEdit.ListItem.fromDOMElement(childNode));
      }
      if (list.children.length === 0) {
        return null;
      }
      return list;
    };

    return List;

  })(ContentEdit.ElementCollection);

  ContentEdit.TagNames.get().register(ContentEdit.List, 'ol', 'ul');

  ContentEdit.ListItem = (function(_super) {
    __extends(ListItem, _super);

    function ListItem(attributes) {
      ListItem.__super__.constructor.call(this, 'li', attributes);
    }

    ListItem.prototype.cssTypeName = function() {
      return 'list-item';
    };

    ListItem.prototype.list = function() {
      if (this.children.length === 2) {
        return this.children[1];
      }
      return null;
    };

    ListItem.prototype.listItemText = function() {
      if (this.children.length > 0) {
        return this.children[0];
      }
      return null;
    };

    ListItem.prototype.html = function(indent) {
      var lines;
      if (indent == null) {
        indent = '';
      }
      lines = ["" + indent + "<li" + (this._attributesToString()) + ">"];
      if (this.listItemText()) {
        lines.push(this.listItemText().html(indent + ContentEdit.INDENT));
      }
      if (this.list()) {
        lines.push(this.list().html(indent + ContentEdit.INDENT));
      }
      lines.push("" + indent + "</li>");
      return lines.join('\n');
    };

    ListItem.prototype.indent = function() {
      var sibling;
      if (this.parent().children.indexOf(this) === 0) {
        return;
      }
      sibling = this.previousSibling();
      if (!sibling.list()) {
        sibling.attach(new ContentEdit.List(sibling.parent().tagName()));
      }
      this.listItemText().storeState();
      this.parent().detach(this);
      sibling.list().attach(this);
      return this.listItemText().restoreState();
    };

    ListItem.prototype.remove = function() {
      var child, i, index, _i, _len, _ref;
      if (!this.parent()) {
        return;
      }
      index = this.parent().children.indexOf(this);
      if (this.list()) {
        _ref = this.list().children.slice();
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          child = _ref[i];
          child.parent().detach(child);
          this.parent().attach(child, i + index);
        }
      }
      return this.parent().detach(this);
    };

    ListItem.prototype.unindent = function() {
      var child, grandParent, i, itemIndex, list, parent, parentIndex, selection, sibling, siblings, text, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1;
      parent = this.parent();
      grandParent = parent.parent();
      siblings = parent.children.slice(parent.children.indexOf(this) + 1, parent.children.length);
      if (grandParent.constructor.name === 'ListItem') {
        this.listItemText().storeState();
        parent.detach(this);
        grandParent.parent().attach(this, grandParent.parent().children.indexOf(grandParent) + 1);
        if (siblings.length && !this.list()) {
          this.attach(new ContentEdit.List(parent.tagName()));
        }
        for (_i = 0, _len = siblings.length; _i < _len; _i++) {
          sibling = siblings[_i];
          sibling.parent().detach(sibling);
          this.list().attach(sibling);
        }
        return this.listItemText().restoreState();
      } else {
        text = new ContentEdit.Text('p', this.attr('class') ? {
          'class': this.attr('class')
        } : {}, this.listItemText().content);
        selection = null;
        if (this.listItemText().isFocused()) {
          selection = ContentSelect.Range.query(this.listItemText().domElement());
        }
        parentIndex = grandParent.children.indexOf(parent);
        itemIndex = parent.children.indexOf(this);
        if (itemIndex === 0) {
          list = null;
          if (parent.children.length === 1) {
            if (this.list()) {
              list = new ContentEdit.List(parent.tagName());
            }
            grandParent.detach(parent);
          } else {
            parent.detach(this);
          }
          grandParent.attach(text, parentIndex);
          if (list) {
            grandParent.attach(list, parentIndex + 1);
          }
          if (this.list()) {
            _ref = this.list().children.slice();
            for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
              child = _ref[i];
              child.parent().detach(child);
              if (list) {
                list.attach(child);
              } else {
                parent.attach(child, i);
              }
            }
          }
        } else if (itemIndex === parent.children.length - 1) {
          parent.detach(this);
          grandParent.attach(text, parentIndex + 1);
          if (this.list()) {
            grandParent.attach(this.list(), parentIndex + 2);
          }
        } else {
          parent.detach(this);
          grandParent.attach(text, parentIndex + 1);
          list = new ContentEdit.List(parent.tagName());
          grandParent.attach(list, parentIndex + 2);
          if (this.list()) {
            _ref1 = this.list().children.slice();
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              child = _ref1[_k];
              child.parent().detach(child);
              list.attach(child);
            }
          }
          for (_l = 0, _len3 = siblings.length; _l < _len3; _l++) {
            sibling = siblings[_l];
            sibling.parent().detach(sibling);
            list.attach(sibling);
          }
        }
        if (selection) {
          text.focus();
          return selection.select(text.domElement());
        }
      }
    };

    ListItem.prototype._onMouseOver = function(ev) {
      ListItem.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    ListItem.prototype._addDOMEventListeners = function() {};

    ListItem.prototype._removeDOMEventListners = function() {};

    ListItem.fromDOMElement = function(domElement) {
      var childNode, content, listDOMElement, listElement, listItem, listItemText, _i, _len, _ref, _ref1;
      listItem = new this(this.getDOMElementAttributes(domElement));
      content = '';
      listDOMElement = null;
      _ref = domElement.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        childNode = _ref[_i];
        if (childNode.nodeType === 1) {
          if ((_ref1 = childNode.tagName.toLowerCase()) === 'ul' || _ref1 === 'li') {
            if (!listDOMElement) {
              listDOMElement = childNode;
            }
          } else {
            content += childNode.outerHTML;
          }
        } else {
          content += HTMLString.String.encode(childNode.textContent);
        }
      }
      content = content.replace(/^\s+|\s+$/g, '');
      listItemText = new ContentEdit.ListItemText(content);
      listItem.attach(listItemText);
      if (listDOMElement) {
        listElement = ContentEdit.List.fromDOMElement(listDOMElement);
        listItem.attach(listElement);
      }
      return listItem;
    };

    return ListItem;

  })(ContentEdit.ElementCollection);

  ContentEdit.ListItemText = (function(_super) {
    __extends(ListItemText, _super);

    function ListItemText(content) {
      ListItemText.__super__.constructor.call(this, 'div', {}, content);
    }

    ListItemText.prototype.cssTypeName = function() {
      return 'list-item-text';
    };

    ListItemText.prototype.typeName = function() {
      return 'List item';
    };

    ListItemText.prototype.blur = function() {
      if (this.content.isWhitespace()) {
        this.parent().remove();
      } else if (this.isMounted()) {
        this._domElement.blur();
        this._domElement.removeAttribute('contenteditable');
      }
      return ContentEdit.Element.prototype.blur.call(this);
    };

    ListItemText.prototype.html = function(indent) {
      var content;
      if (indent == null) {
        indent = '';
      }
      if (!this._lastCached || this._lastCached < this._modified) {
        content = this.content.copy();
        content.optimize();
        this._lastCached = Date.now();
        this._cached = content.html();
      }
      return "" + indent + this._cached;
    };

    ListItemText.prototype._onMouseDown = function(ev) {
      var initDrag;
      ContentEdit.Element.prototype._onMouseDown.call(this, ev);
      initDrag = (function(_this) {
        return function() {
          var listRoot;
          if (ContentEdit.Root.get().dragging() === _this) {
            ContentEdit.Root.get().cancelDragging();
            listRoot = _this.closest(function(node) {
              return node.parent().constructor.name === 'Region';
            });
            return listRoot.drag(ev.pageX, ev.pageY);
          } else {
            _this.drag(ev.pageX, ev.pageY);
            return _this._dragTimeout = setTimeout(initDrag, ContentEdit.DRAG_HOLD_DURATION * 2);
          }
        };
      })(this);
      clearTimeout(this._dragTimeout);
      return this._dragTimeout = setTimeout(initDrag, ContentEdit.DRAG_HOLD_DURATION);
    };

    ListItemText.prototype._onMouseMove = function(ev) {
      if (this._dragTimeout) {
        clearTimeout(this._dragTimeout);
      }
      return ContentEdit.Element.prototype._onMouseMove.call(this, ev);
    };

    ListItemText.prototype._onMouseUp = function(ev) {
      if (this._dragTimeout) {
        clearTimeout(this._dragTimeout);
      }
      return ContentEdit.Element.prototype._onMouseUp.call(this, ev);
    };

    ListItemText.prototype._keyTab = function(ev) {
      ev.preventDefault();
      if (ev.shiftKey) {
        return this.parent().unindent();
      } else {
        return this.parent().indent();
      }
    };

    ListItemText.prototype._keyReturn = function(ev) {
      var grandParent, list, listItem, selection, tail, tip;
      ev.preventDefault();
      if (this.content.isWhitespace()) {
        this.parent().unindent();
        return;
      }
      ContentSelect.Range.query(this._domElement);
      selection = ContentSelect.Range.query(this._domElement);
      tip = this.content.substring(0, selection.get()[0]);
      tail = this.content.substring(selection.get()[1]);
      if (tip.length() + tail.length() === 0) {
        this.parent().unindent();
        return;
      }
      this.content = tip.trim();
      this.updateInnerHTML();
      grandParent = this.parent().parent();
      listItem = new ContentEdit.ListItem(this.attr('class') ? {
        'class': this.attr('class')
      } : {});
      grandParent.attach(listItem, grandParent.children.indexOf(this.parent()) + 1);
      listItem.attach(new ContentEdit.ListItemText(tail.trim()));
      list = this.parent().list();
      if (list) {
        this.parent().detach(list);
        listItem.attach(list);
      }
      if (tip.length()) {
        listItem.listItemText().focus();
        selection = new ContentSelect.Range(0, 0);
        return selection.select(listItem.listItemText().domElement());
      } else {
        selection = new ContentSelect.Range(0, tip.length());
        return selection.select(this._domElement);
      }
    };

    ListItemText.droppers = {
      'ListItemText': function(element, target, placement) {
        var elementParent, insertIndex, listItem, targetParent;
        elementParent = element.parent();
        targetParent = target.parent();
        elementParent.remove();
        elementParent.detach(element);
        listItem = new ContentEdit.ListItem(elementParent._attributes);
        listItem.attach(element);
        if (targetParent.list() && placement[0] === 'below') {
          targetParent.list().attach(listItem, 0);
          return;
        }
        insertIndex = targetParent.parent().children.indexOf(targetParent);
        if (placement[0] === 'below') {
          insertIndex += 1;
        }
        return targetParent.parent().attach(listItem, insertIndex);
      },
      'Text': function(element, target, placement) {
        var cssClass, insertIndex, listItem, targetParent, text;
        if (element.constructor.name === 'Text') {
          targetParent = target.parent();
          element.parent().detach(element);
          cssClass = element.attr('class');
          listItem = new ContentEdit.ListItem(cssClass ? {
            'class': cssClass
          } : {});
          listItem.attach(new ContentEdit.ListItemText(element.content));
          if (targetParent.list() && placement[0] === 'below') {
            targetParent.list().attach(listItem, 0);
            return;
          }
          insertIndex = targetParent.parent().children.indexOf(targetParent);
          if (placement[0] === 'below') {
            insertIndex += 1;
          }
          targetParent.parent().attach(listItem, insertIndex);
          listItem.listItemText().focus();
          if (element._savedSelection) {
            return element._savedSelection.select(listItem.listItemText().domElement());
          }
        } else {
          cssClass = element.attr('class');
          text = new ContentEdit.Text('p', cssClass ? {
            'class': cssClass
          } : {}, element.content);
          element.parent().remove();
          insertIndex = target.parent().children.indexOf(target);
          if (placement[0] === 'below') {
            insertIndex += 1;
          }
          target.parent().attach(text, insertIndex);
          text.focus();
          if (element._savedSelection) {
            return element._savedSelection.select(text.domElement());
          }
        }
      }
    };

    ListItemText.mergers = {
      'ListItemText': function(element, target) {
        var offset;
        offset = target.content.length();
        if (element.content.length()) {
          target.content = target.content.concat(element.content);
        }
        if (target.isMounted()) {
          target._domElement.innerHTML = target.content.html();
        }
        target.focus();
        new ContentSelect.Range(offset, offset).select(target._domElement);
        if (element.constructor.name === 'Text') {
          if (element.parent()) {
            element.parent().detach(element);
          }
        } else {
          element.parent().remove();
        }
        return target.taint();
      }
    };

    return ListItemText;

  })(ContentEdit.Text);

  _mergers = ContentEdit.ListItemText.mergers;

  _mergers['Text'] = _mergers['ListItemText'];

  ContentEdit.Table = (function(_super) {
    __extends(Table, _super);

    function Table(attributes) {
      Table.__super__.constructor.call(this, 'table', attributes);
    }

    Table.prototype.cssTypeName = function() {
      return 'table';
    };

    Table.prototype.typeName = function() {
      return 'Table';
    };

    Table.prototype.firstSection = function() {
      var section;
      if (section = this.thead()) {
        return section;
      } else if (section = this.tbody()) {
        return section;
      } else if (section = this.tfoot()) {
        return section;
      }
      return null;
    };

    Table.prototype.lastSection = function() {
      var section;
      if (section = this.tfoot()) {
        return section;
      } else if (section = this.tbody()) {
        return section;
      } else if (section = this.thead()) {
        return section;
      }
      return null;
    };

    Table.prototype.tbody = function() {
      return this._getChild('tbody');
    };

    Table.prototype.tfoot = function() {
      return this._getChild('tfoot');
    };

    Table.prototype.thead = function() {
      return this._getChild('thead');
    };

    Table.prototype._onMouseOver = function(ev) {
      Table.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    Table.prototype._getChild = function(tagName) {
      var child, _i, _len, _ref;
      _ref = this.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (child.tagName() === tagName) {
          return child;
        }
      }
      return null;
    };

    Table.droppers = {
      'Image': ContentEdit.Element._dropBoth,
      'List': ContentEdit.Element._dropVert,
      'PreText': ContentEdit.Element._dropVert,
      'Static': ContentEdit.Element._dropVert,
      'Table': ContentEdit.Element._dropVert,
      'Text': ContentEdit.Element._dropVert,
      'Video': ContentEdit.Element._dropBoth
    };

    Table.fromDOMElement = function(domElement) {
      var c, childNode, childNodes, orphanRows, row, section, table, tagName, _i, _j, _len, _len1;
      table = new this(this.getDOMElementAttributes(domElement));
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = domElement.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      })();
      orphanRows = [];
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        childNode = childNodes[_i];
        if (childNode.nodeType !== 1) {
          continue;
        }
        tagName = childNode.tagName.toLowerCase();
        if (table._getChild(tagName)) {
          continue;
        }
        switch (tagName) {
          case 'tbody':
          case 'tfoot':
          case 'thead':
            section = ContentEdit.TableSection.fromDOMElement(childNode);
            table.attach(section);
            break;
          case 'tr':
            orphanRows.push(ContentEdit.TableRow.fromDOMElement(childNode));
        }
      }
      if (orphanRows.length > 0) {
        if (!table._getChild('tbody')) {
          table.attach(new ContentEdit.TableSection('tbody'));
        }
        for (_j = 0, _len1 = orphanRows.length; _j < _len1; _j++) {
          row = orphanRows[_j];
          table.tbody().attach(row);
        }
      }
      if (table.children.length === 0) {
        return null;
      }
      return table;
    };

    return Table;

  })(ContentEdit.ElementCollection);

  ContentEdit.TagNames.get().register(ContentEdit.Table, 'table');

  ContentEdit.TableSection = (function(_super) {
    __extends(TableSection, _super);

    function TableSection(tagName, attributes) {
      TableSection.__super__.constructor.call(this, tagName, attributes);
    }

    TableSection.prototype.cssTypeName = function() {
      return 'table-section';
    };

    TableSection.prototype._onMouseOver = function(ev) {
      TableSection.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    TableSection.fromDOMElement = function(domElement) {
      var c, childNode, childNodes, section, _i, _len;
      section = new this(domElement.tagName, this.getDOMElementAttributes(domElement));
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = domElement.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      })();
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        childNode = childNodes[_i];
        if (childNode.nodeType !== 1) {
          continue;
        }
        if (childNode.tagName.toLowerCase() !== 'tr') {
          continue;
        }
        section.attach(ContentEdit.TableRow.fromDOMElement(childNode));
      }
      return section;
    };

    return TableSection;

  })(ContentEdit.ElementCollection);

  ContentEdit.TableRow = (function(_super) {
    __extends(TableRow, _super);

    function TableRow(attributes) {
      TableRow.__super__.constructor.call(this, 'tr', attributes);
    }

    TableRow.prototype.cssTypeName = function() {
      return 'table-row';
    };

    TableRow.prototype.typeName = function() {
      return 'Table row';
    };

    TableRow.prototype._onMouseOver = function(ev) {
      TableRow.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    TableRow.droppers = {
      'TableRow': ContentEdit.Element._dropVert
    };

    TableRow.fromDOMElement = function(domElement) {
      var c, childNode, childNodes, row, tagName, _i, _len;
      row = new this(this.getDOMElementAttributes(domElement));
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = domElement.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c);
        }
        return _results;
      })();
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        childNode = childNodes[_i];
        if (childNode.nodeType !== 1) {
          continue;
        }
        tagName = childNode.tagName.toLowerCase();
        if (!(tagName === 'td' || tagName === 'th')) {
          continue;
        }
        row.attach(ContentEdit.TableCell.fromDOMElement(childNode));
      }
      return row;
    };

    return TableRow;

  })(ContentEdit.ElementCollection);

  ContentEdit.TableCell = (function(_super) {
    __extends(TableCell, _super);

    function TableCell(tagName, attributes) {
      TableCell.__super__.constructor.call(this, tagName, attributes);
    }

    TableCell.prototype.cssTypeName = function() {
      return 'table-cell';
    };

    TableCell.prototype.tableCellText = function() {
      if (this.children.length > 0) {
        return this.children[0];
      }
      return null;
    };

    TableCell.prototype.html = function(indent) {
      var lines;
      if (indent == null) {
        indent = '';
      }
      lines = ["" + indent + "<" + (this.tagName()) + (this._attributesToString()) + ">"];
      if (this.tableCellText()) {
        lines.push(this.tableCellText().html(indent + ContentEdit.INDENT));
      }
      lines.push("" + indent + "</" + (this.tagName()) + ">");
      return lines.join('\n');
    };

    TableCell.prototype._onMouseOver = function(ev) {
      TableCell.__super__._onMouseOver.call(this, ev);
      return this._removeCSSClass('ce-element--over');
    };

    TableCell.prototype._addDOMEventListeners = function() {};

    TableCell.prototype._removeDOMEventListners = function() {};

    TableCell.fromDOMElement = function(domElement) {
      var tableCell, tableCellText;
      tableCell = new this(domElement.tagName, this.getDOMElementAttributes(domElement));
      tableCellText = new ContentEdit.TableCellText(domElement.innerHTML.replace(/^\s+|\s+$/g, ''));
      tableCell.attach(tableCellText);
      return tableCell;
    };

    return TableCell;

  })(ContentEdit.ElementCollection);

  ContentEdit.TableCellText = (function(_super) {
    __extends(TableCellText, _super);

    function TableCellText(content) {
      TableCellText.__super__.constructor.call(this, 'div', {}, content);
    }

    TableCellText.prototype.cssTypeName = function() {
      return 'table-cell-text';
    };

    TableCellText.prototype._isInFirstRow = function() {
      var cell, row, section, table;
      cell = this.parent();
      row = cell.parent();
      section = row.parent();
      table = section.parent();
      if (section !== table.firstSection()) {
        return false;
      }
      return row === section.children[0];
    };

    TableCellText.prototype._isInLastRow = function() {
      var cell, row, section, table;
      cell = this.parent();
      row = cell.parent();
      section = row.parent();
      table = section.parent();
      if (section !== table.lastSection()) {
        return false;
      }
      return row === section.children[section.children.length - 1];
    };

    TableCellText.prototype._isLastInSection = function() {
      var cell, row, section;
      cell = this.parent();
      row = cell.parent();
      section = row.parent();
      if (row !== section.children[section.children.length - 1]) {
        return false;
      }
      return cell === row.children[row.children.length - 1];
    };

    TableCellText.prototype.blur = function() {
      if (this.isMounted()) {
        this._domElement.blur();
        this._domElement.removeAttribute('contenteditable');
      }
      return ContentEdit.Element.prototype.blur.call(this);
    };

    TableCellText.prototype.html = function(indent) {
      var content;
      if (indent == null) {
        indent = '';
      }
      if (!this._lastCached || this._lastCached < this._modified) {
        content = this.content.copy();
        content.optimize();
        this._lastCached = Date.now();
        this._cached = content.html();
      }
      return "" + indent + this._cached;
    };

    TableCellText.prototype._onMouseDown = function(ev) {
      var initDrag;
      ContentEdit.Element.prototype._onMouseDown.call(this, ev);
      initDrag = (function(_this) {
        return function() {
          var cell, table;
          cell = _this.parent();
          if (ContentEdit.Root.get().dragging() === cell.parent()) {
            ContentEdit.Root.get().cancelDragging();
            table = cell.parent().parent().parent();
            return table.drag(ev.pageX, ev.pageY);
          } else {
            cell.parent().drag(ev.pageX, ev.pageY);
            return _this._dragTimeout = setTimeout(initDrag, ContentEdit.DRAG_HOLD_DURATION * 2);
          }
        };
      })(this);
      clearTimeout(this._dragTimeout);
      return this._dragTimeout = setTimeout(initDrag, ContentEdit.DRAG_HOLD_DURATION);
    };

    TableCellText.prototype._keyReturn = function(ev) {
      ev.preventDefault();
      return this._keyTab({
        'shiftKey': false,
        'preventDefault': function() {}
      });
    };

    TableCellText.prototype._keyDown = function(ev) {
      var cell, cellIndex, lastCell, nextRow, row;
      ev.preventDefault();
      cell = this.parent();
      if (this._isInLastRow()) {
        row = cell.parent();
        lastCell = row.children[row.children.length - 1].tableCellText();
        return lastCell.nextContent().focus();
      } else {
        nextRow = cell.parent().nextWithTest(function(node) {
          return node.constructor.name === 'TableRow';
        });
        cellIndex = cell.parent().children.indexOf(cell);
        cellIndex = Math.min(cellIndex, nextRow.children.length);
        return nextRow.children[cellIndex].tableCellText().focus();
      }
    };

    TableCellText.prototype._keyTab = function(ev) {
      var cell, child, grandParent, newCell, newCellText, row, section, _i, _len, _ref;
      ev.preventDefault();
      cell = this.parent();
      if (ev.shiftKey) {
        if (this._isInFirstRow() && cell.parent().children[0] === cell) {
          return;
        }
        return this.previousContent().focus();
      } else {
        grandParent = cell.parent().parent();
        if (grandParent.tagName() === 'tbody' && this._isLastInSection()) {
          row = new ContentEdit.TableRow();
          _ref = cell.parent().children;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            child = _ref[_i];
            newCell = new ContentEdit.TableCell(child.tagName(), child._attributes);
            newCellText = new ContentEdit.TableCellText('');
            newCell.attach(newCellText);
            row.attach(newCell);
          }
          section = this.closest(function(node) {
            return node.constructor.name === 'TableSection';
          });
          section.attach(row);
          return row.children[0].tableCellText().focus();
        } else {
          return this.nextContent().focus();
        }
      }
    };

    TableCellText.prototype._keyUp = function(ev) {
      var cell, cellIndex, previousRow, row;
      ev.preventDefault();
      cell = this.parent();
      if (this._isInFirstRow()) {
        row = cell.parent();
        return row.children[0].previousContent().focus();
      } else {
        previousRow = cell.parent().previousWithTest(function(node) {
          return node.constructor.name === 'TableRow';
        });
        cellIndex = cell.parent().children.indexOf(cell);
        cellIndex = Math.min(cellIndex, previousRow.children.length);
        return previousRow.children[cellIndex].tableCellText().focus();
      }
    };

    TableCellText.droppers = {};

    TableCellText.mergers = {};

    return TableCellText;

  })(ContentEdit.Text);

}).call(this);
