# frozen_string_literal: true

require 'digest'

require_relative 'version'

class Shi::Jekyll::ImageTag < Liquid::Tag
  # class TargetFile < Jekyll::StaticFile
  #   def write(dest)
  #     true # Recover from strange exception when starting server without --auto
  #   end
  # end

  include Shi::Tools

  def get_target_dir context
    page = context.registers[:page]
    result = context['site.shi_images.path'] || 'img'
    by_url = true
    if page['date']
      result = Jekyll::PathManager::join result, page['date'].strftime('%Y/%m/%d')
      by_url = false
    end
    if page['slug']
      result = Jekyll::PathManager::join result, page['slug']
      by_url = false
    end
    if by_url
      if page['url']
        result = Jekyll::PathManager::join result, page['url']
      else
        raise ArgumentError, 'O_o!'  # TODO: нормальное исключение
      end
    end
    result
  end

  DEFAULT_BOUNDS = '1920x1080'

  def bounds_to_resize bounds
    case bounds.upcase
    when 'HD', '720P'
      '-resize 1280x720>'
    when 'FULLHD', 'FHD', '1080P'
      '-resize 1920x1080>'
    when 'WYXGA', '1200P'
      '-resize 1920x1200>'
    when '2K', 'QUADHD', 'QHD', 'WQHD', '1440P'
      '-resize 2560x1440>'
    when '4K', 'ULTRAHD', 'UHD', '2160P'
      '-resize 3840x2160>'
    when '5K', '2880P'
      '-resize 5120x2880>'
    when '8K', '4320P'
      '-resize 7680x4320>'
    when 'SOURCE', 'ORIGINAL', 'ORIGIN', 'NONE'
      ''
    else
      "-resize '#{bounds}>'"
    end
  end

  def generate_picture context, source, bounds, target_dir, crop = nil
    type = File.extname source.relative_path
    svg = type.downcase == '.svg'
    if svg && source.write?
      return source.url
    end

    key = (source.relative_path + '@' + (svg ? '' : bounds)).freeze
    @@generated ||= {}
    if @@generated[key]
      return @@generated[key]
    end

    site = context.registers[:site]
    target_name = source.basename + (svg ? '.svg' : '-' + bounds + '.webp')
    target_path = Jekyll::PathManager::join target_dir, target_name
    target_path_with_leading_slash = Jekyll::PathManager::join '', target_path
    sf = site.static_files.select { |f| f.relative_path == target_path || f.relative_path == target_path_with_leading_slash }.first
    if !sf || context['site.shi_images.regenerate']
      cmd = nil
      cmd_src = Jekyll::PathManager::join site.source, source.relative_path
      cmd_tgt = Jekyll::PathManager::join site.source, target_path
      if svg
        # тупо копируем
        # TODO: разобраться с ресайзом
        cmd = "cp '#{cmd_src}' '#{cmd_tgt}'"
      else
        cropping = if crop
            "-crop '#{crop}' "
          else
            ''
          end
        cmd = "convert '#{cmd_src}' #{cropping}#{bounds_to_resize(bounds)} '#{cmd_tgt}'"
      end
      system(cmd, exception: true)
    end
    if !sf
      tgt_dir = Jekyll::PathManager::join '', target_dir
      sf = Jekyll::StaticFile::new(site, site.source, tgt_dir, target_name)
      site.static_files << sf
    end
    @@generated[key] = sf.url.freeze
    p [sf, sf.url, target_path]
    sf.url
  end

  def image_bounds context, args
    args[:bounds] || lookup_with(context, 'image_bounds', ['page', 'layout', 'site.shi_images']) || DEFAULT_BOUNDS
  end

  def generate_big_picture context, source, args, target_dir
    bounds = image_bounds context, args
    generate_picture context, source, bounds, target_dir
  end

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
    bounds = args[:thumb_bounds]
    width = args[:width] || extra[:width]
    if width && !bounds
      bounds = width_to_bounds width
    end
    bounds ||= lookup_with(context, 'thumb_bounds', ['page', 'layout', 'site.shi_images']) || DEFAULT_THUMB_BOUNDS
    bounds
  end

  def generate_thumbnail context, source, args, extra, target_dir
    bounds = thumb_bounds context, args, extra
    generate_picture context, source, bounds, target_dir
  end

  private :get_target_dir, :generate_big_picture, :generate_thumbnail

  def render context
    args = Shi::Args::Params::parse context, @markup
    extra_args = context['extra_args'] || {}

    p args.to_h

    source = args[:src] || args[:source]
    if source == nil && Jekyll::StaticFile === args[0]
      source = args[0]
    end
    if !Jekyll::StaticFile === source
      raise ArgumentError, "Invalid source: #{source.inspect}!"
    end

    target_dir = get_target_dir context
    FileUtils.mkdir_p target_dir

    link = args[:link]
    link = false if args[:no_link]
    link = true if link == nil
    # if link == false only thumbnail needed

    href = if link == false # nothing
        gen_big = false
        nil
      elsif Jekyll::StaticFile === link && !link.write? # uncopyable static file => picture
        gen_big = false
        generate_big_picture context, link, args, target_dir
      elsif link.respond_to?(:url) && link.url # document, page or static file
        gen_big = false
        link.url
      elsif String === link # external link
        gen_big = false
        link
      elsif link == true # generated big picture
        gen_big = true
        generate_big_picture context, source, args, target_dir
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
        generate_thumbnail context, source, args, extra_args, target_dir
      else
        href
      end

    cls = '__image'
    cls += ' ' + args[:class] if args[:class]
    cls += ' ' + extra_args[:class] if extra_args[:class]

    width = args[:width] || extra_args[:width] || DEFAULT_WIDTH

    style = "max-width:#{width.value};"
    style += extra_args[:style] if extra_args[:style]
    style += args[:style] if args[:style]

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
      fig_style = "max-width:#{width.value}"
      fig_style += args[:fig_style] if args[:fig_style]
      result += "<figure class=\"#{fig_class}\" style=\"#{fig_style}\">"
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
