# encoding: utf-8

require_relative 'version'

require 'pp'
require 'shi/args'

class Shi::Jekyll::FigureBlock < Liquid::Block

  def initialize tag_name, markup, parse_context
    super tag_name, markup, parse_context
    @params = Shi::Args::parse markup
  end

  def render(context)
    text = super
    text.gsub!(/^\s*#\s*(.*?)$/, '<figcaption markdown="span">\1</figcaption>')

    pp @params
    puts '====='
    puts text
    text
  end

end

Liquid::Template.register_tag 'figure', Shi::Jekyll::FigureBlock
