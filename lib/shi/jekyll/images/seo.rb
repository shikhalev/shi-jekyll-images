# frozen_string_literal: true

require_relative 'version'
require_relative 'config'
require_relative 'files'

module Shi::Jekyll::Images::SEO
  class << self
    include Shi::Jekyll::Images::Config

    def file_by_path path
      path_with_leading_slash = Jekyll::PathManager::join '', path
      site.static_files.find { |f| f.relative_path == path || f.relative_path == path_with_leading_slash }
    end

    def process_page page
      image = page.data['image']
      if image
        file = file_by_path image
        if file
          bounds = get_value(page, 'seo_image_bounds') || '640x640'
          crop = get_value(page, 'seo_image_crop') || '500:261+0+0'
          result = Shi::Jekyll::Images::File::create page, file, bounds, crop
          page.data['image'] = result.url
        end
      end
    end

    private :file_by_path
  end
end

Jekyll::Hooks::register :pages, :pre_render do |page, *args|
  Shi::Jekyll::Images::SEO::process_page page
end

Jekyll::Hooks::register :documents, :pre_render do |page, *args|
  Shi::Jekyll::Images::SEO::process_page page
end
