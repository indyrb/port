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
    position = Vector[self.x, self.y]
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
    if proximity_alert
      game.draw_circle(x, y, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
      game.draw_circle(x - 1, y, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
      game.draw_circle(x, y - 1, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
      game.draw_circle(x - 1, y - 1, 1.1 * width / 2.0, Game::Colors::Proximity, 50)
    end
    
    if path && path.active
      game.draw_circle(x, y, 1.1 * width / 2.0, Game::Colors::Selection, 50)
    end
    sprite.draw_rot(x-scale*10, y-scale*10, z_order, angle, 0.5, 0.5, scale * 0.7, scale * 0.7, 0x88000000) #, 0.5, 0.5, 1, 1, 0xffffff)
    super
  end

  def update(ts, ms)
    proximity_check
    add_exhaust(x, y) if rand(10) > 6
    if entered
      if x > window.width || x < 0
        self.heading = Vector[x, y] + Vector[-velocity.x, velocity.y] * 5
      elsif y > window.height || y < 0
        self.heading = Vector[x, y] + Vector[velocity.x, -velocity.y] * 5
      end
    else
      if x > width / 2 && x < window.width - height / 2 &&
          y > width / 2 && y < window.height - height / 2
        
        self.entered = true
      end
    end
    
    update_physics(ts, ms)
    if path && (new_location = path.move_along(self.x, self.y, ts * 0.3))
      self.heading = Vector[*new_location]
    end
  end
  
  def add_exhaust(x, y)
    if game.exhaust
      game.objects << Smoke.new(game, x, y, velocity * -1)
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

  def update_physics(ts, ms)
    v = self.velocity * ms
    self.x += v.x
    self.y += v.y
  end

  # I removed the interpolation code
  # because
  # I HATE BABIES

end
