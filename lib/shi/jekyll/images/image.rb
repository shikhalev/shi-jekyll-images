# encoding: utf-8

require 'forwardable'
require 'liquid/file_system'
require 'liquid/template'
require 'liquid/parser_switching'
require 'liquid/tag'
require 'liquid/block'
require 'jekyll'
require 'jekyll/filters'
require 'jekyll/static_file'
require 'shi/tools'

require_relative 'version'

class Shi::Jekyll::ImageTag < Liquid::Tag
  include Shi::Tools

  class << self
    def list
      @list ||= []
      @list
    end
  end

  def process source, place, width, height, webp, thumb, need_fig
    if source.nil?
      raise ArgumentError, 'Image source cannot be nil!'
    end
    #tmb =
    #
    nil
  end

  private :process

  def render context
    args = Shi::Args::Params::parse(context, @markup)

    source = args[:src] || args[:source]
    if source == nil
      s0 = args[0]
      if Jekyll::StaticFile === s0
        source = s0
      end
    end

    place = args[:place]
    cls = args[:class]
    style = args[:style]
    alt = args[:alt]
    title = args[:title]
    link = args[:link]
    width = args[:width]
    height = args[:height]
    shape = args[:shape]
    webp = args[:webp]
    thumb = args[:thumb]

    alt ||= title

    extra = context['current_figure']
    extra_place = nil
    if extra
      cls ||= extra[:class]
      style ||= extra[:style]
      shape ||= extra[:shape]
      width ||= extra[:width]
      height ||= extra[:height]
      link = extra[:link] if link == nil
      webp = extra[:webp] if webp == nil
      thumb = extra[:thumb] if thumb == nil
      extra_place = extra[:place]
    end

    if extra_place == nil && place == nil
      place = :center
    end
    default_width = Shi::Args::Value::Measure::px(320)
    if place == :center || extra_place == :center
      default_width = Shi::Args::Value::Measure::px(600)
    end

    webp = coalesce(webp, lookup_with(context, 'webp', 'page', 'layout', 'site.images'), true)
    thumb = coalesce(thumb, lookup_with(context, 'thumb', 'page', 'layout','site.images'), true)
    width = coalesce(width, lookup_with(context, 'default_width', 'page', 'layout', 'site.images'), default_width)
    height = coalesce(height, lookup_with(context, 'default_height', 'page', 'layout', 'site.images'))

    process source, place, width, height, webp, thumb, extra.nil?
  end
end

Liquid::Template.register_tag 'image', Shi::Jekyll::ImageTag
