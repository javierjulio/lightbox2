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

  build: ->
    $("<div>", id: 'lightboxOverlay', class: 'transition-hidden')
      .appendTo($('body'))
    
    $('<div/>', id: 'lightbox', class: 'transition-hidden').append(
      $('<div/>', class: 'lb-outerContainer').append(
        $('<div/>', class: 'lb-titleContainer').append(
          $('<div/>', class: 'lb-number'),
          $('<div/>', class: 'lb-title')
        ),
        $('<a class="lb-close">&#10006;</a>'),
        $('<div/>', class: 'lb-container').append(
          $('<img/>', class: 'lb-image'),
          $('<div/>',class: 'lb-nav').append(
            $('<a/>', class: 'lb-prev'),
            $('<a/>', class: 'lb-next')
          ),
          $('<div/>', class: 'lb-progress-container').append(
            $('<div/>', class: 'lb-progress')
          )
        )
      )
    ).appendTo $('body')
    
    @elementOverlay = $('#lightboxOverlay')
    @element = $('#lightbox')
    
    @elementOverlay.on 'click', (event) =>
      event.preventDefault()
      @end()
    
    @element
      .on 'click', (event) =>
        event.preventDefault()
        if $(event.target).attr('id') is 'lightbox' then @end()
      .on 'click', '.lb-prev', (event) =>
        event.preventDefault()
        event.stopPropagation()
        @changeImage @currentImageIndex - 1
      .on 'click', '.lb-next', (event) =>
        event.preventDefault()
        event.stopPropagation()
        @changeImage @currentImageIndex + 1
      .on 'click', '.lb-close', (event) =>
        event.preventDefault()
        event.stopPropagation()
        @end()
    
    return

  # Show overlay and lightbox. If the image is part of a set, add siblings to album array.
  start: ($link) ->
    @elementOverlay
      .prepareTransition()
      .removeClass('transition-hidden')

    @album = []
    selectedImageIndex = 0

    if $link.attr('rel') is 'lightbox'
      # Single image
      @album.push
        link: $link.attr('href'), 
        title: $link.attr('title')
    else
      # Image Gallery
      for a, i in $( $link.prop("tagName") + '[rel="' + $link.attr('rel') + '"]')
        $element = $(a)
        
        @album.push
          link: $element.attr('href')
          title: $element.attr('title')
        
        if $element.attr('href') is $link.attr('href')
          selectedImageIndex = i

    # Position lightbox
    $window = $(window)
    top = $window.scrollTop() + $window.height()/10
    left = $window.scrollLeft()
    @element
      .css
        top: top + 'px'
        left: left + 'px'
      .prepareTransition()
      .removeClass('transition-hidden')

    @changeImage(selectedImageIndex)
    @enableKeyboardActions()
    return

  # Hide most UI elements in preparation for the animated resizing of the lightbox.
  changeImage: (index) ->
    @currentImageIndex = index
    
    $image = @element.find('.lb-image')
    
    if Modernizr.csstransitions
      $image.addClass('transition-hidden')
    else
      $image.hide()
    
    @element
      .find('.lb-progress-container').show().end()
      .find('.lb-prev, .lb-next').hide()
    
    @updateDetails()
    
    preloader = new Image
    preloader.onload = () =>
      $image.attr 'src', @album[index].link
      $image[0].width = preloader.width
      $image[0].height = preloader.height
      @sizeContainer(preloader.width, preloader.height)
    preloader.src = @album[index].link
    return

  # Animate the size of the lightbox to fit the image we are showing
  sizeContainer: (imageWidth, imageHeight) ->
    $outerContainer = @element.find('.lb-outerContainer')
    currentWidth = $outerContainer.width()
    $imageContainer = @element.find('.lb-container')
    currentHeight = $imageContainer.height()
    newWidth = imageWidth
    newHeight = imageHeight
    
    if newWidth is currentWidth and newHeight is currentHeight
      @showImage()
    else if Modernizr.csstransitions
      $outerContainer
        .width(newWidth)
        .one 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', (event) =>
          @showImage()
      $imageContainer
        .height(newHeight)
        .one 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', (event) =>
          @showImage()
    else
      $outerContainer.animate
        width: newWidth,
      , @options.resizeDuration, 'swing'
      
      $imageContainer.animate
        height: newHeight,
      , @options.resizeDuration, 'swing'
      
      setTimeout =>
        @showImage()
      , @options.resizeDuration
      
    return

  showImage: ->
    @element.find('.lb-progress-container').hide()
    
    if Modernizr.csstransitions
      @element
        .find('.lb-image')
        .removeClass('transition-hidden')
    else
      @element.find('.lb-image').fadeIn()
    
    @updateNavigation()
    @preloadNeighboringImages()
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
