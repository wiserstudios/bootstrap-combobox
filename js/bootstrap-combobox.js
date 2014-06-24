// Generated by CoffeeScript 1.7.1

/*
=============================================================
bootstrap-combobox.js v1.1.6
=============================================================
Copyright 2012 Daniel Farrell
Copyright 2014 Wiserstudios, LLC

Licensed under the Apache License, Version 2.0 (the "License")
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=============================================================
 */

(function() {
  "use strict";
  var Combobox,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Combobox = (function() {
    function Combobox(element, options) {
      this.options = $.extend({}, $.fn.combobox.defaults, options);
      this.$source = $(element);
      this.$container = this.setup();
      this.$element = this.$container.find('input[type=text]');
      this.$target = this.$container.find('input[type=hidden]');
      this.$button = this.$container.find('.dropdown-toggle');
      this.$menu = $(this.options.menu).appendTo('body');
      this.matcher = this.options.matcher || this.matcher;
      this.sorter = this.options.sorter || this.sorter;
      this.highlighter = this.options.highlighter || this.highlighter;
      this.shown = false;
      this.selected = false;
      this.refresh();
      this.transferAttributes();
      this.listen();
    }

    Combobox.prototype.setup = function() {
      var combobox;
      combobox = $(this.options.template);
      this.$source.before(combobox);
      this.$source.hide();
      return combobox;
    };

    Combobox.prototype.disable = function() {
      this.$element.prop('disabled', true);
      this.$button.attr('disabled', true);
      this.disabled = true;
      return this.$container.addClass('combobox-disabled');
    };

    Combobox.prototype.enable = function() {
      this.$element.prop('disabled', false);
      this.$button.attr('disabled', false);
      this.disabled = false;
      return this.$container.removeClass('combobox-disabled');
    };

    Combobox.prototype.parse = function() {
      var map, selected, selectedValue, source, that;
      that = this;
      map = {};
      source = [];
      selected = false;
      selectedValue = '';
      this.$source.find('option').each(function() {
        var option;
        option = $(this);
        if (option.val() === '') {
          that.options.placeholder = option.text();
          return;
        }
        map[option.text()] = option.val();
        source.push(option.text());
        if (option.prop('selected')) {
          selected = option.text();
          return selectedValue = option.val();
        }
      });
      this.map = map;
      if (selected) {
        this.$element.val(selected);
        this.$target.val(selectedValue);
        this.$container.addClass('combobox-selected');
        this.selected = true;
      }
      return source;
    };

    Combobox.prototype.transferAttributes = function() {
      this.options.placeholder = this.$source.attr('data-placeholder') || this.options.placeholder;
      this.$element.attr('placeholder', this.options.placeholder);
      this.$target.prop('name', this.$source.prop('name'));
      this.$target.val(this.$source.val());
      this.$source.removeAttr('name');
      this.$element.attr('required', this.$source.attr('required'));
      this.$element.attr('rel', this.$source.attr('rel'));
      this.$element.attr('title', this.$source.attr('title'));
      this.$element.attr('class', this.$source.attr('class'));
      this.$element.attr('tabindex', this.$source.attr('tabindex'));
      this.$source.removeAttr('tabindex');
      if (this.$source.attr('disabled') !== void 0) {
        return this.disable();
      }
    };

    Combobox.prototype.select = function() {
      var val;
      val = this.$menu.find('.active').attr('data-value');
      this.$element.val(this.updater(val)).trigger('change');
      this.$target.val(this.map[val]).trigger('change');
      this.$source.val(this.map[val]).trigger('change');
      this.$container.addClass('combobox-selected');
      this.selected = true;
      return this.hide();
    };

    Combobox.prototype.updater = function(item) {
      return item;
    };

    Combobox.prototype.show = function() {
      var pos;
      pos = $.extend({}, this.$element.position(), {
        height: this.$element[0].offsetHeight
      });
      this.$menu.insertAfter(this.$element).css({
        top: pos.top + pos.height,
        left: pos.left
      }).show();
      this.shown = true;
      return this;
    };

    Combobox.prototype.hide = function() {
      this.$menu.hide();
      this.shown = false;
      return this;
    };

    Combobox.prototype.lookup = function(event) {
      this.query = this.$element.val();
      return this.process(this.source);
    };

    Combobox.prototype.process = function(items) {
      var that;
      that = this;
      items = $.grep(items, function(item) {
        return that.matcher(item);
      });
      items = this.sorter(items);
      if (!items.length) {
        return (this.shown ? this.hide() : this);
      }
      return this.render(items.slice(0, this.options.items)).show();
    };

    Combobox.prototype.template = function() {
      if (this.options.bsVersion === '2') {
        return '<div class="combobox-container"><input type="hidden" /> <div class="input-append"> <input type="text" autocomplete="off" /> <span class="add-on dropdown-toggle" data-dropdown="dropdown"> <span class="caret"/> <i class="icon-remove"/> </span> </div> </div>';
      } else {

      }
    };

    Combobox.prototype.matcher = function(item) {
      return ~item.toLowerCase().indexOf(this.query.toLowerCase());
    };

    Combobox.prototype.sorter = function(items) {
      var beginswith, caseInsensitive, caseSensitive, item;
      beginswith = [];
      caseSensitive = [];
      caseInsensitive = [];
      item;
      while ((item = items.shift())) {
        if (!item.toLowerCase().indexOf(this.query.toLowerCase())) {
          beginswith.push(item);
        } else if (~item.indexOf(this.query)) {
          caseSensitive.push(item);
        } else {
          caseInsensitive.push(item);
        }
      }
      return beginswith.concat(caseSensitive, caseInsensitive);
    };

    Combobox.prototype.highlighter = function(item) {
      var query;
      query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
      return item.replace(new RegExp('(' + query + ')', 'ig'), function($1, match) {
        return '<strong>' + match + '</strong>';
      });
    };

    Combobox.prototype.render = function(items) {
      var that;
      that = this;
      items = $(items).map(function(i, item) {
        i = $(that.options.item).attr('data-value', item);
        i.find('a').html(that.highlighter(item));
        return i[0];
      });
      items.first().addClass('active');
      this.$menu.html(items);
      return this;
    };

    Combobox.prototype.next = function(event) {
      var active, next;
      active = this.$menu.find('.active').removeClass('active');
      next = active.next();
      if (!next.length) {
        next = $(this.$menu.find('li')[0]);
      }
      return next.addClass('active');
    };

    Combobox.prototype.prev = function(event) {
      var active, prev;
      active = this.$menu.find('.active').removeClass('active');
      prev = active.prev();
      if (!prev.length) {
        prev = this.$menu.find('li').last();
      }
      return prev.addClass('active');
    };

    Combobox.prototype.toggle = function() {
      if (!this.disabled) {
        if (this.$container.hasClass('combobox-selected')) {
          this.clearTarget();
          this.triggerChange();
          return this.clearElement();
        } else {
          if (this.shown) {
            return this.hide();
          } else {
            this.clearElement();
            return this.lookup();
          }
        }
      }
    };

    Combobox.prototype.clearElement = function() {
      return this.$element.val('').focus();
    };

    Combobox.prototype.clearTarget = function() {
      this.$source.val('');
      this.$target.val('');
      this.$container.removeClass('combobox-selected');
      return this.selected = false;
    };

    Combobox.prototype.triggerChange = function() {
      return this.$source.trigger('change');
    };

    Combobox.prototype.refresh = function() {
      this.source = this.parse();
      return this.options.items = this.source.length;
    };

    Combobox.prototype.listen = function() {
      this.$element.on('focus', $.proxy(this.focus, this)).on('blur', $.proxy(this.blur, this)).on('keypress', $.proxy(this.keypress, this)).on('keyup', $.proxy(this.keyup, this));
      if (this.eventSupported('keydown')) {
        this.$element.on('keydown', $.proxy(this.keydown, this));
      }
      this.$menu.on('click', $.proxy(this.click, this)).on('mouseenter', 'li', $.proxy(this.mouseenter, this)).on('mouseleave', 'li', $.proxy(this.mouseleave, this));
      return this.$button.on('click', $.proxy(this.toggle, this));
    };

    Combobox.prototype.eventSupported = function(eventName) {
      var isSupported;
      isSupported = __indexOf.call(this.$element, eventName) >= 0;
      if (!isSupported) {
        this.$element.attr(eventName, 'return;');
        isSupported = typeof this.$element[eventName] === 'function';
      }
      return isSupported;
    };

    Combobox.prototype.move = function(e) {
      if (!this.shown) {
        return;
      }
      switch (e.keyCode) {
        case 27:
          e.preventDefault();
          break;
        case 38:
          e.preventDefault();
          this.prev();
          break;
        case 40:
          e.preventDefault();
          this.next();
      }
      return e.stopPropagation();
    };

    Combobox.prototype.keydown = function(e) {
      this.suppressKeyPressRepeat = ~$.inArray(e.keyCode, [40, 38, 9, 13, 27]);
      return this.move(e);
    };

    Combobox.prototype.keypress = function(e) {
      if (this.suppressKeyPressRepeat) {
        return;
      }
      return this.move(e);
    };

    Combobox.prototype.keyup = function(e) {
      switch (e.keyCode) {
        case 13:
          if (!this.shown) {
            return;
          }
          this.select();
          break;
        case 27:
          if (!this.shown) {
            return;
          }
          this.hide();
          break;
        default:
          this.clearTarget();
          this.lookup();
      }
      e.stopPropagation();
      return e.preventDefault();
    };

    Combobox.prototype.focus = function(e) {
      return this.focused = true;
    };

    Combobox.prototype.blur = function(e) {
      var that, val;
      that = this;
      this.focused = false;
      val = this.$element.val();
      if (!this.selected && val !== '') {
        this.$element.val('');
        this.$source.val('').trigger('change');
        this.$target.val('').trigger('change');
      }
      if (!this.mousedover && this.shown) {
        return setTimeout((function() {
          return that.hide();
        }), 200);
      }
    };

    Combobox.prototype.click = function(e) {
      e.stopPropagation();
      e.preventDefault();
      this.select();
      return this.$element.focus();
    };

    Combobox.prototype.mouseenter = function(e) {
      this.mousedover = true;
      this.$menu.find('.active').removeClass('active');
      return $(e.currentTarget).addClass('active');
    };

    Combobox.prototype.mouseleave = function(e) {
      return this.mousedover = false;
    };

    return Combobox;

  })();

  $.fn.combobox = function(option) {
    return this.each(function() {
      var $this, data, options;
      $this = $(this);
      data = $this.data('combobox');
      options = typeof option === 'object' && option;
      if (!data) {
        $this.data('combobox', (data = new Combobox(this, options)));
      }
      if (typeof option === 'string') {
        return data[option]();
      }
    });
  };

  $.fn.combobox.defaults = {
    template: '<div class="combobox-container"> <input type="hidden" /> <div class="input-group"> <input type="text" autocomplete="off" /> <span class="input-group-addon dropdown-toggle" data-dropdown="dropdown"> <span class="caret" /> <span class="glyphicon glyphicon-remove" /> </span> </div> </div>',
    menu: '<ul class="typeahead typeahead-long dropdown-menu"></ul>',
    item: '<li><a href="#"></a></li>'
  };

  $.fn.combobox.Constructor = Combobox;

}).call(this);
