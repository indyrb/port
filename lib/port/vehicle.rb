class Vehicle < Sprite
  attr_accessor :path
  
  score 1
  z_order 10

  class << self

    def terminal_velocity()
      Vector[20, 20]
    end
    
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

  def is_heading_to_point?
    !!@heading
  end

  def velocity=(v)
    @velocity = v
  end

  def velocity
    @velocity || Vector[0,0]
  end


  def update(ts, ms)
    return score_and_destroy if landed?
    update_physics(ts, ms)
    if path && (new_location = path.move_along(self.x, self.y, ts * 0.3))
      self.heading = Vector[*new_location]
    end
  end

  def landed?
    window.field.in_landing_zone?(x, y)
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
