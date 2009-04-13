class Sprite
  include Game::Constants
  
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

  def update(diff, diff_fractional)
  end
  
  def draw
    if game.debugging
      c = Game::Colors::Debug::Sprite
      window.draw_polygon(edge_points, Colors::Debug::Sprite::Outline, ZOrder::Debug::Sprite::Outline)
      window.draw_crosshairs(position, Colors::Debug::Sprite::Center, ZOrder::Debug::Sprite::Center)
    end
    sprite.draw_rot(position.x, position.y, z_order, angle, 0.5, 0.5, scale, scale, color)
  end
  
  def edge_points
    Polygon.new([
      Vector[position.x - width / 2, position.y - height / 2],
      Vector[position.x + width / 2, position.y - height / 2],
      Vector[position.x + width / 2, position.y + height / 2],
      Vector[position.x - width / 2, position.y + height / 2],
      ], :center => position, :closed => true).rotate_degrees(angle)
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
    position.distance_to(check_position) <= width
  end

  def collided?(sprite)
    if can_collide_with?(sprite)
      position.distance_to(sprite.position) <= (width/2) + (sprite.width/2)
    end
  end
  
  def clickable?
    false
  end
  
  def collidable?
    false
  end
  
  def can_collide_with?(sprite)
    self != sprite && collidable? && sprite.collidable?
  end

end
