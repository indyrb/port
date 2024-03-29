# frozen_string_literal: true

class Assets
  attr_accessor :window

  def initialize(window)
    self.window = window
    preload
  end

  def self.asset_dirs
    @asset_directories ||= add_asset_dir(File.join(APP_ROOT, "images"))
  end

  def self.add_asset_dir(dir)
    @asset_directories ||= []
    @asset_directories << dir
  end

  def preload
    @assets ||= {}
    Dir.glob(File.join(self.class.asset_dirs, "*.png")).each do |file|
      if !File.directory?(file)
        @assets[File.basename(file).gsub(File.extname(file), "")] = Gosu::Image.new(file)
      end
    end
  end

  def list
    @assets
  end

  def by_name(name)
    @assets[name] || raise("Could not find image #{name.inspect}")
  end
end
