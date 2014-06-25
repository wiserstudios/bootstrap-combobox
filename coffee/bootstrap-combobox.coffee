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

class Option
  constructor: (@value, @text, @selected) ->

class OptionGroup
  constructor: (@label, @options) ->

class Combobox
  constructor: (element, options) ->
    @options = $.extend({}, $.fn.combobox.defaults, options)
    @$source = $(element)
    @$container = @setup()
    @$element = @$container.find('input[type=text]')
    @$target = @$container.find('input[type=hidden]')
    @$button = @$container.find('.dropdown-toggle')
    @$menu = $(@options.menu).appendTo('body')
    @matcher = @options.matcher || @matcher
    @sorter = @options.sorter || @sorter
    @highlighter = @options.highlighter || @highlighter
    @shown = false
    @selected = false
    @refresh()
    @transferAttributes()
    @listen()

  setup: () ->
    combobox = $(@options.template)
    @$source.before(combobox)
    @$source.hide()
    combobox

  disable: () ->
    @$element.prop('disabled', true)
    @$button.attr('disabled', true)
    @disabled = true
    @$container.addClass('combobox-disabled')

  enable: () ->
    @$element.prop('disabled', false)
    @$button.attr('disabled', false)
    @disabled = false
    @$container.removeClass('combobox-disabled')

  parseOption: (opt) ->
    new Option opt.val(), opt.text(), opt.prop('selected') and opt.val() isnt ''

  parseOptionGroup: (group) ->
    options = (@parseOption $(child) for child in group.children('option'))
    new OptionGroup group.attr('label'), options

  parse: (element) ->
    (if $(child).is 'option' then @parseOption $(child) else @parseOptionGroup $(child)) for child in element.children('option,optgroup')

  transferAttributes: () ->
    @options.placeholder = @$source.attr('data-placeholder') || @options.placeholder
    @$element.attr('placeholder', @options.placeholder)
    @$target.prop('name', @$source.prop('name'))
    @$target.val(@$source.val())
    @$source.removeAttr('name')  # Remove from source otherwise form will pass parameter twice.
    @$element.attr('required', @$source.attr('required'))
    @$element.attr('rel', @$source.attr('rel'))
    @$element.attr('title', @$source.attr('title'))
    @$element.attr('class', @$source.attr('class'))
    @$element.attr('tabindex', @$source.attr('tabindex'))
    @$source.removeAttr('tabindex')
    if @$source.attr('disabled')?
      @disable()

  traverseOptions: (items, callback) ->
    for item in items
      if item instanceof Option
        callback item
      else if item instanceof OptionGroup
        callback option for option in item.options

  setPlaceholder: (items) ->
    @traverseOptions items, (option) =>
      @options.placeholder = option.text if option.value is ''

  select: (arg) ->
    switch
      when arg instanceof Option
        @$element.val(@updater(arg.text)).trigger('change')
        @$target.val(arg.value).trigger('change')
        @$source.val(arg.value).trigger('change')
        @$container.addClass('combobox-selected')
        @selected = true
      when arg instanceof Array
        @traverseOptions arg, (option) =>
          @select option if option.selected
      when not arg?
        @select(@$menu.find('.active').data('option'))

    @hide()

  updater: (item) ->
    item

  show: () ->
    pos = $.extend({}, @$element.position(), {
      height: @$element[0].offsetHeight
    })

    @$menu
      .insertAfter(@$element)
      .css({
        top: pos.top + pos.height
      , left: pos.left
      })
      .show()

    @shown = true
    return this

  hide: () ->
    @$menu.hide()
    @shown = false
    this

  lookup: (event) ->
    @query = @$element.val()
    @process(@items)

  process: (items) ->
    ungrouped = @sorter (option for option in items when option instanceof Option and @matcher option)
    groups = (new OptionGroup group.label, group.options for group in items when group instanceof OptionGroup)
    for group in groups
      group.options = @sorter (option for option in group.options when @matcher option)
    groups = (group for group in groups when group.options.length > 0)

    items = ungrouped.concat groups

    if items.length is 0
      @hide if @shown
    else
      @render items
      @show()

  matcher: (option) ->
    ~option.text.toLowerCase().indexOf(@query.toLowerCase())

  sorter: (options) ->
    beginswith = []
    caseSensitive = []
    caseInsensitive = []

    for option in options
      if not option.text.toLowerCase().indexOf(@query.toLowerCase())
        beginswith.push(option)
      else if ~option.text.indexOf(@query)
        caseSensitive.push(option)
      else
        caseInsensitive.push(option)

    beginswith.concat(caseSensitive, caseInsensitive)

  highlighter: (option) ->
    query = @query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
    option.text.replace new RegExp('(' + query + ')', 'ig'), ($1, match) ->
      '<strong>' + match + '</strong>'

  renderOption: (option) ->
    item = $(@options.item)
    item.data('option', option)
    item.find('a').html(@highlighter option)
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

  toggle: () ->
    if not @disabled
      if @$container.hasClass('combobox-selected')
        @clearTarget()
        @triggerChange()
        @clearElement()
      else
        if @shown
          @hide()
        else
          @clearElement()
          @lookup()

  clearElement: () ->
    @$element.val('').focus()

  clearTarget: () ->
    @$source.val('')
    @$target.val('')
    @$container.removeClass('combobox-selected')
    @selected = false

  triggerChange: () ->
    @$source.trigger('change')

  refresh: () ->
    @items = @parse(@$source)
    @setPlaceholder(@items)
    @select(@items)

  listen: () ->
    @$element
      .on('focus',    $.proxy(@focus, this))
      .on('blur',     $.proxy(@blur, this))
      .on('keypress', $.proxy(@keypress, this))
      .on('keyup',    $.proxy(@keyup, this))

    if @eventSupported('keydown')
      @$element.on('keydown', $.proxy(@keydown, this))

    @$menu
      .on('click', $.proxy(@click, this))
      .on('mouseenter', 'li', $.proxy(@mouseenter, this))
      .on('mouseleave', 'li', $.proxy(@mouseleave, this))

    @$button
      .on('click', $.proxy(@toggle, this))

  eventSupported: (eventName) ->
    isSupported = eventName in @$element
    if !isSupported
      @$element.attr(eventName, 'return;')
      isSupported = typeof @$element[eventName] is 'function'
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
        @clearTarget()
        @lookup()

    e.stopPropagation()
    e.preventDefault()

  focus: (e) ->
    @focused = true

  blur: (e) ->
    @focused = false
    val = @$element.val()
    if not @selected and val isnt ''
      @$element.val('')
      @$source.val('').trigger('change')
      @$target.val('').trigger('change')
    if not @mousedover and @shown
      setTimeout (() => @hide()), 200

  click: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @select()
    @$element.focus()

  mouseenter: (e) ->
    @mousedover = true
    @$menu.find('.active').removeClass('active')
    $(e.currentTarget).addClass('active')

  mouseleave: (e) ->
    @mousedover = false


$.fn.combobox = (option) ->
  this.each () ->
    $this = $(this)
    data = $this.data('combobox')
    options = typeof option is 'object' and option
    $this.data('combobox', (data = new Combobox(this, options))) if not data
    data[option]() if typeof option == 'string'

$.fn.combobox.defaults = {
  template: '<div class="combobox-container"> <input type="hidden" /> <div class="input-group"> <input type="text" autocomplete="off" /> <span class="input-group-addon dropdown-toggle" data-dropdown="dropdown"> <span class="caret" /> <span class="glyphicon glyphicon-remove" /> </span> </div> </div>'
  menu: '<ul class="typeahead typeahead-long dropdown-menu"></ul>'
  item: '<li><a href="#"></a></li>'
}

$.fn.combobox.Constructor = Combobox
