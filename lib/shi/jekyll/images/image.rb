# encoding: utf-8

require_relative 'version'

class Shi::Jekyll::ImageTag < Liquid::Tag
end

Liquid::Template.register_tag 'image', Shi::Jekyll::ImageTag
