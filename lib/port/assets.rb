class Assets

  def initialize(window)
    @window = window
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
    Dir.glob(File.join(self.class.asset_dirs, '*')).each do |file|
      if !File.directory?(file)
        @assets[File.basename(file).gsub(File.extname(file), '')] = Gosu::Image.new(@window, file)
      end
    end
  end

  def list
    @assets
  end

  def by_name(name)
    @assets[name]
  end

end
