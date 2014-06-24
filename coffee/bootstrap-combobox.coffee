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

class Combobox
  constructor: (element, options) ->
    @options = $.extend({}, $.fn.combobox.defaults, options)
    @$source = $(element)
    @$container = @setup()
    @$element = @$container.find('input[type=text]')
    @$target = @$container.find('input[type=hidden]')
    @$button = @$container.find('.dropdown-toggle')
    @$menu = $(@options.menu).appendTo('body')
    @template = @options.template || @template
    @matcher = @options.matcher || @matcher
    @sorter = @options.sorter || @sorter
    @highlighter = @options.highlighter || @highlighter
    @shown = false
    @selected = false
    @refresh()
    @transferAttributes()
    @listen()

  setup: () ->
    combobox = $(@template())
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

  parse: () ->
    that = this
    map = {}
    source = []
    selected = false
    selectedValue = ''
    @$source.find('option').each () ->
      option = $(this)
      if option.val() is ''
        that.options.placeholder = option.text()
        return
      map[option.text()] = option.val()
      source.push(option.text())
      if option.prop('selected')
        selected = option.text()
        selectedValue = option.val()
    @map = map
    if selected
      @$element.val(selected)
      @$target.val(selectedValue)
      @$container.addClass('combobox-selected')
      @selected = true
    source

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
    if (@$source.attr('disabled') isnt undefined)
      @disable()

  select: () ->
    val = @$menu.find('.active').attr('data-value')
    @$element.val(@updater(val)).trigger('change')
    @$target.val(@map[val]).trigger('change')
    @$source.val(@map[val]).trigger('change')
    @$container.addClass('combobox-selected')
    @selected = true
    return @hide()

  updater: (item) ->
    return item

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
    return this

  lookup: (event) ->
    @query = @$element.val()
    return @process(@source)

  process: (items) ->
    that = this

    items = $.grep items, (item) ->
      that.matcher(item)

    items = @sorter(items)

    if !items.length
      return (if @shown then @hide() else this)

    return @render(items.slice(0, @options.items)).show()

  template: () ->
    if @options.bsVersion == '2'
      return '<div class="combobox-container"><input type="hidden" /> <div class="input-append"> <input type="text" autocomplete="off" /> <span class="add-on dropdown-toggle" data-dropdown="dropdown"> <span class="caret"/> <i class="icon-remove"/> </span> </div> </div>'
    else
      return '<div class="combobox-container"> <input type="hidden" /> <div class="input-group"> <input type="text" autocomplete="off" /> <span class="input-group-addon dropdown-toggle" data-dropdown="dropdown"> <span class="caret" /> <span class="glyphicon glyphicon-remove" /> </span> </div> </div>'

  matcher: (item) ->
    return ~item.toLowerCase().indexOf(@query.toLowerCase())

  sorter: (items) ->
    beginswith = []
    caseSensitive = []
    caseInsensitive = []
    item

    while (item = items.shift())
      if !item.toLowerCase().indexOf(@query.toLowerCase())
        beginswith.push(item)
      else if ~item.indexOf(@query)
        caseSensitive.push(item)
      else
        caseInsensitive.push(item)

    return beginswith.concat(caseSensitive, caseInsensitive)

  highlighter: (item) ->
    query = @query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
    item.replace new RegExp('(' + query + ')', 'ig'), ($1, match) ->
      '<strong>' + match + '</strong>'

  render: (items) ->
    that = this

    items = $(items).map (i, item) ->
      i = $(that.options.item).attr('data-value', item)
      i.find('a').html(that.highlighter(item))
      i[0]

    items.first().addClass('active')
    @$menu.html(items)
    return this

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
    if !@disabled
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
    @source = @parse()
    @options.items = @source.length

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
    that = this
    @focused = false
    val = @$element.val()
    if not @selected and val isnt ''
      @$element.val('')
      @$source.val('').trigger('change')
      @$target.val('').trigger('change')
    if not @mousedover and @shown
      setTimeout (() -> that.hide()), 200

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
  bsVersion: '3'
  menu: '<ul class="typeahead typeahead-long dropdown-menu"></ul>'
  item: '<li><a href="#"></a></li>'
}

$.fn.combobox.Constructor = Combobox
