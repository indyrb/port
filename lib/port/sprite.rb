class Sprite
  attr_accessor :x, :y, :image, :game, :window

  class << self
    def z_order(value = nil)
      if value
        @z_order = value
      end
      @z_order
    end
    
    def score(value = nil)
      if value
        @score = value
      end
      @score
    end

    def default_sprite_options
      { :tiles => -1 }
    end
    
    # assumes horizontal tiling
    def sprite_options(options)
      @sprite_options = default_sprite_options.merge(options)
    end
    
    def sprites(window)
      @sprites = Gosu::Image.load_tiles(window, 
        File.join(APP_ROOT, 'images', @sprite_options[:file]), @sprite_options[:tiles], -1, false)          
    end
  end
  
  def initialize(game, x, y)
    self.game = game
    self.window = game.window
    self.x = x
    self.y = y
  end
  
  def score
    self.class.score
  end

  def z_order
    self.class.z_order
  end

  def update(time)
  end
  
  def draw    
  end

  def destroy
    game.remove(self)    
  end

  def score_and_destroy
    game.score += self.class.score
    destroy
  end

  def sprite
    sprites.first
  end
  
  def sprites
    self.class.sprites(window)
  end
  
  def width
    sprite.width
  end
  
  def height
    sprite.height
  end
  
  def contains?(x, y)
    (x..(x + width * 2)).include?(x) && 
    (y..(y + height * 2)).include?(y)
  end

end