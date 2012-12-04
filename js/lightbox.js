// Generated by CoffeeScript 1.3.3

/*
Rewritten by Javier Julio (https://github.com/javierjulio/lightbox2)

Lightbox v2.51 (http://lokeshdhakar.com/projects/lightbox2/)
by Lokesh Dhakar (http://www.lokeshdhakar.com)

Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
- free for use in both personal and commercial projects
- attribution requires leaving author name, author link, and the license info intact
*/


(function() {
  var Lightbox,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Lightbox = (function() {

    function Lightbox(linkElement, options) {
      this.linkElement = linkElement;
      this.keyboardAction = __bind(this.keyboardAction, this);

      this.album = [];
      this.currentImageIndex = void 0;
      this.element = void 0;
      this.options = $.extend({}, $.fn.lightbox.defaults, options, this.linkElement.data());
      this.build();
    }

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
      }).append($('<div/>', {
        "class": 'lb-titleContainer'
      }).append($('<div/>', {
        "class": 'lb-number'
      }), $('<div/>', {
        "class": 'lb-title'
      })), $('<a class="lb-close">&#10006;</a>'), $('<div/>', {
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
      }))))).appendTo($('body'));
      this.elementOverlay = $('#lightboxOverlay');
      this.element = $('#lightbox');
      this.elementOverlay.on('click', function(event) {
        event.preventDefault();
        return _this.end();
      });
      this.element.on('click', function(event) {
        event.preventDefault();
        if ($(event.target).attr('id') === 'lightbox') {
          return _this.end();
        }
      }).on('click', '.lb-prev', function(event) {
        event.preventDefault();
        event.stopPropagation();
        return _this.changeImage(_this.currentImageIndex - 1);
      }).on('click', '.lb-next', function(event) {
        event.preventDefault();
        event.stopPropagation();
        return _this.changeImage(_this.currentImageIndex + 1);
      }).on('click', '.lb-close', function(event) {
        event.preventDefault();
        event.stopPropagation();
        return _this.end();
      });
    };

    Lightbox.prototype.start = function($link) {
      var $element, $window, a, i, left, selectedImageIndex, top, _i, _len, _ref;
      this.elementOverlay.prepareTransition().removeClass('transition-hidden');
      this.album = [];
      selectedImageIndex = 0;
      if ($link.attr('rel') === 'lightbox') {
        this.album.push({
          link: $link.attr('href'),
          title: $link.attr('title')
        });
      } else {
        _ref = $($link.prop("tagName") + '[rel="' + $link.attr('rel') + '"]');
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          a = _ref[i];
          $element = $(a);
          this.album.push({
            link: $element.attr('href'),
            title: $element.attr('title')
          });
          if ($element.attr('href') === $link.attr('href')) {
            selectedImageIndex = i;
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
      this.changeImage(selectedImageIndex);
      this.enableKeyboardActions();
    };

    Lightbox.prototype.changeImage = function(index) {
      var $image, preloader,
        _this = this;
      this.currentImageIndex = index;
      $image = this.element.find('.lb-image');
      if (Modernizr.csstransitions) {
        $image.addClass('transition-hidden');
      } else {
        $image.hide();
      }
      this.element.find('.lb-progress-container').show().end().find('.lb-prev, .lb-next').hide();
      this.updateDetails();
      preloader = new Image;
      preloader.onload = function() {
        $image.attr('src', _this.album[index].link);
        $image[0].width = preloader.width;
        $image[0].height = preloader.height;
        return _this.sizeContainer(preloader.width, preloader.height);
      };
      preloader.src = this.album[index].link;
    };

    Lightbox.prototype.sizeContainer = function(imageWidth, imageHeight) {
      var $imageContainer, $outerContainer, currentHeight, currentWidth, newHeight, newWidth,
        _this = this;
      $outerContainer = this.element.find('.lb-outerContainer');
      currentWidth = $outerContainer.width();
      $imageContainer = this.element.find('.lb-container');
      currentHeight = $imageContainer.height();
      newWidth = imageWidth;
      newHeight = imageHeight;
      if (newWidth === currentWidth && newHeight === currentHeight) {
        this.showImage();
      } else if (Modernizr.csstransitions) {
        $outerContainer.width(newWidth).one('transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', function(event) {
          return _this.showImage();
        });
        $imageContainer.height(newHeight).one('transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', function(event) {
          return _this.showImage();
        });
      } else {
        $outerContainer.animate({
          width: newWidth
        }, this.options.resizeDuration, 'swing');
        $imageContainer.animate({
          height: newHeight
        }, this.options.resizeDuration, 'swing');
        setTimeout(function() {
          return _this.showImage();
        }, this.options.resizeDuration);
      }
    };

    Lightbox.prototype.showImage = function() {
      this.element.find('.lb-progress-container').hide();
      if (Modernizr.csstransitions) {
        this.element.find('.lb-image').removeClass('transition-hidden');
      } else {
        this.element.find('.lb-image').fadeIn();
      }
      this.updateNavigation();
      this.preloadNeighboringImages();
    };

    Lightbox.prototype.updateNavigation = function() {
      if (this.currentImageIndex > 0) {
        this.element.find('.lb-prev').show();
      }
      if (this.currentImageIndex < this.album.length - 1) {
        this.element.find('.lb-next').show();
      }
    };

    Lightbox.prototype.updateDetails = function() {
      if ((this.album[this.currentImageIndex].title != null) && this.album[this.currentImageIndex].title !== "") {
        this.element.find('.lb-title').html(this.album[this.currentImageIndex].title);
      }
      if (this.album.length > 1) {
        this.element.find('.lb-number').html("" + (this.currentImageIndex + 1) + " " + this.options.labelOf + " " + this.album.length);
      }
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

    Lightbox.prototype.enableKeyboardActions = function() {
      $(document).on('keyup.lightbox', this.keyboardAction);
    };

    Lightbox.prototype.disableKeyboardActions = function() {
      $(document).off('.lightbox');
    };

    Lightbox.prototype.keyboardAction = function(event) {
      var KEYCODE_ESC, KEYCODE_LEFTARROW, KEYCODE_RIGHTARROW, keycode;
      KEYCODE_ESC = 27;
      KEYCODE_LEFTARROW = 37;
      KEYCODE_RIGHTARROW = 39;
      keycode = event.keyCode;
      if (keycode === KEYCODE_ESC) {
        this.end();
      } else if (keycode === KEYCODE_LEFTARROW) {
        if (this.currentImageIndex !== 0) {
          this.changeImage(this.currentImageIndex - 1);
        }
      } else if (keycode === KEYCODE_RIGHTARROW) {
        if (this.currentImageIndex < this.album.length - 1) {
          this.changeImage(this.currentImageIndex + 1);
        }
      }
    };

    Lightbox.prototype.end = function() {
      var _this = this;
      this.disableKeyboardActions();
      this.element.prepareTransition().addClass('transition-hidden');
      this.elementOverlay.prepareTransition().addClass('transition-hidden');
      if (Modernizr.csstransitions) {
        return this.element.one('transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', function(event) {
          _this.element.remove();
          return _this.elementOverlay.remove();
        });
      } else {
        this.element.remove();
        return this.elementOverlay.remove();
      }
    };

    return Lightbox;

  })();

  $(document).on('click', 'a[rel^=lightbox], area[rel^=lightbox]', function(event) {
    event.preventDefault();
    event.stopPropagation();
    return $(this).lightbox();
  });

  $.fn.lightbox = function(options) {
    return this.each(function() {
      var $el, data;
      $el = $(this);
      data = $el.data('lightbox');
      if (!data) {
        $el.data('lightbox', (data = new Lightbox($el, options)));
      }
      return data.start($el);
    });
  };

  $.fn.lightbox.Constructor = Lightbox;

  $.fn.lightbox.defaults = {
    labelImage: 'Image',
    labelOf: 'of'
  };

}).call(this);
