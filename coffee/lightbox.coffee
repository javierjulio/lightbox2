###

A simple, unobtrusive jQuery plugin to overlay an image or images 
(as a gallery) on top of the page in a fixed container.

Built with jQuery 1.8.3
https://github.com/javierjulio/lightbox2

###

class Lightbox
  constructor: (@linkElement, options) ->
    @album = []
    @currentImageIndex = undefined
    @element = undefined
    @options = $.extend {}, $.fn.lightbox.defaults, options, @linkElement.data()
    @build()

  build: ->
    $(@options.htmlTemplate).appendTo(document.body)
    return

  start: ($link) =>
    @element = $('#lightbox')
    @album = []
    selectedImageIndex = 0

    if $link.attr('rel') is 'lightbox' # single image
      elements = [$link]
      $link.data('lightbox', this)
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
    title = "&nbsp;"
    countLabel = ""

    if @album[@currentImageIndex].title? and @album[@currentImageIndex].title != ""
      title = @album[@currentImageIndex].title

    @element.find('.lb-title').html(title)

    if @album.length > 1
      countLabel = "#{@options.labelImage} #{@currentImageIndex + 1} #{@options.labelOf} #{@album.length}"

    @element.find('.lb-number').html(countLabel)
    return

  preloadNeighboringImages: ->
    if @album.length > @currentImageIndex + 1
      preloadNext = new Image
      preloadNext.src = @album[@currentImageIndex + 1].link
    
    if @currentImageIndex > 0
      preloadPrev = new Image
      preloadPrev.src = @album[@currentImageIndex - 1].link
    return

  enableClickActions: ->
    @element
      .on 'click.lightbox', (event) =>
        if $(event.target).attr('id') is 'lightbox' then @end()
      .on 'click.lightbox', '.lb-prev', (event) =>
        event.preventDefault()
        event.stopPropagation()
        @changeImage @currentImageIndex - 1
      .on 'click.lightbox', '.lb-next', (event) =>
        event.preventDefault()
        event.stopPropagation()
        @changeImage @currentImageIndex + 1
      .on 'click.lightbox', '.lb-close', (event) =>
        event.preventDefault()
        event.stopPropagation()
        @end()

    $(window)
      .on 'resize.lightbox', (event) =>
        imageContainer = @element.find('.lb-image-container')
        imageContainer.css('line-height', "#{imageContainer.height()}px")
      .trigger('resize.lightbox')

  disableClickActions: ->
    @element.off 'click.lightbox'
    $(window).off 'resize.lightbox'

  enableKeyboardActions: ->
    $(document).on 'keyup.lightbox', @keyboardAction
    return

  disableKeyboardActions: ->
    $(document).off 'keyup.lightbox'
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
    @disableClickActions()
    @element.find('.lb-image').replaceWith('<img class="lb-image transition-hidden"/>')
    @element.addClass('transition-hidden')

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
  htmlTemplate: """
    <div id="lightbox" class="transition-hidden">
      <div class="lb-outer-container">
        <a class="lb-close">&times;</a>
        <div class="lb-image-container">
          <img class="lb-image transition-hidden">
          <div class="lb-nav">
            <div class="lb-prev"></div>
            <div class="lb-next"></div>
          </div>
          <div class="lb-progress-container">
            <div class="lb-progress">Loading...</div>
          </div>
        </div>
        <div class="lb-footer">
          <div class="lb-title-container">
            <div class="lb-title"></div>
            <div class="lb-number"></div>
          </div>
        </div>
      </div>
    </div>
    """
