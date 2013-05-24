# URL Helper Filter Plugin with CDN Support for Jekyll
# Version: 1.0.0
# Release Date: 2013-05-24
# License: MIT
# (c) Copyright Jhaura Wachsman, http://jhaurawachsman.com
module Jekyll
  module Filters

    # See the README for usage examples.

    # The get_ methods grabs/returns a value from _config.yml.

    # Internal: Get the 'url' variable value from _config.yml.
    def get_url
      url = @context.registers[:site].config['url']
    end

    # Internal: Get the 'baseurl' variable value from _config.yml.
    def get_baseurl
      baseurl = @context.registers[:site].config['baseurl']
    end

    # The to_ methods transform a root-relative path into the path
    # type of the method name: to_<type>url.

    # Public: Append the 'baseurl' variable to 'input'.
    def to_baseurl(input)

      # baseurl << input # wouldn't work, created a huge concat chain
      input = "#{get_baseurl}#{input}"
    end

    # Public: Append the 'url' variable to 'input'.
    def to_absurl(input)

      # url + baseurl << input
      input = "#{get_url}#{get_baseurl}#{input}"
    end

    # Public: Append a CDN HTTP host name to a root-relative URL.
    #
    # Requires: Zlib
    #
    # cdn_hosts - An array of up to 4 hosts, ordered from 0 to 3.
    #             Order matters. Pos 0 is host 0, Pos 1 is host 1,
    #             etc. Use Cloudfront hosts if you need SSL, or
    #             CNAMEs otherwise.
    #
    #
    # release   - 6 digit integer. Default is today's date with
    #             two-digit century, e.g., 2025/01/15, release:
    #             250115.
    #
    #             The current site version for use in 'virtual
    #             versioned' URLs and an Origin Pull CDN setup
    #             such as CloudFront. This method does not
    #             require one to use 'invalidate' on every site
    #             update and syncs all assets/files on your web
    #             server with CDN URLs automatically with
    #             Cloudfront, so you don't need to use S3.
    #
    #             Only increment if EXISTING assets need to be
    #             refreshed. Adding new assets to the current
    #             cache does not require a new release number.
    #
    # prefix    - Release id is prefixed with this string. Useful
    #             for catching in an .htaccess RewriteRule.
    #             Default is 'v'.
    #
    # mode      - (development|production). The current working
    #             state. Use 'development' when working locally,
    #             offline or when you want to save bandwidth and
    #             CDN costs. Use 'production' when shipping or
    #             making your code live.
    #
    # Note: Store 'cdn_hosts', 'release', 'prefix' and 'mode' in
    # a user defined hash named 'app' _config.yml. See the README
    # for instructions on how to setup your _config.yml.
    #
    # Note: Using crc32 method to return consistent cross-machine
    # numeric value of string; input.hash sucks and returns diff
    # value for same string, even on same machine.
    #
    # Note: Using value of @input string to match with same CDN
    # Host upon successive site regenerations to maintain caching
    # across builds.
    #
    # Note: You will also need a RewriteRule in .htaccess to
    # create the 'virtual version' match to the actual asset
    # (assumes `prefix` is 'v'):
    #
    # RewriteRule ^v[0-9]{6,6}/(.*)$ /$1 [L]
    #
    # Note: You do not actually have to rename any files or
    # folders to use 'virtual versioned' URLs. You only need to
    # make sure your 'href' and 'src' attributes point to the
    # virtual version URL. The method does exactly that for you.
    #
    # Returns: //xxxxxxxxxxxxxN.cloudfront.net/BASE_URL/PREFIX+RELEASE/img/dog.jpg
    def to_cdnurl(input)

      require 'zlib'

      cdn_hosts = @context.registers[:site].config['app']['cdn_hosts']

      cdn_num = cdn_hosts.length
      hash = Zlib::crc32(input)
      cdn_sub = hash % cdn_num
      cdn_host = cdn_hosts[cdn_sub]

      release = @context.registers[:site].config['app']['release']

      if !release
        release = @context.registers[:site].time.strftime('%y%m%d')
      end

      prefix = @context.registers[:site].config['app']['prefix']

      if !prefix
        prefix = 'v'
      end

      # Debugging
      # puts "\nInput: #{input}\nCDN Host: #{cdn_host}\nCDN Sub: #{cdn_sub}\nCDN Num: #{cdn_num}\nRelease: #{release}\nHash: #{hash}\n//#{cdn_host}#{get_baseurl}/#{prefix}#{release}#{input}\n"

      # If developing locally, point URLs locally, instead of CDN
      if @context.registers[:site].config['app']['mode'] == 'development'
        input = to_baseurl(input)
      else
        input = "//#{cdn_host}#{get_baseurl}/#{prefix}#{release}#{input}"
      end
    end

    # Public: Regex globally append the 'baseurl' variable to 'input'.
    def sub_baseurl(input)
      input.gsub(/(href|src)="\//, "\\1=\"#{get_baseurl}/")
    end

    # Public: Regex globally append the 'url' variable to 'input'.
    def sub_absurl(input)

      # Step 1: Prepend http: protocol to // URLs (protocol anonymous).
      #
      # Step 2: Prepend @url and @baseurl to Root-Relative URLs
      # in templates to make an Absolute URL. Looks for ="/ in
      # href or src tags, not directly followed by a / (look ahead)
      input.gsub(/(href|src)="\/\//, "\\1=\"http://").gsub(/(href|src)="\/(?!\/)/, "\\1=\"#{get_url}#{get_baseurl}/")
    end

    # Public: Regex append image thumbnail sizes and optionally
    # @2x to 'input'.
    def sub_imgurl(input, size = '150x150', hires = nil)

      if hires === true
        hires = "@2x"
      end

      input.sub(/\.(jpg|png|gif)/, "_#{size}#{hires}.\\1")
    end

    # Public: Sanitize a string for use in a URL.
    def sanitize_str(input)
      input.gsub(/[^a-z0-9 -]+/, '').gsub(/\s/, '-').gsub(/-{2,}/, '-').downcase
    end
  end
end

Liquid::Template.register_filter(Jekyll::Filters)
