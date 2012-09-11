###
Lightbox v2.51
by Lokesh Dhakar - http://www.lokeshdhakar.com

For more information, visit:
http://lokeshdhakar.com/projects/lightbox2/

Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
- free for use in both personal and commercial projects
- attribution requires leaving author name, author link, and the license info intact
	
Thanks
- Scott Upton(uptonic.com), Peter-Paul Koch(quirksmode.com), and Thomas Fuchs(mir.aculo.us) for ideas, libs, and snippets.
- Artemy Tregubenko (arty.name) for cleanup and help in updating to latest proto-aculous in v2.05.
###

class LightboxOptions
  constructor: ->
    @resizeDuration = 500
    @labelImage = "Image"
    @labelOf = "of"


class Lightbox
  constructor: (@options, @linkElement) ->
    @album = []
    @currentImageIndex = undefined
    @element = undefined
    @elementOverlay = undefined
    @build()
    @start(@linkElement)
  
  # Build html for the lightbox and the overlay.
  # Attach event handlers to the new DOM elements. click click click
  build: ->
    $("<div>", id: 'lightboxOverlay', class: 'transition-hidden')
      .appendTo($('body'))
    
    $('<div/>', id: 'lightbox', class: 'transition-hidden').append(
      $('<div/>', class: 'lb-outerContainer').append(
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
      ),
      $('<div/>', class: 'lb-dataContainer').append(
        $('<div/>', class: 'lb-caption'),
        $('<div/>', class: 'lb-number')
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
    $image = @element.find('.lb-image')
    
    if Modernizr.csstransitions
      $image.addClass('transition-hidden')
    else
      $image.hide()
    
    @element
      .find('.lb-progress-container').show().end()
      .find('.lb-prev, .lb-next, .lb-number, .lb-caption').hide()
    
    @currentImageIndex = index
    
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
    currentHeight = $outerContainer.height()
    newWidth = imageWidth
    newHeight = imageHeight
    
    if newWidth is currentWidth and newHeight is currentHeight
      @showImage()
    else if Modernizr.csstransitions
      $outerContainer
        .width(newWidth)
        .height(newHeight)
        .one 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', (event) =>
          @element.find('.lb-dataContainer').width(newWidth)
          @showImage()
    else
      $outerContainer.animate
        width: newWidth,
        height: newHeight
      , @options.resizeDuration, 'swing'
      
      setTimeout =>
        @element.find('.lb-dataContainer').width(newWidth)
        @showImage()
      , @options.resizeDuration
      
    return

  showImage: ->
    @element.find('.lb-progress-container').hide()
    if Modernizr.csstransitions
      @element
        .find('.lb-image')
        .prepareTransition()
        .removeClass('transition-hidden')
    else
      @element.find('.lb-image').fadeIn()
    @updateNavigation()
    @updateDetails()
    @preloadNeighboringImages()
    return

  updateNavigation: ->
    @element.find('.lb-prev').show() if @currentImageIndex > 0
    @element.find('.lb-next').show() if @currentImageIndex < @album.length - 1
    return

  updateDetails: ->
    if @album[@currentImageIndex].title? and @album[@currentImageIndex].title != ""
      @element
        .find('.lb-caption')
        .html(@album[@currentImageIndex].title)
        .fadeIn('fast')

    if @album.length > 1
      @element
        .find('.lb-number')
        .html("#{@options.labelImage} #{@currentImageIndex + 1} #{@options.labelOf} #{@album.length}")
        .fadeIn('fast')
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


$ ->
  $.fn.prepareTransition = ->
    return this.each ->
      el = $(this)
      
      el.one 'TransitionEnd webkitTransitionEnd transitionend oTransitionEnd MSTransitionEnd', ->
        el.removeClass('is-transitioning')
      
      cl = ["transition-duration", "-moz-transition-duration", "-webkit-transition-duration", "-o-transition-duration", "-ms-transition-duration"]
      duration = 0
      $.each cl, (idx, itm) ->
        duration =  parseFloat( el.css( itm ) ) || duration
      
      if duration isnt 0
        el.addClass('is-transitioning')
        el[0].offsetWidth
  
  $('body').on 'click', 'a[rel^=lightbox], area[rel^=lightbox]', (event) =>
    event.preventDefault()
    event.stopPropagation()
    options = new LightboxOptions
    lightbox = new Lightbox options, $(event.currentTarget)
