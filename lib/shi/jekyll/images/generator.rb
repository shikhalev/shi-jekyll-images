# frozen_string_literal: true

require_relative 'version'
require_relative 'image'

class Shi::Jekyll::ImageGenerator < Jekyll::Generator
  safe true

  def generate site
    Shi::Jekyll::ImageTag::sources.each do |img|
      pp img
      pp `pwd`
    end
  end
end
