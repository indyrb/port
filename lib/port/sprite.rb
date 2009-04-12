class Sprite
  attr_accessor :window, :game, :logger
  attr_accessor :position, :angle, :scale, :color

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
  
  def initialize(game, position, angle = 0)
    self.game = game
    self.window = game.window
    self.logger = game.logger
    
    self.position = position
    self.angle = angle
    self.scale = 1
    self.color = 0xffffffff
    logger.debug "Added #{self.class} at #{position}"
  end
  
  def z_order
    self.class.z_order
  end

  def update(time, ms)
  end
  
  def draw
    if game.debugging
      c = Game::Colors::Debug::Sprite
      window.draw_rect(position.x - width / 2 , position.y - height / 2, position.x + width / 2, position.y + width / 2, c, 100)
      window.draw_crosshairs(position.x, position.y, c, 100)
    end
    sprite.draw_rot(position.x, position.y, z_order, angle, 0.5, 0.5, scale, scale, color)
  end
  
  def destroy
    game.remove(self)    
  end

  def sprite
    self.class.sprite(window)
  end

  def width
    (@width ||= sprite.width) * scale
  end
  
  def height
    (@height ||= sprite.height) * scale
  end
  
  def contains?(check_position)
    dist = Gosu.distance(position.x, position.y, check_position.x, check_position.y)
    (dist <= width)
  end

  def collided?(sprite)
    distance_to(sprite) <= (width/2) + (sprite.width/2)
  end
  
  def distance_to(sprite)
    Gosu.distance(position.x, position.y, sprite.position.x, sprite.position.x)
  end

end
