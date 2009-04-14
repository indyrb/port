class Vehicle < Scorable
  attr_accessor :path, :entered, :proximity_alert, :landing_life

  score 1
  z_order 10

  class << self
    def terminal_velocity 
      Vector[20, 20]
    end
    
    def weighted_options
      {
        :bomber => 1,
        :fighter => 0.6,
        :old_fighter => 0.9,
        :space_shuttle => 0.2,
        :stealth_bomber => 0.3
      }
    end
  end

  def initialize(*args)
    super
    self.entered = false
    self.scale = 0.5
  end
  
  def new_path(mouse_position)
    path.destroy if path
    self.path = Path.new(game, mouse_position, self)
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
  
  def distance_to_edge
    x_distance = 
      if position.x < window.width / 2
        - position.x
      else
        position.x - window.width
      end

    y_distance = 
      if position.y < window.height / 2
        - position.y
      else
        position.y - window.height
      end

    [x_distance, y_distance].max
  end

  def draw
    if proximity_alert
      window.circle(position, 1.1 * width / 2.0, Game::Colors::Proximity, 50, :thickness => 2)
    end
    
    if path && path.active
      window.circle(position, 1.1 * width / 2.0, Game::Colors::Selection, 50, :thickness => 1)
    end
    sprite.draw_rot(position.x-scale*10, position.y-scale*10, z_order, angle, 0.5, 0.5, scale * 0.7, scale * 0.7, 0x88000000) #, 0.5, 0.5, 1, 1, 0xffffff)
    proximity_draw if game.debugging
    
    if (d = distance_to_edge) > 0
      window.circle(position, d ** 2 * 0.3, Game::Colors::NewVehicle, Game::ZOrder::IncomingVehicle, :thickness => 3)
    end
    super
  end

  def update(diff, diff_fractional)
    if landing_life
      self.landing_life -= 1
      destroy if landing_life <= 0
    end
    proximity_check
    add_exhaust(position) if rand(10) > 6
    if entered
      if position.x > window.width || position.x < 0
        self.heading = position + Vector[-velocity.x, velocity.y] * 5
      elsif position.y > window.height || position.y < 0
        self.heading = position + Vector[velocity.x, -velocity.y] * 5
      end
    else
      if position.x > width  && position.x < window.width - height &&
          position.y > width  && position.y < window.height - height
        
        self.entered = true
      end
    end
    
    update_physics(diff, diff_fractional)
    if path && (new_position = path.move_along(position, diff * 0.3))
      self.heading = new_position
    end
  end
  
  def add_exhaust(position)
    if game.exhaust
      game.objects << Smoke.new(game, position.dup, velocity * -1)
    end
  end
    
  def scale
    if landing_percent
      @scale * ((landing_percent.clamp(0.5, 100)) * 1.3 - 0.2)
    else
      @scale
    end
  end
  
  def destroy
    path.destroy if path
    super
  end

  def proximity_check
    initial_value = proximity_alert
    self.proximity_alert = false
    game.objects.each do |object|
      if within_collision_proximity_of?(object)
        self.proximity_alert = true
        object.proximity_alert = true
      end
    end
    window.play_sound(:proximity) if !initial_value && proximity_alert
  end

  def proximity_draw
    game.objects.each do |object|
      if within_collision_proximity_of?(object)
        window.draw_path([position, object.position], Game::Colors::Debug::Proximity, Game::ZOrder::Debug::Proximity)
      end
    end
  end
  
  def within_collision_proximity_of?(sprite)
    can_collide_with?(sprite) && position.distance_to(sprite.position) < 80
  end

  def land
    unless landing_life
      window.play_sound(:landing)
      add_score
      self.landing_life = 100.0
    end
  end
  
  def landing_percent
    if landing_life
      landing_life / 100.0
    end
  end

  def on_landing_approach?
    path && path.landing_strip
  end
  
  def clickable?
    true
  end
  
  def collidable?
    !landing_life
  end
  
  private

  def update_physics(diff, diff_fractional)
    v = 
      if landing_life
        self.velocity * diff_fractional * landing_percent
      else
        self.velocity * diff_fractional
      end
      
    position.x += v.x
    position.y += v.y
  end

  # I removed the interpolation code
  # because
  # I HATE BABIES

end
