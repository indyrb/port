
class Sprite
  attr_accessor :x, :y, :image, :game, :window, :angle, :logger

  class << self
    def z_order(value = nil)
      if value
        @z_order = value
      end
      @z_order || superclass.z_order if superclass.respond_to?(:z_order)
    end
    
    def default_sprite_options
      { :tiles => 1, :file => 'mushroom.png' }
    end
    
    def sprite_options(options = nil)
      if options
        @sprite_options = sprite_options.merge(options)
      else
        @sprite_options ||= default_sprite_options
      end
    end
    
    def sprites(window)
      # assumes horizontal tiling
      @sprites = Gosu::Image.load_tiles(window, 
        File.join(APP_ROOT, 'images', sprite_options[:file]), -sprite_options[:tiles], -1, false)          
    end
  end
  
  def initialize(game, x, y, angle = 0)
    self.game = game
    self.window = game.window
    self.x = x
    self.y = y
    self.angle = angle
    self.logger = game.logger
    logger.debug "Added #{self.class} at #{x}, #{y}"
  end
  
  def z_order
    self.class.z_order
  end

  def update(time, ms)
  end
  
  def draw
    sprite.draw_rot(x, y, z_order, angle)
  end

  def destroy
    game.remove(self)    
  end

  def sprite
    sprites.first
  end
  
  def sprites
    self.class.sprites(window)
  end
  
  def center_x
    x + width.to_f / 2
  end
  
  def center_y
    y + height.to_f / 2
  end
  
  def width
    sprite.width
  end
  
  def height
    sprite.height
  end
  
  def contains?(check_x, check_y)
    dist = Gosu.distance(x, y, check_x, check_y)
    (dist <= width)
  end

end
