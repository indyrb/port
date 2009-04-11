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
    
    def sprite(window)
      @sprite ||= window.assets.by_name(sprite_options[:file])
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
    self.class.sprite(window)
  end

  def center_x
    x + width.to_f / 2
  end
  
  def center_y
    y + height.to_f / 2
  end
  
  def width
    @width ||= sprite.width
  end
  
  def height
    @height ||= sprite.height
  end
  
  def contains?(check_x, check_y)
    dist = Gosu.distance(x, y, check_x, check_y)
    (dist <= width)
  end

  def collided?(sprite)
    Gosu.distance(center_x, center_y, sprite.center_x, sprite.center_y) <= (width/2) + (sprite.width/2)
  end

end
