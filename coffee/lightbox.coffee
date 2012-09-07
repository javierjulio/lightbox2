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


Table of Contents
=================
LightboxOptions

Lightbox
- constructor
- init
- enable
- build
- start
- changeImage
- sizeContainer
- showImage
- updateNav
- updateDetails
- preloadNeigbhoringImages
- enableKeyboardNav
- disableKeyboardNav
- keyboardAction
- end

options = new LightboxOptions
lightbox = new Lightbox options

###

# Use local alias
$ = jQuery

class LightboxOptions
  constructor: ->
    @resizeDuration = 700
    @labelImage = "Image" # Change to localize to non-english language
    @labelOf = "of"


class Lightbox
  constructor: (@options) ->
    @album = []
    @currentImageIndex = undefined
    @element = undefined
    @elementOverlay = undefined
    @init()
  
  init: ->
    @build()
    @enable()
  
  # Loop through anchors and areamaps looking for rel attributes that contain 'lightbox'
  # On clicking these, start lightbox.
  enable: ->
    $('body').on 'click', 'a[rel^=lightbox], area[rel^=lightbox]', (e) =>
      @start $(e.currentTarget)
      false
  
  # Build html for the lightbox and the overlay.
  # Attach event handlers to the new DOM elements. click click click
  build: ->
    $("<div>", id: 'lightboxOverlay', class: 'transition-hidden')
      .appendTo($('body'))
    
    $('<div/>', id: 'lightbox', class: 'transition-hidden').append(
      $('<div/>', class: 'lb-outerContainer').append(
        $('<a/>', class: 'lb-close'),
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
        $('<div/>', class: 'lb-data').append(          
          $('<div/>', class: 'lb-details').append(
            $('<span/>', class: 'lb-caption'),
            $('<span/>', class: 'lb-number')
          )
        )
      )
    ).appendTo $('body')
    
    @elementOverlay = $('#lightboxOverlay')
    @element = $('#lightbox')
    
    @elementOverlay.on 'click', (e) =>
      @end()
      return false
    
    @element
      .on 'click', (e) =>
        if $(e.target).attr('id') == 'lightbox' then @end()
        return false
      .on 'click', '.lb-outerContainer', (e) =>
        if $(e.target).attr('id') == 'lightbox' then @end()
        return false
      .on 'click', '.lb-prev', (e) =>
        @changeImage @currentImageIndex - 1
        return false
      .on 'click', '.lb-next', (e) =>
        @changeImage @currentImageIndex + 1
        return false
      .on 'click', '.lb-close', (e) =>
        @end()
        return false
    
    return

  # Show overlay and lightbox. If the image is part of a set, add siblings to album array.
  start: ($link) ->
    $('select, object, embed').css visibility: "hidden"
    
    @elementOverlay
      .prepareTransition()
      .removeClass('transition-hidden')

    @album = []
    imageNumber = 0

    if $link.attr('rel') == 'lightbox'
      # If image is not part of a set
      @album.push link: $link.attr('href'), title: $link.attr('title')
    else
      # Image is part of a set
      for a, i in $( $link.prop("tagName") + '[rel="' + $link.attr('rel') + '"]')
        @album.push link: $(a).attr('href'), title: $(a).attr('title')
        if $(a).attr('href') == $link.attr('href')
          imageNumber = i

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

    @changeImage(imageNumber)
    @enableKeyboardNav()
    return

  # Hide most UI elements in preparation for the animated resizing of the lightbox.
  changeImage: (imageNumber) ->
    $image = @element.find('.lb-image')
    
    @elementOverlay
      .prepareTransition()
      .removeClass('transition-hidden')
    
    $('.lb-progress-container').show()
    
    @element.find('.lb-image, .lb-prev, .lb-next, .lb-number, .lb-caption').hide()
    
    @currentImageIndex = imageNumber
    
    # When image to show is preloaded, we send the width and height to sizeContainer()
    preloader = new Image
    preloader.onload = () =>
      $image.attr 'src', @album[imageNumber].link
      $image[0].width = preloader.width
      $image[0].height = preloader.height
      @sizeContainer preloader.width, preloader.height
    preloader.src = @album[imageNumber].link
    
    return

  # Animate the size of the lightbox to fit the image we are showing
  sizeContainer: (imageWidth, imageHeight) ->
    $outerContainer = @element.find('.lb-outerContainer')
    oldWidth = $outerContainer.outerWidth()
    oldHeight = $outerContainer.outerHeight()

    $container = @element.find('.lb-container')
    containerTopPadding = parseInt $container.css('padding-top'), 10
    containerRightPadding = parseInt $container.css('padding-right'), 10
    containerBottomPadding = parseInt $container.css('padding-bottom'), 10
    containerLeftPadding = parseInt $container.css('padding-left'), 10

    newWidth = imageWidth + containerLeftPadding + containerRightPadding
    newHeight = imageHeight + containerTopPadding + containerBottomPadding

    if newWidth == oldWidth and newHeight == oldHeight
      @element.find('.lb-dataContainer').width(newWidth)
      @showImage()
    else if Modernizr.csstransitions # if transition support OR no width and height changed
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
      , @options.resizeDuration, 'swing'
      
    return
  
  # Display the image and it's details and begin preload neighboring images.
  showImage: ->
    @element.find('.lb-progress-container').hide()
    @element.find('.lb-image').fadeIn 'slow'
    @updateNav()
    @updateDetails()
    @preloadNeighboringImages()
    return

  # Display previous and next navigation if appropriate.
  updateNav: ->
    @element.find('.lb-prev').show() if @currentImageIndex > 0
    @element.find('.lb-next').show() if @currentImageIndex < @album.length - 1
    return
  
  # Display caption, image number, and closing button. 
  updateDetails: ->
    if typeof @album[@currentImageIndex].title != 'undefined' && @album[@currentImageIndex].title != ""
      @element
        .find('.lb-caption')
        .html( @album[@currentImageIndex].title)
        .fadeIn('fast')

    if @album.length > 1
      @element
        .find('.lb-number')
        .html( @options.labelImage + ' ' + (@currentImageIndex + 1) + ' ' + @options.labelOf + '  ' + @album.length)
        .fadeIn('fast')
    else
      @element.find('.lb-number').hide()

    @element
      .find('.lb-dataContainer')
      .fadeIn @resizeDuration
    return

  # Preload previos and next images in set.  
  preloadNeighboringImages: ->
    if @album.length > @currentImageIndex + 1
      preloadNext = new Image
      preloadNext.src = @album[@currentImageIndex + 1].link
    
    if @currentImageIndex > 0
      preloadPrev = new Image
      preloadPrev.src = @album[@currentImageIndex - 1].link    
    return

  enableKeyboardNav: ->
    $(document).on 'keyup.keyboard', @keyboardAction
    return
  
  disableKeyboardNav: ->
    $(document).off '.keyboard'
    return
  
  keyboardAction: (event) =>
    KEYCODE_ESC = 27
    KEYCODE_LEFTARROW = 37
    KEYCODE_RIGHTARROW = 39

    keycode = event.keyCode
    key = String.fromCharCode(keycode).toLowerCase()
    
    if keycode == KEYCODE_ESC || key.match(/x|o|c/)
      @end()
    else if key == 'p' || keycode == KEYCODE_LEFTARROW
      if @currentImageIndex != 0
        @changeImage @currentImageIndex - 1
    else if key == 'n' || keycode == KEYCODE_RIGHTARROW
      if @currentImageIndex < @album.length - 1
        @changeImage @currentImageIndex + 1
    return
  
  end: ->
    @disableKeyboardNav()
    @element.prepareTransition().addClass('transition-hidden')
    @elementOverlay.prepareTransition().addClass('transition-hidden')
    $('select, object, embed').css visibility: "visible"


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
      
      if duration != 0
        el.addClass('is-transitioning')
        el[0].offsetWidth
  
  options = new LightboxOptions
  lightbox = new Lightbox options