class Vehicle < Sprite
  attr_accessor :path
  
  score 1
  z_order 10

  class << self

    def terminal_velocity()
      Vector[20, 20]
    end
    
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
    if path && path.active
      game.draw_circle(x, y, 1.1 * width / 2.0, Game::Colors::Selection, 50)
    end

    #sprite.draw_rot(x-10, y-10, z_order, angle, 0.5, 0.5, 0.7, 0.7, 0xffffffff, :additive) #, 0.5, 0.5, 1, 1, 0xffffff)
    super
  end

  def update(ts, ms)
    unless landed? 
      update_physics(ts, ms)
      if path && (new_location = path.move_along(self.x, self.y, ts * 0.3))
        self.heading = Vector[*new_location]
      end
    else
      score_and_destroy
    end
  end

  def landed?
    if path
      px, py = path.points.last
      window.field.in_landing_zone?(x, y) && window.field.in_landing_zone?(px, py)
    else
      false
    end

  end
    
  def destroy
    path.destroy if path
    super
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
