// Generated by CoffeeScript 1.3.3

/*
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
*/


(function() {
  var $, Lightbox, LightboxOptions,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $ = jQuery;

  LightboxOptions = (function() {

    function LightboxOptions() {
      this.resizeDuration = 700;
      this.labelImage = "Image";
      this.labelOf = "of";
    }

    return LightboxOptions;

  })();

  Lightbox = (function() {

    function Lightbox(options) {
      this.options = options;
      this.keyboardAction = __bind(this.keyboardAction, this);

      this.album = [];
      this.currentImageIndex = void 0;
      this.element = void 0;
      this.elementOverlay = void 0;
      this.init();
    }

    Lightbox.prototype.init = function() {
      this.build();
      return this.enable();
    };

    Lightbox.prototype.enable = function() {
      var _this = this;
      return $('body').on('click', 'a[rel^=lightbox], area[rel^=lightbox]', function(e) {
        _this.start($(e.currentTarget));
        return false;
      });
    };

    Lightbox.prototype.build = function() {
      var _this = this;
      $("<div>", {
        id: 'lightboxOverlay',
        "class": 'transition-hidden'
      }).appendTo($('body'));
      $('<div/>', {
        id: 'lightbox',
        "class": 'transition-hidden'
      }).append($('<div/>', {
        "class": 'lb-outerContainer'
      }).append($('<a/>', {
        "class": 'lb-close'
      }), $('<div/>', {
        "class": 'lb-container'
      }).append($('<img/>', {
        "class": 'lb-image'
      }), $('<div/>', {
        "class": 'lb-nav'
      }).append($('<a/>', {
        "class": 'lb-prev'
      }), $('<a/>', {
        "class": 'lb-next'
      })), $('<div/>', {
        "class": 'lb-progress-container'
      }).append($('<div/>', {
        "class": 'lb-progress'
      })))), $('<div/>', {
        "class": 'lb-dataContainer'
      }).append($('<div/>', {
        "class": 'lb-data'
      }).append($('<div/>', {
        "class": 'lb-details'
      }).append($('<span/>', {
        "class": 'lb-caption'
      }), $('<span/>', {
        "class": 'lb-number'
      }))))).appendTo($('body'));
      this.elementOverlay = $('#lightboxOverlay');
      this.element = $('#lightbox');
      this.elementOverlay.on('click', function(e) {
        _this.end();
        return false;
      });
      this.element.on('click', function(e) {
        if ($(e.target).attr('id') === 'lightbox') {
          _this.end();
        }
        return false;
      }).on('click', '.lb-outerContainer', function(e) {
        if ($(e.target).attr('id') === 'lightbox') {
          _this.end();
        }
        return false;
      }).on('click', '.lb-prev', function(e) {
        _this.changeImage(_this.currentImageIndex - 1);
        return false;
      }).on('click', '.lb-next', function(e) {
        _this.changeImage(_this.currentImageIndex + 1);
        return false;
      }).on('click', '.lb-close', function(e) {
        _this.end();
        return false;
      });
    };

    Lightbox.prototype.start = function($link) {
      var $window, a, i, imageNumber, left, top, _i, _len, _ref;
      $('select, object, embed').css({
        visibility: "hidden"
      });
      this.elementOverlay.prepareTransition().removeClass('transition-hidden');
      this.album = [];
      imageNumber = 0;
      if ($link.attr('rel') === 'lightbox') {
        this.album.push({
          link: $link.attr('href'),
          title: $link.attr('title')
        });
      } else {
        _ref = $($link.prop("tagName") + '[rel="' + $link.attr('rel') + '"]');
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          a = _ref[i];
          this.album.push({
            link: $(a).attr('href'),
            title: $(a).attr('title')
          });
          if ($(a).attr('href') === $link.attr('href')) {
            imageNumber = i;
          }
        }
      }
      $window = $(window);
      top = $window.scrollTop() + $window.height() / 10;
      left = $window.scrollLeft();
      this.element.css({
        top: top + 'px',
        left: left + 'px'
      }).prepareTransition().removeClass('transition-hidden');
      this.changeImage(imageNumber);
      this.enableKeyboardNav();
    };

    Lightbox.prototype.changeImage = function(imageNumber) {
      var $image, preloader,
        _this = this;
      $image = this.element.find('.lb-image');
      this.elementOverlay.prepareTransition().removeClass('transition-hidden');
      $('.lb-progress-container').show();
      this.element.find('.lb-image, .lb-prev, .lb-next, .lb-number, .lb-caption').hide();
      this.currentImageIndex = imageNumber;
      preloader = new Image;
      preloader.onload = function() {
        $image.attr('src', _this.album[imageNumber].link);
        $image[0].width = preloader.width;
        $image[0].height = preloader.height;
        return _this.sizeContainer(preloader.width, preloader.height);
      };
      preloader.src = this.album[imageNumber].link;
    };

    Lightbox.prototype.sizeContainer = function(imageWidth, imageHeight) {
      var $container, $outerContainer, containerBottomPadding, containerLeftPadding, containerRightPadding, containerTopPadding, newHeight, newWidth, oldHeight, oldWidth,
        _this = this;
      $outerContainer = this.element.find('.lb-outerContainer');
      oldWidth = $outerContainer.outerWidth();
      oldHeight = $outerContainer.outerHeight();
      $container = this.element.find('.lb-container');
      containerTopPadding = parseInt($container.css('padding-top'), 10);
      containerRightPadding = parseInt($container.css('padding-right'), 10);
      containerBottomPadding = parseInt($container.css('padding-bottom'), 10);
      containerLeftPadding = parseInt($container.css('padding-left'), 10);
      newWidth = imageWidth + containerLeftPadding + containerRightPadding;
      newHeight = imageHeight + containerTopPadding + containerBottomPadding;
      if (newWidth === oldWidth && newHeight === oldHeight) {
        this.element.find('.lb-dataContainer').width(newWidth);
        this.showImage();
      } else if (Modernizr.csstransitions) {
        $outerContainer.width(newWidth).height(newHeight).one('transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', function(event) {
          _this.element.find('.lb-dataContainer').width(newWidth);
          return _this.showImage();
        });
      } else {
        $outerContainer.animate({
          width: newWidth,
          height: newHeight
        }, this.options.resizeDuration, 'swing');
        setTimeout(function() {
          _this.element.find('.lb-dataContainer').width(newWidth);
          return _this.showImage();
        }, this.options.resizeDuration, 'swing');
      }
    };

    Lightbox.prototype.showImage = function() {
      this.element.find('.lb-progress-container').hide();
      this.element.find('.lb-image').fadeIn('slow');
      this.updateNav();
      this.updateDetails();
      this.preloadNeighboringImages();
    };

    Lightbox.prototype.updateNav = function() {
      if (this.currentImageIndex > 0) {
        this.element.find('.lb-prev').show();
      }
      if (this.currentImageIndex < this.album.length - 1) {
        this.element.find('.lb-next').show();
      }
    };

    Lightbox.prototype.updateDetails = function() {
      if (typeof this.album[this.currentImageIndex].title !== 'undefined' && this.album[this.currentImageIndex].title !== "") {
        this.element.find('.lb-caption').html(this.album[this.currentImageIndex].title).fadeIn('fast');
      }
      if (this.album.length > 1) {
        this.element.find('.lb-number').html(this.options.labelImage + ' ' + (this.currentImageIndex + 1) + ' ' + this.options.labelOf + '  ' + this.album.length).fadeIn('fast');
      } else {
        this.element.find('.lb-number').hide();
      }
      this.element.find('.lb-dataContainer').fadeIn(this.resizeDuration);
    };

    Lightbox.prototype.preloadNeighboringImages = function() {
      var preloadNext, preloadPrev;
      if (this.album.length > this.currentImageIndex + 1) {
        preloadNext = new Image;
        preloadNext.src = this.album[this.currentImageIndex + 1].link;
      }
      if (this.currentImageIndex > 0) {
        preloadPrev = new Image;
        preloadPrev.src = this.album[this.currentImageIndex - 1].link;
      }
    };

    Lightbox.prototype.enableKeyboardNav = function() {
      $(document).on('keyup.keyboard', this.keyboardAction);
    };

    Lightbox.prototype.disableKeyboardNav = function() {
      $(document).off('.keyboard');
    };

    Lightbox.prototype.keyboardAction = function(event) {
      var KEYCODE_ESC, KEYCODE_LEFTARROW, KEYCODE_RIGHTARROW, key, keycode;
      KEYCODE_ESC = 27;
      KEYCODE_LEFTARROW = 37;
      KEYCODE_RIGHTARROW = 39;
      keycode = event.keyCode;
      key = String.fromCharCode(keycode).toLowerCase();
      if (keycode === KEYCODE_ESC || key.match(/x|o|c/)) {
        this.end();
      } else if (key === 'p' || keycode === KEYCODE_LEFTARROW) {
        if (this.currentImageIndex !== 0) {
          this.changeImage(this.currentImageIndex - 1);
        }
      } else if (key === 'n' || keycode === KEYCODE_RIGHTARROW) {
        if (this.currentImageIndex < this.album.length - 1) {
          this.changeImage(this.currentImageIndex + 1);
        }
      }
    };

    Lightbox.prototype.end = function() {
      this.disableKeyboardNav();
      this.element.prepareTransition().addClass('transition-hidden');
      this.elementOverlay.prepareTransition().addClass('transition-hidden');
      return $('select, object, embed').css({
        visibility: "visible"
      });
    };

    return Lightbox;

  })();

  $(function() {
    var lightbox, options;
    $.fn.prepareTransition = function() {
      return this.each(function() {
        var cl, duration, el;
        el = $(this);
        el.one('TransitionEnd webkitTransitionEnd transitionend oTransitionEnd MSTransitionEnd', function() {
          return el.removeClass('is-transitioning');
        });
        cl = ["transition-duration", "-moz-transition-duration", "-webkit-transition-duration", "-o-transition-duration", "-ms-transition-duration"];
        duration = 0;
        $.each(cl, function(idx, itm) {
          return duration = parseFloat(el.css(itm)) || duration;
        });
        if (duration !== 0) {
          el.addClass('is-transitioning');
          return el[0].offsetWidth;
        }
      });
    };
    options = new LightboxOptions;
    return lightbox = new Lightbox(options);
  });

}).call(this);
