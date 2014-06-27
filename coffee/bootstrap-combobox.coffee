###
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
###

"use strict"

# OPTION CLASS DEFINITION
# =======================

class Option
  constructor: (@value, @text, @selected) ->

# OPTION GROUP CLASS DEFINITION
# =============================

class OptionGroup
  constructor: (@label, @options) ->

# COMBOBOX CLASS DEFINITION
# =========================

class Combobox
  @VERSION: 2.0
  @DEFAULTS: {
    template: '<div class="combobox-container"> <input type="hidden" /> <div class="input-group"> <input type="text" autocomplete="off" /> <span class="input-group-addon dropdown-toggle" data-dropdown="dropdown"> <span class="caret" /> <span class="glyphicon glyphicon-remove" /> </span> </div> </div>'
    menu: '<ul class="typeahead typeahead-long dropdown-menu"></ul>'
    item: '<li><a href="#"></a></li>'
  }

  constructor: (element, options) ->
    @options = $.extend({}, Combobox.DEFAULTS, options)
    @$body = $(document.body)
    @$element = $(element)
    @$container = @createContainer(@$element)
    @$input = @$container.find('input[type=text]')
    @$hidden = @$container.find('input[type=hidden]')
    @$button = @$container.find('.dropdown-toggle')
    @$menu = $(@options.menu).appendTo(@$body)
    @matcher = @options.matcher || @matcher
    @sorter = @options.sorter || @sorter
    @highlighter = @options.highlighter || @highlighter
    @shown = false
    @selected = false
    @refresh()
    @transferAttributes()
    @listen()

  # PUBLIC API METHODS
  # ==================
  disable: () ->
    @$input.prop('disabled', true)
    @$button.attr('disabled', true)
    @disabled = true
    @$container.addClass('combobox-disabled')

  enable: () ->
    @$input.prop('disabled', false)
    @$button.attr('disabled', false)
    @disabled = false
    @$container.removeClass('combobox-disabled')

  show: () ->
    @$container.trigger(e = $.Event 'show.bs.combobox')
    return if e.isDefaultPrevented()
    pos = $.extend({}, @$input.position(), {
      height: @$input[0].offsetHeight
    })

    @$menu
      .insertAfter(@$input)
      .css({
        top: pos.top + pos.height
      , left: pos.left
      })
      .show()

    @shown = true
    @$container.trigger(e = $.Event 'shown.bs.combobox')


  hide: () ->
    @$container.trigger(e = $.Event 'hide.bs.combobox')
    return if e.isDefaultPrevented()
    @$menu.hide()
    @shown = false
    @$container.trigger(e = $.Event 'hidden.bs.combobox')


  toggle: () ->
    if not @disabled
      @hide() if @shown
      @lookup() if not @shown and not @selected
      @clear() if @selected

  refresh: () ->
    @$container.trigger(e = $.Event 'refresh.bs.combobox')
    return if e.isDefaultPrevented()
    @items = @parse(@$element)
    @setPlaceholder(@items)
    @select(@items)
    @$container.trigger(e = $.Event 'refreshed.bs.combobox')


  select: (arg) ->
    @$container.trigger(e = $.Event 'select.bs.combobox')
    return if e.isDefaultPrevented()
    switch
      when arg instanceof Option
        @$container.addClass('combobox-selected')
        @$input.val(arg.text).trigger('change')
        @$hidden.val(arg.value).trigger('change')
        @$element.val(arg.value).trigger('change')
        @selected = true
        @$container.trigger(e = $.Event 'selected.bs.combobox')
      when arg instanceof Array
        @traverseOptions arg, (option) =>
          @select option if option.selected
      when not arg?
        @select(@$menu.find('.active').data('option'))

    @hide()

  clear: () ->
    @$container.trigger(e = $.Event 'clear.bs.combobox')
    return if e.isDefaultPrevented()
    @$container.removeClass('combobox-selected')
    @$input.val('').trigger('change').focus()
    @$hidden.val('').trigger('change')
    @$element.val('').trigger('change')
    @selected = false
    @$container.trigger(e = $.Event 'cleared.bs.combobox')


  # PRIVATE METHODS
  # ===============

  createContainer: (element) ->
    combobox = $(@options.template)
    element.before(combobox)
    element.hide()
    combobox

  transferAttributes: () ->
    @options.placeholder = @$element.attr('data-placeholder') || @options.placeholder
    @$input.attr('placeholder', @options.placeholder)
    @$hidden.prop('name', @$element.prop('name'))
    @$hidden.val(@$element.val())
    @$element.removeAttr('name')  # Remove from source otherwise form will pass parameter twice.
    @$input.attr('required', @$element.attr('required'))
    @$input.attr('rel', @$element.attr('rel'))
    @$input.attr('title', @$element.attr('title'))
    @$input.attr('class', @$element.attr('class'))
    @$input.attr('tabindex', @$element.attr('tabindex'))
    @$element.removeAttr('tabindex')
    if @$element.attr('disabled')?
      @disable()

  parseOption: (opt) ->
    new Option opt.val(), opt.text(), opt.prop('selected') and opt.val() isnt ''

  parseOptionGroup: (group) ->
    options = (@parseOption $(child) for child in group.children('option'))
    new OptionGroup group.attr('label'), options

  parse: (element) ->
    (if $(child).is 'option' then @parseOption $(child) else @parseOptionGroup $(child)) for child in element.children('option,optgroup')

  traverseOptions: (items, callback) ->
    for item in items
      if item instanceof Option
        callback item
      else if item instanceof OptionGroup
        callback option for option in item.options

  setPlaceholder: (items) ->
    @traverseOptions items, (option) =>
      @options.placeholder = option.text if option.value is ''

  lookup: (event) ->
    @query = @$input.val()
    @process(@items)

  process: (items) ->
    ungrouped = @sorter (option for option in items when option instanceof Option and @matcher option.text)
    groups = (new OptionGroup group.label, group.options for group in items when group instanceof OptionGroup)
    for group in groups
      group.options = @sorter (option for option in group.options when @matcher option.text)
    groups = (group for group in groups when group.options.length > 0)

    items = ungrouped.concat groups

    if items.length is 0
      @hide if @shown
    else
      @render items
      @show()

  matcher: (item) ->
    ~item.toLowerCase().indexOf(@query.toLowerCase())

  sorter: (items) ->
    beginswith = []
    caseSensitive = []
    caseInsensitive = []

    for item in items
      if not item.text.toLowerCase().indexOf(@query.toLowerCase())
        beginswith.push(item)
      else if ~item.text.indexOf(@query)
        caseSensitive.push(item)
      else
        caseInsensitive.push(item)

    beginswith.concat(caseSensitive, caseInsensitive)

  highlighter: (item) ->
    cursive_reg = /[\u0600-\u06FF]/
    if cursive_reg.test item
      return item
    query = @query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
    item.replace new RegExp('(' + query + ')', 'ig'), ($1, match) ->
      '<strong>' + match + '</strong>'

  renderOption: (option) ->
    item = $(@options.item)
    item.data('option', option)
    item.find('a').html(@highlighter option.text)
    item

  renderOptionGroup: (group) ->
    header = $(@options.item)
    header.addClass('dropdown-header')
    header.html(group.label)

    options = (@renderOption option for option in group.options when option.value isnt '')
    [header].concat(options)

  render: (items) ->
    ungrouped = (@renderOption option for option in items when option instanceof Option and option.value isnt '')
    groups = (@renderOptionGroup group for group in items when group instanceof OptionGroup)

    if ungrouped.length > 0 then ungrouped[0].addClass('active') else groups[0][1].addClass('active')

    divider = $(@options.item)
    divider.addClass('divider')
    divider.html('')

    @$menu.html('')
    @$menu.append(ungrouped)
    for group in groups
      @$menu.append(divider) if @$menu.children().length > 0
      @$menu.append(element) for element in group

  next: (event) ->
    active = @$menu.find('.active').removeClass('active')
    next = active.next()

    if !next.length
      next = $(@$menu.find('li')[0])

    next.addClass('active')

  prev: (event) ->
    active = @$menu.find('.active').removeClass('active')
    prev = active.prev()

    if !prev.length
      prev = @$menu.find('li').last()

    prev.addClass('active')

  listen: () ->
    @$input
      .on('focus',    $.proxy(@focus, this))
      .on('blur',     $.proxy(@blur, this))
      .on('keypress', $.proxy(@keypress, this))
      .on('keyup',    $.proxy(@keyup, this))

    if @eventSupported('keydown')
      @$input.on('keydown', $.proxy(@keydown, this))

    @$menu
      .on('click', $.proxy(@click, this))
      .on('mouseenter', 'li', $.proxy(@mouseenter, this))
      .on('mouseleave', 'li', $.proxy(@mouseleave, this))

    @$button
      .on('click', $.proxy(@toggle, this))

  eventSupported: (eventName) ->
    isSupported = eventName in @$input
    if !isSupported
      @$input.attr(eventName, 'return;')
      isSupported = typeof @$input[eventName] is 'function'
    isSupported

  move: (e) ->
    return if not @shown

    switch e.keyCode
      #when 9 # tab
      #when 13 # enter
      when 27 # escape
        e.preventDefault()
      when 38 # up arrow
        e.preventDefault()
        @prev()
      when 40 # down arrow
        e.preventDefault()
        @next()
    e.stopPropagation()

  keydown: (e) ->
    @suppressKeyPressRepeat = ~$.inArray(e.keyCode, [40,38,9,13,27])
    @move(e)

  keypress: (e) ->
    return if @suppressKeyPressRepeat
    @move(e)

  keyup: (e) ->
    switch e.keyCode
      #when 40 # down arrow
      #when 39 # right arrow
      #when 38 # up arrow
      #when 37 # left arrow
      #when 36 # home
      #when 35 # end
      #when 16 # shift
      #when 17 # ctrl
      #when 18 # alt
      #when 9 # tab
      when 13 # enter
        return if not @shown
        @select()
      when 27 # escape
        return if not @shown
        @hide()
      else
        @clear()
        @lookup()

    e.stopPropagation()
    e.preventDefault()

  focus: (e) ->
    @focused = true

  blur: (e) ->
    @focused = false
    val = @$input.val()
    if not @selected and val isnt ''
      @$input.val('')
      @$element.val('').trigger('change')
      @$hidden.val('').trigger('change')
    if not @mousedover and @shown
      setTimeout (() => @hide()), 200

  click: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @select()
    @$input.focus()

  mouseenter: (e) ->
    @mousedover = true
    @$menu.find('.active').removeClass('active')
    $(e.currentTarget).addClass('active')

  mouseleave: (e) ->
    @mousedover = false

# COMBOBOX PLUGIN DEFINITION
# ==========================

Plugin = (option) ->
  this.each () ->
    $this = $(this)
    data = $this.data('bs.combobox')
    options = typeof option is 'object' and option

    $this.data('bs.combobox', (data = new Combobox(this, options))) if not data
    data[option]() if typeof option == 'string'

old = $.fn.combobox

$.fn.combobox = Plugin
$.fn.combobox.Constructor = Combobox

# COMBOBOX NO CONFLICT
# ====================

$.fn.combobox.noConflict = () ->
  $.fn.combobox = old
  this
