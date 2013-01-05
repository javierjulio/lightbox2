# Lightbox

This is a complete top to bottom rewrite of [Lokesh Dhakar](http://www.lokeshdhakar.com)'s [Lightbox2 plugin](http://lokeshdhakar.com/projects/lightbox2/) to simplify and modernize it. I needed a lightbox type tool for my current work project ([myfdb.com](https://www.myfdb.com/)) that was simple enough that I could modify (and boy did I often) confidently and with little trouble. I looked at other plugins but this was the simplest using jQuery but also written in CoffeeScript (huge win). Changes include:

* replaced JS effects with CSS transitions (runs great on an iPad!)
* if CSS transitions aren't supported, content is just hidden or shown as expected
* fewer DOM lookups! (man did the original have a lot)
* using full fixed CSS based overlay (no JS)
* all plugin events are namespaced
* namespaced events are added or removed when opening or closing lightbox
* registering one click and one keyup handler on document object, rather than on each individual element
* replacing misc images (close, loading, etc.) with simple text as a default (can be changed through settings)
* removed all JS for image layout by just setting line-height on the image container equal to that container's height to vertically center and then using CSS text-align which doesn't require a width to horizontally center
* window is no longer positioned using JS, all done through CSS
* remove centered chrome and now using a stretched-out-to-fill-window chrome with a solid background color matching the common style used today (Flickr, Google+, etc.)
* settings can be provided by changing global defaults, programmatically when initializing plugin, or through data attributes
* HTML can be modified through a template setting
* standardizing plugin init structure (tend to follow Bootstrap's style)
* removing code support for very old versions of IE

My main goal is to modernize Lightbox and offer enough basic options that those features can be changed through settings. Anymore than that the plugin is simple enough that its easy to modify the JS source to suit your needs. This is what I wanted but I couldn't find a similar plugin that offered that and hope this will help you as it did for me.

## Todo List

* cache all DOM lookups on start and reuse
* redo image preloading to preload in sets
* move auto intialization out of plugin and into README documentation
* come up with data attribute name to enable plugin
  * data attribute name can't lightbox but the attribute value can be
  * maybe use `data-toggle="lightbox"` but what to use for a gallery of images?
  * remove rel attribute support and replace with class and data lookup instead

## Contribute

To contribute, fork this repo, create a topic branch, make changes, then send a pull request.

Setting up this project for local development requires [CoffeeScript](http://coffeescript.org/#installation), Ruby and [rbenv](https://github.com/sstephenson/rbenv). Don't have Ruby installed? Use [ruby-build](https://github.com/sstephenson/ruby-build) and [rbenv](https://github.com/sstephenson/rbenv) and you'll be in good hands. Trust me. Best 2 CLI tools ever!

## Version History

In ongoing development...

**0.9.0** (September 10, 2012)

* Initial setup.

## License

(The MIT license)

Copyright (c) 2012 Javier Julio

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
