# frozen_string_literal: true

require_relative 'version'

class Shi::Jekyll::FigureBlock < Liquid::Block
  def render context
    nil # TODO: implement
  end
end

Liquid::Template.register_tag 'figure', Shi::Jekyll::FigureBlock
