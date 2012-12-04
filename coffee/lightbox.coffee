###
Rewritten by Javier Julio (https://github.com/javierjulio/lightbox2)

Lightbox v2.51 (http://lokeshdhakar.com/projects/lightbox2/)
by Lokesh Dhakar (http://www.lokeshdhakar.com)

Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
- free for use in both personal and commercial projects
- attribution requires leaving author name, author link, and the license info intact
###

class Lightbox
  constructor: (@linkElement, options) ->
    @album = []
    @currentImageIndex = undefined
    @element = undefined
    @options = $.extend {}, $.fn.lightbox.defaults, options, @linkElement.data()
    @build()

  # TODO: refactor so HTML is a settings default and is built as one string rather than all jQuery objects
  build: ->
    $('<div/>', id: 'lightbox', class: 'transition-hidden').append(
      $('<div/>', class: 'lb-outer-container').append(
        $('<a class="lb-close">&times;</a>'),
        $('<div/>', class: 'lb-image-container').append(
          $('<img class="lb-image transition-hidden"/>'),
          $('<div/>', class: 'lb-nav').append(
            $('<a/>', class: 'lb-prev'),
            $('<a/>', class: 'lb-next')
          ),
          $('<div/>', class: 'lb-progress-container').append(
            $('<div/>', class: 'lb-progress', text: 'Loading...')
          )
        ),
        $('<div/>', class: 'lb-footer').append(
          $('<div/>', class: 'lb-title-container').append(
            $('<div/>', class: 'lb-title'),
            $('<div/>', class: 'lb-number')
          )
        )
      )
    ).appendTo $('body')
    return

  start: ($link) =>
    @element = $('#lightbox')
    @album = []
    selectedImageIndex = 0

    if $link.attr('rel') is 'lightbox' # single image
      elements = [$link]
    else # image gallery
      elements = $( $link.prop("tagName") + '[rel="' + $link.attr('rel') + '"]')

    elements.data('lightbox', this)

    for a, i in elements
      $element = $(a)
      
      @album.push
        link: $element.attr('href')
        title: $element.attr('title')

      if $element.attr('href') is $link.attr('href')
        selectedImageIndex = i

    @element.removeClass('transition-hidden')

    @changeImage(selectedImageIndex)

    @updateDetails()
    @enableClickActions()
    @enableKeyboardActions()
    return

  changeImage: (index) ->
    @currentImageIndex = index

    $image = @element.find('.lb-image')

    if Modernizr.csstransitions
      $image.addClass('transition-hidden')
    else
      $image.hide()

    @element.find('.lb-progress-container').show()

    @element.find('.lb-prev, .lb-next').hide()

    preloader = new Image
    preloader.onload = () =>
      $image.attr('src', @album[index].link)
      @showImage()
    preloader.src = @album[index].link
    return

  showImage: ->
    @element.find('.lb-progress-container').hide()

    if Modernizr.csstransitions
      @element.find('.lb-image').removeClass('transition-hidden')
    else
      @element.find('.lb-image').show()

    @updateDetails()
    @updateNavigation()
    @preloadNeighboringImages()
    return

  enableNavigation: ->
    @enableKeyboardActions()
    @updateNavigation()
    return

  disableNavigation: ->
    @disableKeyboardActions()
    @element.find('.lb-prev, .lb-next').hide()
    return

  updateNavigation: ->
    @element.find('.lb-prev').show() if @currentImageIndex > 0
    @element.find('.lb-next').show() if @currentImageIndex < @album.length - 1
    return

  updateDetails: ->
    if @album[@currentImageIndex].title? and @album[@currentImageIndex].title != ""
      @element
        .find('.lb-title')
        .html(@album[@currentImageIndex].title)

    if @album.length > 1
      @element
        .find('.lb-number')
        .html("#{@currentImageIndex + 1} #{@options.labelOf} #{@album.length}")
    return

  preloadNeighboringImages: ->
    if @album.length > @currentImageIndex + 1
      preloadNext = new Image
      preloadNext.src = @album[@currentImageIndex + 1].link
    
    if @currentImageIndex > 0
      preloadPrev = new Image
      preloadPrev.src = @album[@currentImageIndex - 1].link
    return

  enableKeyboardActions: ->
    $(document).on 'keyup.lightbox', @keyboardAction
    return

  disableKeyboardActions: ->
    $(document).off '.lightbox'
    return

  keyboardAction: (event) =>
    KEYCODE_ESC = 27
    KEYCODE_LEFTARROW = 37
    KEYCODE_RIGHTARROW = 39

    keycode = event.keyCode

    if keycode is KEYCODE_ESC
      @end()
    else if keycode is KEYCODE_LEFTARROW
      if @currentImageIndex != 0
        @changeImage @currentImageIndex - 1
    else if keycode is KEYCODE_RIGHTARROW
      if @currentImageIndex < @album.length - 1
        @changeImage @currentImageIndex + 1
    return

  end: ->
    @disableKeyboardActions()
    @element.prepareTransition().addClass('transition-hidden')
    @elementOverlay.prepareTransition().addClass('transition-hidden')
    
    if Modernizr.csstransitions
      @element.one 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', (event) =>
        @element.remove()
        @elementOverlay.remove()
    else
      @element.remove()
      @elementOverlay.remove()

$(document).on 'click', 'a[rel^=lightbox], area[rel^=lightbox]', (event) ->
  event.preventDefault()
  event.stopPropagation()
  $(this).lightbox()

$.fn.lightbox = (options) ->
  this.each ->
    $el = $(this)
    data = $el.data 'lightbox'
    if !data then $el.data('lightbox', (data = new Lightbox($el, options)))
    data.start($el)

$.fn.lightbox.Constructor = Lightbox

$.fn.lightbox.defaults =
  labelImage: 'Image'
  labelOf: 'of'
