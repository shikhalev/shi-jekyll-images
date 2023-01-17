# frozen_string_literal: true

require_relative 'version'
require_relative 'config'

module Shi::Jekyll::Images::File
  class << self
    def create page, source, bounds, crop
      type = File.extname source.relative_path
      if type.downcase == '.svg'
        Shi::Jekyll::Images::SVGFile::create page, source
      else
        Shi::Jekyll::Images::WebPFile::create page, source, bounds, crop
      end
    end
  end
end

class Shi::Jekyll::Images::WebPFile < Jekyll::StaticFile
  include Shi::Jekyll::Images::Config

  class << self
    include Shi::Jekyll::Images::Config

    def name_by_source source, bounds, crop
      result = source.basename
      result += "-#{bounds}" if bounds && !['SOURCE', 'ORIGINAL', 'ORIGIN', 'NONE'].include?(bounds.upcase)
      result += "-#{Jekyll::Utils::slugify(crop)}" if crop
      result += '.webp'
      result
    end

    def path page, source, bounds, crop
      Jekyll::PathManager::join path_by_page(page), name_by_source(source, bounds, crop)
    end

    def make_key source, bounds, crop
      result = source.relative_path
      result += "@#{bounds}" if bounds
      result += "@#{crop}" if crop
      Jekyll::PathManager::join '', result
    end

    def default_bounds page
      get_value(page, 'image_bounds') || 'ORIGINAL'
    end

    def create page, source, bounds, crop
      bounds ||= default_bounds(page)
      return source if source.write? && (['SOURCE', 'ORIGINAL', 'ORIGIN', 'NONE'].include?(bounds.upcase)) && crop.nil?

      @@created ||= {}
      key = make_key source, bounds, crop
      result = @@created[key]
      if result == nil
        result = new path(page, source, bounds, crop), source, bounds, crop
        @@created[key] = result
      end
      if !site.static_files.include?(result)
        site.static_files << result
      end
      result
    end

    private :new
    private :name_by_source, :path, :make_key, :default_bounds
  end

  def initialize path, source, bounds, crop
    @wp_path = path
    @wp_source = source
    @wp_bounds = bounds
    @wp_crop = crop
    super site, site.source, File.dirname(path), File.basename(path)
  end

  def modified?
    true
  end

  def write?
    true
  end

  def cropping crop
    if crop
      "-crop '#{crop}' +repage -flatten"
    else
      ''
    end
  end

  def resizing bounds
    command = '-filter Lanczos2Sharp -resize'
    case bounds.upcase
    when 'HD', '720P'
      "#{command} '1280x720>'"
    when 'FULLHD', 'FHD', '1080P'
      "#{command} '1920x1080>'"
    when 'WYXGA', '1200P'
      "#{command} '1920x1200>'"
    when '2K', 'QUADHD', 'QHD', 'WQHD', '1440P'
      "#{command} '2560x1440>'"
    when '4K', 'ULTRAHD', 'UHD', '2160P'
      "#{command} '3840x2160>'"
    when '5K', '2880P'
      "#{command} '5120x2880>'"
    when '8K', '4320P'
      "#{command} '7680x4320>'"
    when 'SOURCE', 'ORIGINAL', 'ORIGIN', 'NONE'
      ''
    else
      "#{command} '#{bounds}>'"
    end
  end

  def qualiting
    '-strip -quality 80 -define webp:auto-filter=true'
  end

  def write dest
    tgt_path = destination dest
    src_path = File::join site.source, @wp_source.relative_path

    FileUtils::mkdir_p(File.dirname(tgt_path))
    FileUtils::rm(tgt_path) if File.exist?(tgt_path)
    cmd = "convert '#{src_path}' #{cropping(@wp_crop)} #{resizing(@wp_bounds)} #{qualiting} '#{tgt_path}'"
    system(cmd, exception: true)

    true
  end

  private :cropping, :resizing, :qualiting
end

class Shi::Jekyll::Images::SVGFile < Jekyll::StaticFile
  include Shi::Jekyll::Images::Config

  class << self
    include Shi::Jekyll::Images::Config

    def path page, source
      Jekyll::PathManager::join path_by_page(page), source.name
    end

    def make_key source
      Jekyll::PathManager::join '', source.relative_path
    end

    def create page, source
      return source if source.write?

      @@created ||= {}
      key = make_key source
      result = @@created[key]
      if result == nil
        result = new path(page, source), source
        @@created[key] = result
      end
      if !site.static_files.include?(result)
        site.static_files << result
      end
      result
    end

    private :new
    private :path, :make_key
  end

  def initialize path, source
    @wp_path = path
    @wp_source = source
    super site, site.source, File.dirname(path), File.basename(path)
  end

  def modified?
    true
  end

  def write?
    true
  end

  def write dest
    tgt_path = destination dest
    src_path = File::join site.source, @wp_source.relative_path

    FileUtils::mkdir_p(File.dirname(tgt_path))
    FileUtils::rm(tgt_path) if File.exist?(tgt_path)
    FileUtils::cp(src_path, tgt_path)

    true
  end
end
