class Sprite
  attr_accessor :x, :y, :image, :game, :window, :angle, :logger, :scale, :color

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
    self.scale = 1
    self.color = 0xffffffff
    self.logger = game.logger
    logger.debug "Added #{self.class} at #{x}, #{y}"
  end
  
  def z_order
    self.class.z_order
  end

  def update(time, ms)
  end
  
  def draw
    if game.debugging
      c = Game::Colors::Debug::Sprite
      window.draw_rect(x - width / 2 , y - height / 2, x + width / 2, y + width / 2, c, 100)
    end
    sprite.draw_rot(x, y, z_order, angle, 0.5, 0.5, scale, scale, color)
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
    (@width ||= sprite.width) * scale
  end
  
  def height
    (@height ||= sprite.height) * scale
  end
  
  def contains?(check_x, check_y)
    dist = Gosu.distance(x, y, check_x, check_y)
    (dist <= width)
  end

  def collided?(sprite)
    Gosu.distance(center_x, center_y, sprite.center_x, sprite.center_y) <= (width/2) + (sprite.width/2)
  end

end
