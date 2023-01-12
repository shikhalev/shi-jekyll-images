# frozen_string_literal: true

require_relative 'version'

class Shi::Jekyll::FigureBlock < Liquid::Block
  DEFAULT_WIDTH = {
    :right => 320,
    :left => 320,
    :center => 600
  }

  def render context
    images_args = {}
    args = Shi::Args::Params::parse context, @markup
    args.each_attribute do |key, value|
      if key.to_s =~ /^img_(?<name>\w+)/
        images_args[$~[:name].intern] = value
      end
    end

    text = context.stack do
      context['extra_args'] = images_args
      super context
    end

    place = args[:place]
    if place.nil?
      place = :right if args[:right]
      place ||= :left if args[:left]
      place ||= :center
    else
      place = place.intern
    end
    width = args[:width] || Shi::Args::Value::Measure::px(DEFAULT_WIDTH[place])

    cls = '__figure'
    cls += ' ' + args[:class] if args[:class]
    cls += " __#{place}"

    style = "max-width:#{width.value};"
    style += args[:style] if args[:style]

    id = args[:id]

    attrs = "class=\"#{cls}\" style=\"#{style}\""
    attrs += " id=\"#{id}\"" if id

    caption_position = args[:caption_position]&.intern || :bottom

    caption = args[:caption]
    if text.gsub!(/^\s*#\s*(?<caption>.*?)(\n|$)/, '')
      caption ||= $~[:caption]
    end

    wrp_class = '__figure_wrapper'
    wrp_class += ' ' + args[:wrp_class] if args[:wrp_class]
    wrp_attrs = "class=\"#{wrp_class}\""
    wrp_attrs = " style=\"#{args[:wrp_style]}\"" if args[:wrp_style]
    if caption
      cap_attrs = ''
      cap_attrs += " class=\"#{args[:cap_class]}\"" if args[:cap_class]
      cap_attrs += " style=\"#{args[:cap_style]}\"" if args[:cap_style]
      if caption_position == :bottom
        text = "<div #{wrp_attrs}>#{text}</div><figcaption#{cap_attrs} markdown=\"span\">#{caption}</figcaption>"
      else
        text = "<figcaption#{cap_attrs} markdown=\"span\">#{caption}</figcaption><div #{wrp_attrs}>#{text}</div>"
      end
    else
      text = "<div #{wrp_attrs}>#{text}</div>"
    end

    "<figure #{attrs} markdown=\"0\">#{text}</figure>"
  end
end

Liquid::Template.register_tag 'figure', Shi::Jekyll::FigureBlock
