# frozen_string_literal: true

module Shi::Jekyll::Images::Config
  def site_config
    @@site_config ||= Jekyll::configuration || {}
    @@site_config
  end

  def config
    @@config ||= Jekyll::configuration['shi_images'] || {}
    @@config
  end

  def get_value page, name
    result = page.data[name]
    if result == nil
      layout_name = page.data['layout']
      if layout_name
        layout_object = site.layouts[page.data['layout']]
        if layout_object
          result = layout_object.data[name]
        end
      end
    end
    if result == nil
      result = config[name]
    end
    result
end

  def site
    Jekyll::sites.first
  end

  def path_by_page page
    target_root = config['target_root'] || 'img'
    result = target_root
    by_url = true
    if page.respond_to?(:date) && page.date != nil
      result = Jekyll::PathManager::join result, page.date.strftime('%Y/%m/%d')
      by_url = false
    end
    if page.respond_to?(:slug) && page.slug != nil
      result = Jekyll::PathManager::join result, page.slug
      by_url = false
    end
    if by_url
      if page.respond_to?(:url) && page.url != nil
        result = Jekyll::PathManager::join result, page.url
      else
        raise ArgumentError, "Invalid Page object: #{page.inspect}"
      end
    end
    result
  end
end
