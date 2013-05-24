# URL Helper Filter Plugin for Jekyll

This is a Jekyll [Liquid Filter](https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers) plugin that allows you to abstract your URLs in __template__ and __\_posts__ files so that your code is portable and normalized to a greater degree.

By using this plugin you only ever have to change your URL components in one place and the change will be reflected throughout your entire site.

This is highly advantageous with settings like `_config.yml` -> `baseurl`, your `feed.xml` file which needs absolute URLs and if you use a CDN or the cloud to serve some of your assets. See the examples below for full usage.

## How to Install

To install this plugin download or copy into a directory named `_plugins` in your project working directory.

> Visit the official __Jekyll__ [plugins documentation](http://jekyllrb.com/docs/plugins/) for more information.

## Dependencies

This plugin requires the Ruby [Zlib](http://zlib.net/) library, which should be installed on most machines with a recent version of Ruby.

## Usage

See the plugin itself for information on the methods. For a high-scalability implimentation and lots of usage ideas check out my own [website repo](https://github.com/jhauraw/jhaurawachsman.com).

### Methods that begin with to_

The methods which begin with `to_` transform a _root-relative_ path/url into the path/url type of the method's name, e.g., base, absolute or cdn.

The methods can be used on assets such as CSS and JS files, images, XML feeds in template files and anywhere you find useful.

### method to_baseurl

Transform a _root-relative_ URL into a _base-relative_ URL.

In your template and optionally in your markdown files use the `to_baseurl` method to __append__ the `baseurl` parameter value in `_config.yml` to _root-relative_ URLs.

Example:

In `_config.yml` you have:

    baseurl: /blog

In `_layouts` -> `default.html` you will likely have a CSS file linked, so we can add the _filter_ to the _Liquid_ tag to abstract the URL:

    <link rel="stylesheet" href="{{ '/css/site.css' | to_baseurl }}" />

When you _generate_ your site, the result is:

    <link rel="stylesheet" href="/blog/css/site.css" />

### method to_absurl

Transform a _root-relative_ URL into an _absolute_ URL.

In your template and optionally in your markdown files use the `to_absurl` method to __append__ the `@url` parameter value in `_config.yml` to _root-relative_ URLs.

Example:

In `_config.yml` you have:

    url: http://www.domain.tld

In `feed/index.xml` you will likely have a _self_ link, so we can add the _filter_ in a _Liquid_ tag to make it an _absolute_ and _abstracted_ URL:

    <link href="{{ '/feed/index.xml' | to_absurl }}" rel="self" />

When you _generate_ your site, the result is:

    <link href="http://www.domain.tld/feed/index.xml" rel="self" />

If you also have `baseurl` set in `_config.yml` then `to_baseurl` will be run before and you'll get:

    <link href="http://www.domain.tld/blog/feed/index.xml" rel="self" />

## Author

Jhaura Wachsman [website](http://jhaurawachsman.com), [@jhaurawachsman](http://twitter.com/jhaurawachsman)

## LICENSE

MIT. See the complete [LICENSE](https://github.com/jhauraw/jekyll-url-helper-filter-plugin/blob/master/LICENSE) for more information.

(c) Copyright 2013 Jhaura Wachsman.
