# encoding: utf-8

require_relative 'version'

class Shi::Jekyll::ImageTag < Liquid::Tag

  def render(context)
    puts "image start"
    pp context['current_figure']
    nil
  end

end

Liquid::Template.register_tag 'image', Shi::Jekyll::ImageTag
