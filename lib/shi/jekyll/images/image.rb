# frozen_string_literal: true

require_relative 'version'
require_relative 'files'

class Shi::Jekyll::ImageTag < Liquid::Tag
  include Shi::Tools

  def width_to_bounds width
    if Shi::Args::Value::Measure === width
      width.to_px.to_s
    else
      width.to_s
    end
  end

  DEFAULT_THUMB_BOUNDS = '320'
  DEFAULT_WIDTH = Shi::Args::Value::Measure::px(320)

  def thumb_bounds context, args, extra
    bounds = args[:thumb_bounds] || extra[:thumb_bounds]
    width = args[:width] || extra[:width]
    if width && !bounds
      bounds = width_to_bounds width
    end
    bounds ||= lookup_with(context, 'thumb_bounds', ['page', 'layout', 'site.shi_images']) || DEFAULT_THUMB_BOUNDS
    bounds
  end

  def clean_path path
    path.split(/\/?#/)[0]
  end

  def render context
    args = Shi::Args::Params::parse context, @markup
    extra_args = context['extra_args'] || {}

    source = args[:src] || args[:source]
    if source == nil && Jekyll::StaticFile === args[0]
      source = args[0]
    end
    if !Jekyll::StaticFile === source
      raise ArgumentError, "Invalid source: #{source.inspect}!"
    end

    link = args[:link]
    link = false if args[:no_link]
    link = true if link == nil
    # if link == false only thumbnail needed

    site = context.registers[:site]
    page_path = clean_path(context['page.path'])
    if page_path == nil
      p context.registers[:page]
    end
    page = site.documents.find { |d| d.relative_path == page_path }
    page ||= site.pages.find { |p| p.relative_path == page_path }

    href = if link == false # nothing
        gen_big = false
        nil
      elsif Jekyll::StaticFile === link && !link.write? # uncopyable static file => picture
        gen_big = false
        bounds = args[:bounds] || extra_args[:bounds]
        Jekyll::PathManager::join '', Shi::Jekyll::Images::File::create(page, link, bounds, nil).url
      elsif link.respond_to?(:url) && link.url # document, page or static file
        gen_big = false
        Jekyll::PathManager::join '', link.url
      elsif String === link # external link
        gen_big = false
        link
      elsif link == true # generated big picture
        gen_big = true
        bounds = args[:bounds] || extra_args[:bounds]
        Jekyll::PathManager::join '', Shi::Jekyll::Images::File::create(page, source, bounds, nil).url
      else
        raise ArgumentError, "Invalid link: #{link.inspect}!"
      end

    thumb = args[:thumb]
    thumb = false if args[:no_thumb]
    thumb = true if thumb == nil
    # if thumb == false use full size as thumbnail

    if !gen_big && !thumb
      raise ArgumentError, "You can't disable large image and thumbnail at the same time!"
    end

    src = if thumb
        bounds = thumb_bounds context, args, extra_args
        crop = args[:crop] || extra_args[:crop]
        Shi::Jekyll::Images::File::create(page, source, bounds, crop).url
      else
        href
      end
    src = Jekyll::PathManager::join '', src

    cls = '__image'
    cls += ' ' + args[:class] if args[:class]
    cls += ' ' + extra_args[:class] if extra_args[:class]

    width = args[:width] || extra_args[:width] || DEFAULT_WIDTH

    style = "max-width:#{width.value};"
    style += extra_args[:style] if extra_args[:style]
    style += args[:style] if args[:style]

    shape = args[:shape] || extra_args[:shape]
    case shape
    when Jekyll::StaticFile
      style += "shape-outside:url(#{generate_thumbnail context, shape, args, extra_args, target_dir});"
    when String
      cls += " __shape_#{shape}"
    when true
      style += "shape-outside:url(#{src});"
    end

    caption = args[:caption]
    title = args[:title] || caption
    alt = args[:alt] || title
    id = args[:id]

    attrs = "class=\"#{cls}\""
    attrs += " style=\"#{style}\"" if style
    attrs += " alt=\"#{alt}\"" if alt
    attrs += " title=\"#{title}\"" if title
    attrs += " id=\"#{id}\""

    figure = args[:figure]
    if figure && !extra_args.empty?
      raise ArgumentError, 'Nested figures not allowed!'
    end

    result = ''
    if figure
      fig_class = '__figure __implicit_figure'
      place = args[:place]
      if place == 'right' || args[:right]
        fig_class += ' __right'
      elsif place == 'left' || args[:left]
        fig_class += ' __left'
      else
        fig_class += ' __center'
      end
      fig_class += ' ' + args[:fig_class] if args[:fig_class]
      fig_style = "max-width:#{width.value};"
      fig_style += args[:fig_style] if args[:fig_style]
      result += "<figure class=\"#{fig_class}\" style=\"#{fig_style}\" markdown=\"0\">"
    end
    if link != false
      # href = Jekyll::PathManager::join '', href
      result += "<a href=\"#{href}\" class=\"__image_link\">"
    end
    # src = Jekyll::PathManager::join '', src
    result += "<img src=\"#{src}\" #{attrs}>"
    if link != false
      result += '</a>'
    end
    if figure
      if caption
        result += "<figcaption markdown=\"span\">#{caption}</figcaption>"
      end
      result += '</figure>'
    end

    result
  end
end

Liquid::Template.register_tag 'image', Shi::Jekyll::ImageTag

# Jekyll::Hooks::register :site, :post_write do |site|
#   Shi::Jekyll::ImageTag::clean site
# end

# Jekyll::Hooks::register :pages, :pre_render do |*args|
#   #  puts "PAGE: #{args[0].class}: #{args[0].url}"
#   #  pp args[0].data
#   if args[0].data['image']
#     args[0].data['image'] = '/img/about/girl-1920x1080.webp'
#   end
#   #  pp args[1]
#   # puts 'PAGES:'
#   # pp args.map { |i| i.class }
# end

# Jekyll::Hooks::register :documents, :pre_render do |*args|
#   #  puts "DOCUMENT: #{args[0].class}: #{args[0].url}"
#   #  pp args[0].data
#   if args[0].data['image']
#     args[0].data['image'] = '/img/about/girl-1920x1080.webp'
#   end
#   #  pp args[1]
# end
