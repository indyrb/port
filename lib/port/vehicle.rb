class Vehicle < Scorable
  attr_accessor :path, :entered, :proximity_alert

  score 1
  z_order 10

  class << self
    def terminal_velocity 
      Vector[20, 20]
    end
  end

  def initialize(*args)
    self.entered = false
    super
  end
  
  def new_path(start_x, start_y)
    path.destroy if path
    self.path = Path.new(game, start_x, start_y, self)
  end
  
  def heading
    @heading || Vector[0, 0]
  end

  def heading=(v)
    @heading = v
    self.angle = position.angle_between_gosu(v)
    result = v - position
    self.velocity = result.unit * self.velocity.magnitude
  end

  def angle=(a)
    @angle =a
  end

  def velocity=(v)
    @velocity = v
  end

  def velocity
    @velocity || Vector[0,0]
  end

  def draw
    # if proximity_alert
    #   game.draw_circle(x, y, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
    #   game.draw_circle(x - 1, y, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
    #   game.draw_circle(x, y - 1, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
    #   game.draw_circle(x - 1, y - 1, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
    # end
    
    if path && path.active
      game.draw_circle(position.x, position.y, 1.1 * width / 2.0, Game::Colors::Selection, 50)
    end
    sprite.draw_rot(position.x-scale*10, position.y-scale*10, z_order, angle, 0.5, 0.5, scale * 0.7, scale * 0.7, 0x88000000) #, 0.5, 0.5, 1, 1, 0xffffff)
    super
  end

  def update(diff, diff_fractional)
    proximity_check
    add_exhaust(Vector[position.x, position.y]) if rand(10) > 6
    if entered
      if position.x > window.width || position.x < 0
        self.heading = Vector[position.x, position.y] + Vector[-velocity.x, velocity.y] * 5
      elsif position.y > window.height || position.y < 0
        self.heading = Vector[position.x, position.y] + Vector[velocity.x, -velocity.y] * 5
      end
    else
      if position.x > width / 2 && position.x < window.width - height / 2 &&
          position.y > width / 2 && position.y < window.height - height / 2
        
        self.entered = true
      end
    end
    
    update_physics(diff, diff_fractional)
    if path && (new_location = path.move_along(position.x, position.y, diff * 0.3))
      self.heading = Vector[*new_location]
    end
  end
  
  def add_exhaust(position)
    if game.exhaust
      game.objects << Smoke.new(game, position, velocity * -1)
    end
  end
    
  def destroy
    path.destroy if path
    super
  end

  def collided?(sprite)
    if sprite.is_a?(Vehicle)
      super
    end
  end
  
  def proximity_check
    initial_value = proximity_alert
    self.proximity_alert = false
    game.objects.each do |object|
      if object != self && object.is_a?(Vehicle) && distance_to(object) < 80
        self.proximity_alert = true
        object.proximity_alert = true
      end
    end
    window.play_sound(:proximity) if !initial_value && proximity_alert
  end

  def scale
    0.5
  end
  
  def land
    window.play_sound(:landing)
    score_and_destroy
  end
    
  private

  def update_physics(diff, diff_fractional)
    v = self.velocity * diff_fractional
    position.x += v.x
    position.y += v.y
  end

  # I removed the interpolation code
  # because
  # I HATE BABIES

end
