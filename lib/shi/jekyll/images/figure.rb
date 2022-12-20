# encoding: utf-8

require_relative "version"

require "pp"
require "shi/args"
# require 'liquid/tag/disabler'

class Shi::Jekyll::FigureBlock < Liquid::Block

  # def initialize tag_name, markup, parse_context
  #   super tag_name, markup, parse_context
  # end

  def render(context)
    args = Shi::Args::parse(@markup)
    args.attach! context

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
    width = "#{width}px" if Numeric === width

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
      width: width,
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
    end
    if caption
      cap_attrs = ""
      cap_attrs += " class=\"#{cap_class}\"" if cap_class
      cap_attrs += " style=\"#{cap_style}\"" if cap_style
      if caption_position == :top
        text = "<figcaption markdown=\"span\"#{cap_attrs}>#{caption}</figcaption>\n#{text}"
      else
        text = "#{text}\n<figcaption markdown=\"span\"#{cap_attrs}>#{caption}</figcaption>"
      end
    end

    fig_class = 'shi_figure'
    fig_class =+ " #{cls}" if cls
    fig_attrs = " class=\"#{fig_class}\""
    # if fig_style
    #   if width
    #     fig_style += "max-width:#{width};#{fig_style}"
    #   else
    #   end
    # end
    fig_style ||= ''
    fig_style += "width:#{width};" if width
    # TODO: shape с развертыванием
    fig_attrs += " style=\"#{fig_style}\""
    if wrp_class
      wrp_class = "shi_figure_wrapper #{wrp_class}"
    else
      wrp_class = 'shi_figure_wrapper'
    end
    wrp_attrs = " class=\"#{wrp_class}\""
    wrp_attrs += " style=\"#{wrp_style}\"" if wrp_style

    "<figure markdown=\"0\"#{fig_attrs}><div#{wrp_attrs}>#{text}</div></figure>"
  end
end

Liquid::Template.register_tag "figure", Shi::Jekyll::FigureBlock
