module "bootstrap-combobox"

test "should be defined on jquery object", () ->
  ok($(document.body).combobox, 'combobox method is defined')

test "should return element", () ->
  $select = $('<select />')
  ok($($select).combobox()[0] == $select[0], 'select returned')

test "should build combobox from a select", () ->
  $select = $('<select />')
  $select.combobox()
  ok($select.data('bs.combobox').$element, 'has a source select')
  ok($select.data('bs.combobox').$container, 'has a container')
  ok($select.data('bs.combobox').$input, 'has a input element')
  ok($select.data('bs.combobox').$button, 'has a button')
  ok($select.data('bs.combobox').$hidden, 'has a target')

test "should listen to an input", () ->
  $select = $('<select />')
  combobox = $select.combobox().data('bs.combobox')
  $input = combobox.$input
  ok($._data($input[0], 'events').blur, 'has a blur event')
  ok($._data($input[0], 'events').keypress, 'has a keypress event')
  ok($._data($input[0], 'events').keyup, 'has a keyup event')
  if combobox.eventSupported('keydown')
    ok($._data($input[0], 'events').keydown, 'has a keydown event')
  else
    ok($._data($input[0], 'events').keydown, 'does not have a keydown event')

  combobox.$menu.remove()

test "should listen to an button", () ->
  $select = $('<select />')
  $button = $select.combobox().data('bs.combobox').$button
  ok($._data($button[0], 'events').click, 'has a click event')

test "should create a menu", () ->
  $select = $('<select />')
  ok($select.combobox().data('bs.combobox').$menu, 'has a menu')

test "should listen to the menu", () ->
  $select = $('<select />')
  $menu = $select.combobox().data('bs.combobox').$menu

  ok($._data($menu[0], 'events').mouseover, 'has a mouseover(pseudo: mouseenter)')
  ok($._data($menu[0], 'events').click, 'has a click')

test "should show menu when query entered", () ->
  $select = $('<select><option></option><option value="aa">aa</option><option value="ab">ab</option><option value="ac">ac</option></select>').appendTo('body')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  $input.val('a')
  combobox.lookup()

  ok(combobox.$menu.is(":visible"), 'menu is visible')
  equal(combobox.$menu.find('li').length, 3, 'has 3 items in menu')
  equal(combobox.$menu.find('.active').length, 1, 'one item is active')

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()

test "should hide menu when query entered", () ->
  stop()
  $select = $('<select><option></option><option value="aa">aa</option><option value="ab">ab</option><option value="ac">ac</option></select>').appendTo('body')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  $input.val('a')
  combobox.lookup()

  ok(combobox.$menu.is(":visible"), 'menu is visible')
  equal(combobox.$menu.find('li').length, 3, 'has 3 items in menu')
  equal(combobox.$menu.find('.active').length, 1, 'one item is active')

  $input.blur()

  setTimeout () ->
    ok(!combobox.$menu.is(":visible"), "menu is no longer visible")
    start()
  , 200

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()

test "should set next item when down arrow is pressed", () ->
  $select = $('<select><option></option><option>aa</option><option>ab</option><option>ac</option></select>').appendTo('body')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  $input.val('a')
  combobox.lookup()

  ok(combobox.$menu.is(":visible"), 'menu is visible')
  equal(combobox.$menu.find('li').length, 3, 'has 3 items in menu')
  equal(combobox.$menu.find('.active').length, 1, 'one item is active')
  ok(combobox.$menu.find('li').first().hasClass('active'), "first item is active")

  $input.trigger {
    type: 'keypress'
    keyCode: 40
  }

  ok(combobox.$menu.find('li').first().next().hasClass('active'), "second item is active")


  $input.trigger {
    type: 'keypress'
    keyCode: 38
  }

  ok(combobox.$menu.find('li').first().hasClass('active'), "first item is active")

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()


test "should set input and select value to selected item", () ->
  $select = $('<select><option></option><option>aa</option><option>ab</option><option>ac</option></select>').appendTo('body')
  combobox = $select.combobox().data('bs.combobox')
  $input = combobox.$input
  $element = combobox.$element
  $hidden = combobox.$hidden


  $input.val('a')
  combobox.lookup()

  $(combobox.$menu.find('li')[2]).mouseover().click()

  equal($input.val(), 'ac', 'input value was correctly set')
  equal($element.val(), 'ac', 'select value was correctly set')
  equal($hidden.val(), 'ac', 'hidden field value was correctly set')
  ok(!combobox.$menu.is(':visible'), 'the menu was hidden')

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()

test "should show menu when no item is selected and button is clicked", () ->
  $select = $('<select><option></option><option>aa</option><option>ab</option><option>ac</option></select>').appendTo('body')
  $button = $select.combobox().data('bs.combobox').$button
  combobox = $select.data('bs.combobox')

  $button.click()

  ok(combobox.$menu.is(":visible"), 'menu is visible')
  equal(combobox.$menu.find('li').length, 3, 'has 3 items in menu')
  equal(combobox.$menu.find('.active').length, 1, 'one item is active')

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()

test "should add class to container when an item is selected", () ->
  $select = $('<select><option></option><option>aa</option><option>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  $input.val('a')
  combobox.lookup()

  $(combobox.$menu.find('li')[2]).mouseover().click()

  ok(combobox.$container.hasClass('combobox-selected'), 'container has selected class')

  combobox.$menu.remove()

test "should clear and focus input and select and remove class from container when button is clicked when item is selected", () ->
  $select = $('<select><option></option><option>aa</option><option>ab</option><option>ac</option></select>')
  combobox = $select.combobox().data('bs.combobox')
  $input = combobox.$input
  $element = combobox.$element
  $hidden = combobox.$hidden

  $input.val('a')
  combobox.lookup()

  $(combobox.$menu.find('li')[2]).mouseover().click()

  equal($input.val(), 'ac', 'input value was correctly set')
  equal($element.val(), 'ac', 'select value was correctly set')
  equal($hidden.val(), 'ac', 'hidden field value was correctly set')

  combobox.$button.mouseover().click()

  equal($input.val(), '', 'input value was cleared correctly')
  equal($select.val(), '', 'select value was cleared correctly')
  # ok($input.is(":focus"), 'input has focus')

  combobox.$menu.remove()

test "should set as selected if select was selected before load", () ->
  $select = $('<select><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  $hidden = $select.combobox().data('bs.combobox').$hidden
  combobox = $select.data('bs.combobox')

  equal($input.val(), 'ab', 'input value was correctly set')
  equal($hidden.val(), 'ab', 'hidden input value was correctly set')
  equal($select.val(), 'ab', 'select value was correctly set')

test "should clear input on blur when value does not exist", () ->
  $select = $('<select><option>aa</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  $input.val('DOES NOT EXIST')
  $input.trigger('keyup')
  $input.trigger('blur')

  equal($input.val(), '', 'input value was correctly set')
  equal($select.val(), 'aa', 'select value was correctly set')

  combobox.$menu.remove()

test "should set placeholder text on the input if specified text of no value option", () ->
  $select = $('<select><option value="">Pick One</option><option value="aa">aa</option><option value="ab">ab</option><option value="ac">ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.attr('placeholder'), 'Pick One', 'input value was correctly set')

  combobox.$menu.remove()

test "should set placeholder text on the input if specified as an data attribute", () ->
  $select = $('<select data-placeholder="Type something..."><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.attr('placeholder'), 'Type something...', 'input value was correctly set')

  combobox.$menu.remove()

test "should set required attribute the input if specified on the select", () ->
  $select = $('<select required="required"><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.attr('required'), 'required', 'required was correctly set')

  combobox.$menu.remove()

test "should copy classes to the input if specified on the select", () ->
  $select = $('<select class="input-small"><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.attr('class'), 'input-small', 'class was correctly set')

  combobox.$menu.remove()

test "should copy rel attribute to the input if specified on the select", () ->
  $select = $('<select rel="tooltip"><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.attr('rel'), 'tooltip', 'rel was correctly set')

  combobox.$menu.remove()

test "should copy title attribute to the input if specified on the select", () ->
  $select = $('<select title="A title"><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.attr('title'), 'A title', 'title was correctly set')

  combobox.$menu.remove()

test "should respect disabled attribute", () ->
  $select = $('<select disabled><option></option><option>aa</option><option selected>ab</option><option>ac</option></select>')
  $input = $select.combobox().data('bs.combobox').$input
  combobox = $select.data('bs.combobox')

  equal($input.prop('disabled'), true)
  equal(combobox.$button.attr('disabled'), "disabled")
  equal(combobox.disabled, true)

  combobox.$menu.remove()

test "should show dropdown headers and dividers for optgroups", () ->
  $select = $('<select><option></option><optgroup label="a"><option value="aa">aa</option><option value="ab">ab</option><option value="ac">ac</option></optgroup><optgroup label="b"><option value="ba">ba</option><option value="bb">bb</option><option value="bc">bc</option></optgroup></select>').appendTo('body')
  combobox = $select.combobox().data('bs.combobox')
  menu = combobox.$menu

  combobox.lookup()

  ok menu.is(":visible"), 'menu is visible'
  equal menu.find('li').length, 9, 'has 9 items in menu'

  headers = menu.find('li.dropdown-header')
  equal headers.length, 2, 'has 2 headers'

  equal headers.eq(0).html(), 'a', 'has header for group a'
  equal menu.find('li').index(headers.eq(0)), 0, 'has header for group a in correct position'

  equal headers.eq(1).html(), 'b','has header for group b'
  equal menu.find('li').index(headers.eq(1)), 5, 'has header for group b in correct position'

  divider = menu.find('li.divider')
  equal divider.length, 1, 'has 1 divider'
  equal menu.find('li').index(divider), 4, 'has divider between groups a and b'

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()

test "should only show dropdown headers for optgroups with matches", () ->
  $select = $('<select><option></option><optgroup label="a"><option value="aa">aa</option><option value="ab">ab</option><option value="ac">ac</option></optgroup><optgroup label="b"><option value="ba">ba</option><option value="bb">bb</option><option value="bc">bc</option></optgroup></select>').appendTo('body')
  combobox = $select.combobox().data('bs.combobox')
  menu = combobox.$menu

  combobox.$input.val('aa')
  combobox.lookup()

  ok menu.is(":visible"), 'menu is visible'
  equal menu.find('li').length, 2, 'has 2 items in menu'
  equal menu.find('li.dropdown-header').length, 1, 'has 1 header'
  equal menu.find('li.divider').length, 0, 'has 0 dividers'

  combobox.$menu.remove()
  $select.remove()
  combobox.$container.remove()