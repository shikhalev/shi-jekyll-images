# encoding: utf-8

require_relative "version"

require "pp"
require "shi/args"
# require 'liquid/tag/disabler'

class Shi::Jekyll::FigureBlock < Liquid::Block

  include Jekyll::Filters::URLFilters

  # def initialize tag_name, markup, parse_context
  #   super tag_name, markup, parse_context
  # end

  def render(context)
    args = Shi::Args::Params::parse(context, @markup)

    pp args.to_h

    id = args[:id]

    place = args[:place] || if args[:right]
      :right
    elsif args[:left]
      :left
    else
      :center
    end
    place = place.intern if String === place

    caption_position = args[:caption_position] || :bottom
    caption_position = caption_position.intern if String === caption_position

    cls = args[:class]
    img_class = args[:img_class]
    wrp_class = args[:wrp_class]
    cap_class = args[:cap_class]
    style = args[:style]
    img_style = args[:img_style]
    wrp_style = args[:wrp_style]
    cap_style = args[:cap_style]

    caption = args[:caption]
    link = args[:link]

    width = args[:width]
    width = Shi::Args::Value::Measure::px(width) if Numeric === width
    img_width = args[:img_width]
    img_width = Shi::Args::Value::Measure::px(img_width) if Numeric === img_width

    height = args[:height]
    height = Shi::Args::Value::Measure::px(height) if Numeric === height
    img_height = args[:img_height]
    img_height = Shi::Args::Value::Measure::px(img_height) if Numeric === img_height

    shape = args[:shape]
    img_shape = args[:img_shape]
    if img_shape == nil && (shape == true || shape == false)
      img_shape = shape
    end

    webp = args[:webp]
    thumb = args[:thumb]

    data = {
      id: id,
      place: place,
      width: img_width,
      height: img_height,
      fig_width: width,
      fig_height: height,
      class: img_class,
      style: img_style,
      shape: img_shape,
      fig_shape: shape,
      link: link,
      caption: caption,
      webp: webp,
      thumb: thumb,
    }

    text = nil
    context.stack do
      context["current_figure"] = data
      text = super context
    end

    if text.match /^\s*#\s*(?<caption>.*?)(\n|$)/
      caption = $~[:caption]
      text.gsub! /^\s*#\s*(?<caption>.*?)(\n|$)/, ''
    end
    fig_class = 'shi_figure'
    fig_class += " __shape_#{shape}" if String === shape
    fig_class += " __place_#{place}"
    fig_class += " #{cls}" if cls
    fig_attrs = " class=\"#{fig_class}\""
    fig_style ||= ''
    fig_style += "max-width:#{width};" if width
    fig_style += "shape-outside:url(#{relative_url(shape)});" if Jekyll::StaticFile === shape
    fig_attrs += " style=\"#{fig_style}\""
    if wrp_class
      wrp_class = "shi_figure_wrapper #{wrp_class}"
    else
      wrp_class = 'shi_figure_wrapper'
    end
    wrp_attrs = " class=\"#{wrp_class}\""
    wrp_attrs += " style=\"#{wrp_style}\"" if wrp_style

    if caption
      cap_attrs = ""
      cap_attrs += " class=\"#{cap_class}\"" if cap_class
      cap_attrs += " style=\"#{cap_style}\"" if cap_style
      if caption_position == :top
        text = "<figcaption markdown=\"span\"#{cap_attrs}>#{caption}</figcaption>\n<div#{wrp_attrs}>#{text}</div>"
      else
        text = "<div#{wrp_attrs}>#{text}</div>\n<figcaption markdown=\"span\"#{cap_attrs}>#{caption}</figcaption>"
      end
    end

    "<figure markdown=\"0\"#{fig_attrs}>#{text}</figure>"
  end
end

Liquid::Template.register_tag "figure", Shi::Jekyll::FigureBlock
