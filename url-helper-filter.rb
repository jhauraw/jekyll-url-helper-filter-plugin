module Jekyll
  module Filters

    # The @get_ methods grabs/returns a value from _config.yml
    def get_url
      url = @context.registers[:site].config['url']
    end

    def get_baseurl
      baseurl = @context.registers[:site].config['baseurl']
    end

    # The @to_ methods transform a root-relative path into the path type
    # of the method name.

    # BASE URL: /img/dog.jpg to /blog/img/bog.jpg
    def to_baseurl(input)

      # baseurl << input # wouldn't work, created a huge concat chain
      input = "#{get_baseurl}#{input}"
    end

    # ABSOLUTE URL: /img/dog.jpg -> http://domain.tld/img/dog.jpg
    #
    # If _config.yml @baseurl is set that value will be inserted between
    # the TLD and the relative path, e.g.:
    # http://domain.tld/blog/img/dog.jpg
    def to_absurl(input)

      # url + baseurl << input
      input = "#{get_url}#{get_baseurl}#{input}"
    end

    # Prepend a CDN 'virtual versioned' URL for any relative URL resource,
    #
    # Example input value for a relative image resource:
    # /img/dog.jpg
    #
    # Example return value for an Amazon Cloudfront CDN URL:
    # //xxx.cloudfront.net/BASE_URL/PREFIX+RELEASE/img/dog.jpg
    #
    # Using crc32 to return consistent cross-machine numeric value of string.
    # input.hash sucks and returns diff value for same string, even on same
    # machine.
    #
    # Using value of @input string to match with same CDN Host upon successive
    # site regenerations to maintain caching across builds unless release id
    # changes.
    #
    # Release id, if not set or null, the current day's date will be used
    # with two digit century; given 2025/01/15, release will equal 250115
    #
    # Prefix. Release id is prefixed with this value, for catching in
    # an .htaccess RewriteRule such as:
    # RewriteRule ^v[0-9]{6,6}/(.*)$ /$1 [L]
    #
    # EXAMPLE _config.yml setup
    # App Config ======================================================== #
    # app:

      # Release ================================================ #

      # RELEASE
      # The current site version for use in 'virtual versioned' URLs
      # and an Origin Pull CDN setup such as CloudFront. This method
      # does not require one to use 'invalidate' on every site update
      # and syncs automatically with Cloudfront, so you don't need to
      # use S3.
      #
      # Exactly 6 digit integer. Increment by 1 for every LIVE release.
      #
      # Release id, if not set or null, the current day's date will be
      # used with two digit century; given 2025/01/15, release will
      # equal 250115
      # release: 100012

      # Mode =================================================== #

      # MODE
      # Switches some URL paths to Relative, Absolute or CDN.
      # Options: (development|production)
      # mode: development

      # CDN ==================================================== #

      # CDN HOSTS
      # Order matters. Pos 1 is host 0, Pos 2 is host 1 etc.
      # Change to CNAME hosts if you don't need SSL.
      # cdn_hosts:
        # - xxxxxxxxxxxxx1.cloudfront.net
        # - xxxxxxxxxxxxx2.cloudfront.net
        # - xxxxxxxxxxxxx3.cloudfront.net
        # - xxxxxxxxxxxxx4.cloudfront.net
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

      prefix = 'v'

      # Debugging
      # puts "\nInput: #{input}\nCDN Host: #{cdn_host}\nCDN Sub: #{cdn_sub}\nCDN Num: #{cdn_num}\nRelease: #{release}\nHash: #{hash}\n//#{cdn_host}#{get_baseurl}/#{prefix}#{release}#{input}\n"

      # If developing locally, point URLs locally, instead of CDN
      if @context.registers[:site].config['app']['mode'] == 'development'
        input = to_baseurl(input)
      else
        input = "//#{cdn_host}#{get_baseurl}/#{prefix}#{release}#{input}"
      end
    end

    # Append image size to images generated in templates for use in
    # sidebars, thumbnails, etc.
    #
    # Default usage:
    # <img src="{{ '/img/dog.jpg' | sub_imgurl }}" />
    #
    # Result:
    # <img src="/img/dog_150x150.jpg" />
    #
    # Specify @size:
    # <img src="{{ '/img/dog.jpg' | sub_imgurl: '300x300' }}" />
    #
    # Result:
    # <img src="/img/dog_300x300.jpg" />
    #
    # Specify @size and @hires:
    # <img src="{{ '/img/dog.jpg' | sub_imgurl: '300x300', true }}" />
    #
    # Result:
    # <img src="/img/dog_300x300@2x.jpg" />
    def sub_imgurl(input, size = '150x150', hires = nil)

      if hires === true
        hires = "@2x"
      end

      input.sub(/\.(jpg|png|gif)/, "_#{size}#{hires}.\\1")
    end

    # Prepend @baseurl to root-relative URLs in templates to make a
    # Root-Base-Relative URL. Looks for ="/ in href or src tags
    def sub_baseurl(input)
      input.gsub(/(href|src)="\//, "\\1=\"#{get_baseurl}/")
    end

    def sub_absurl(input)

      # Step 1: Prepend http: protocol to // URLs (protocol anonymous).

      # Step 2: Prepend @url and @baseurl to Root-Relative URLs
      # in templates to make an Absolute URL. Looks for ="/ in
      # href or src tags, not directly followed by a / (look ahead)
      input.gsub(/(href|src)="\/\//, "\\1=\"http://").gsub(/(href|src)="\/(?!\/)/, "\\1=\"#{get_url}#{get_baseurl}/")
    end

    # Sanitize for use in URL string.
    #
    # E.g.: web Development
    #
    # Result: web-development
    def sanitize_str(input)
      input.gsub(/[^a-z0-9 -]+/, '').gsub(/\s/, '-').gsub(/-{2,}/, '-').downcase
    end
  end
end

Liquid::Template.register_filter(Jekyll::Filters)
