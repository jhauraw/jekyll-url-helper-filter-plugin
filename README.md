# Jekyll URL Helper Filter Plugin with CDN Support

This is a Jekyll [Liquid Filter](https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers) plugin that allows you to abstract your URLs in __template__ and __\_posts__ files so that your code is portable and normalized to a greater degree.

By using this plugin you only ever have to change your URL components in one place and the change will be reflected throughout your entire site.

This is highly advantageous with settings like `_config.yml` -> `baseurl`, your `feed.xml` file (which needs absolute URLs) and if you use a CDN or the cloud to serve some of your assets.

__Version__: 1.0.0

## How to Install

To install this plugin [download](https://github.com/jhauraw/jekyll-url-helper-filter-plugin/archive/master.zip) or copy it into a directory named `_plugins` in your project working directory.

> Visit the official __Jekyll__ [Plugin's Documentation](http://jekyllrb.com/docs/plugins/) for more information.

## Dependencies

This plugin requires the Ruby [Zlib](http://zlib.net/) library, which should be installed on most machines with a recent version of Ruby.

## Usage

See the plugin itself for information on the methods. For a high-scalability implementation and lots of usage ideas check out my own [website repo](https://github.com/jhauraw/jhaurawachsman.com).

### Methods that begin with to_

The methods which begin with `to_` transform a _root-relative_ path/url into the path/url __type__ of the method's name, e.g., base, absolute or cdn: `to_<type>url`.

The methods can be used on assets such as CSS and JS files, images, XML feeds in template files and anywhere you find useful.

### method to_baseurl

Transform a _root-relative_ URL into a _base-relative_ URL.

In your templates and optionally in your Markdown files use the `to_baseurl` method to __append__ the `baseurl` parameter value in `_config.yml` to _root-relative_ URLs.

Example:

In `_config.yml` you have:

    baseurl: /blog

In `_layouts` -> `default.html` you will likely have a CSS file linked, so we can add the _filter_ to the _Liquid_ tag to abstract the URL:

    <link rel="stylesheet" href="{{ '/css/site.css' | to_baseurl }}" />

When you _generate_ your site, the result is:

    <link rel="stylesheet" href="/blog/css/site.css" />

### method to_absurl

Transform a _root-relative_ URL into an _absolute_ URL.

In your templates and optionally in your Markdown files use the `to_absurl` method to __append__ the `url` parameter value in `_config.yml` to _root-relative_ URLs.

Example:

In `_config.yml` you have:

    url: http://www.domain.tld

In `feed/index.xml` you will likely have a _self_ link, so we can add the _filter_ in a _Liquid_ tag to make it an _absolute_ and _abstracted_ URL:

    <link href="{{ '/feed/index.xml' | to_absurl }}" rel="self" />

When you _generate_ your site, the result is:

    <link href="http://www.domain.tld/feed/index.xml" rel="self" />

If you also have `baseurl` set in `_config.yml` then `to_baseurl` will be run before and you'll get:

    <link href="http://www.domain.tld/blog/feed/index.xml" rel="self" />

### method to_cdnurl

Prepend a CDN 'virtual versioned' URL for any relative URL resource. Uses up to 4 hosts for multiple download streams at the same time.

In your templates and optionally in your Markdown files use the `to_cdnurl` method to __append__ the `cdn_hosts` parameter value in `_config.yml` to _root-relative_ URLs.

Jekyll's `_config.yml` does not have a `cdn_hosts` parameter, so we need to add our own first. There will likely be other _user specified_ parameters that you will need, so we can namespace all of them in a hash called `app`:

    app:
      release: 100000
      prefix:
      mode: development
      cdn_hosts:
        - xxxxxxxxxxxxx0.cloudfront.net
        - xxxxxxxxxxxxx1.cloudfront.net
        - xxxxxxxxxxxxx2.cloudfront.net
        - xxxxxxxxxxxxx3.cloudfront.net

You will also need a __RewriteRule__ in `.htaccess` to create the 'virtual version' match to the actual asset (assumes `prefix` is 'v'):

    RewriteRule ^v[0-9]{6,6}/(.*)$ /$1 [L]

Note: You do not actually have to rename any files or folders to use 'virtual versioned' URLs. You only need to make sure your 'href' and 'src' attributes point to the virtual version URL. The method does exactly that for you.

Tip: You can _virtual version_ any asset or file just by linking to it using this method! That means PDFs, movies, images, index.html files and web fonts.

Example:

In your `_layouts` -> `default.html` template file you have your __logo__ at the top of the page. You want to serve it from the CDN:

    <object type="image/svg+xml" data="{{ '/img/logo.svg' | to_cdnurl }}">Project Name</object>

When you _generate_ your site, the result is:

    <object type="image/svg+xml" data="//xxxxxxxxxxxxx1.cloudfront.net/v100000/img/logo.svg">Project Name</object>

Depending on the path given to the method, a different CDN host will be chosen using crc32. The final URL is put together like this:

    //xxxxxxxxxxxxxN.cloudfront.net/BASE_URL/PREFIX+RELEASE/img/dog.jpg

Note: `http:` is intentionally left off for protocol anonymous URLs.

See the documentation in the [plugin code](https://github.com/jhauraw/jekyll-url-helper-filter-plugin/blob/master/url-helper-filter.rb) for this method for more information.

## Methods that begin with sub_

Methods that begin with `sub_` do single or global regex string replacement on the input.

You should use these methods sparingly if at all as it is better to use a `to_` method on the input on a per instance basis.

### methods sub_baseurl and sub_absurl

See the `to_baseurl` and `to_absurl` for basic workings of these methods. The only difference is that the `sub_` methods search through a whole block of input rather than just a short string, meaning multiple instances of _relative_ URLs can be effected.

Example:

One place the `sub_absurl` method is very handy is in your feed xml file. Use it on the `post.content` to make any _relative_ URLs _absolute_.

    post.content (in Markdown):

      Lorem ipsum dolor sit amet, consectetur adipisicing. ![Dog Image](/img/dog.jpg)

    feed.xml (entries loop):

    {% for post in site.posts %}
      <entry>
        ...
        <content type="html">{{ post.content | sub_absurl | xml_escape }}</content>
      </entry>
    {% endfor %}

When you _generate_ your site, the result is:

    <entry>
      ...
      <content type="html">
        Lorem ipsum dolor sit amet, consectetur adipisicing. &lt;a href=&quot;http://domain.tld/img/dog.jpg&quot;&gt;
      </content>
    </entry>

### method sub_imgurl

Append image alternate size to images generated in templates such as sidebars and post asides.

This is useful for when you need to show a thumbnail or smaller version of an image such as in a __Post Archive__.

Q: Why not just hardcode the size in the template file?

A: You could. However, if you are specifying a feature image for a post in the `YAML Front Matter` you will be using something like `page.image.src` in your sidebar template and so you can't insert the thumbnail size without using a regex. So moving that task into the plugin was deemed more __DRY__.

Arguments:

  - __size__ -  The string representing the image size. Recommended format is \<width\>x\<height\> measured in pixels.
  - __hires__ - Boolean. Append @2x to the image name if true. For use with retina logic.

Example:

    <img src="{{ '/img/dog.jpg' | sub_imgurl }}" />

When you _generate_ your site, the result is:

    <img src="/img/dog_150x150.jpg" />

Specify __size__:

    <img src="{{ '/img/dog.jpg' | sub_imgurl: '300x300' }}" />

Result:

    <img src="/img/dog_300x300.jpg" />

Specify __size__ and __hires__:

    <img src="{{ '/img/dog.jpg' | sub_imgurl: '300x300', true }}" />

Result:

    <img src="/img/dog_300x300@2x.jpg" />

### method sanitize_str

Sanitize a string for use in URLs. Specifically, when you want to link to a __category__ or __tag__ name in your templates.

Category or Tag names with spaces, capital letters, etc. will break your URLs. This method formats them correctly.

Example:

    page.category: Web Development

    <a href="/{{ page.category | sanitize_str }}/">...</a>

When you _generate_ your site, the result is:

    <a href="/web-development/">...</a>

## Summary

Abstracting and normalizing the URL structure of your website is a process that will pay dividends down the road.

Bootstrapers and template developers will especially benefit from this technique when distributing their work to different users who may have preferences of their own in terms of `baseurl` directory name and string names in categories and tags.

## Author

Jhaura Wachsman [website](http://jhaurawachsman.com), [@jhaurawachsman](http://twitter.com/jhaurawachsman)

## CHANGELOG

See [CHANGELOG](https://github.com/jhauraw/jekyll-url-helper-filter-plugin/blob/master/CHANGELOG).

## LICENSE

MIT. See [LICENSE](https://github.com/jhauraw/jekyll-url-helper-filter-plugin/blob/master/LICENSE).

(c) Copyright 2013 Jhaura Wachsman.
