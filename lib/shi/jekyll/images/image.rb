# frozen_string_literal: true

require_relative 'version'

class Shi::Jekyll::ImageTag < Liquid::Tag
  include Shi::Tools

  def render context
    nil # TODO: implement
  end
end

Liquid::Template.register_tag 'image', Shi::Jekyll::ImageTag
