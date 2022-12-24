# encoding: utf-8

require_relative 'version'

require 'forwardable'
require 'liquid/file_system'
require 'liquid/template'
require 'liquid/parser_switching'
require 'liquid/tag'
require 'liquid/block'
require 'jekyll'
require 'jekyll/filters'
require 'jekyll/static_file'

class Shi::Jekyll::ImageTag < Liquid::Tag
  def render context
    args = Shi::Args::Params::parse(context, @markup)

    source = args[:src]
    if source == nil
      s0 = args[0]
      if Jekyll::StaticFile === s0
        source = s0
      end
    end

    puts 'image start'
    pp context['current_figure']
    nil
  end
end

Liquid::Template.register_tag 'image', Shi::Jekyll::ImageTag
