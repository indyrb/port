class Vehicle < Sprite
  attr_accessor :path
  
  score 1
  z_order 10

  class << self

    def max_acceleration()
      Vector[5, 5]
    end

    def terminal_velocity()
      Vector[2, 2]
    end
    
  end


  def heading
    @heading || Vector[0, 0]
  end

  def heading=(v)
    @heading = v
    position = Vector[self.x, self.y]
    @time_until = position.distance_to(v) / self.velocity.magnitude()
    self.angle = position.angle_between_gosu(v)
  end

  def is_heading_to_point?
    !!@heading
  end

  def acceleration=(v)
    if v.magnitude > self.class.max_acceleration.magnitude
      @acceleration = self.class.max_acceleration.dup
    else
      @acceleration = v
    end
  end

  def acceleration
    @acceleration || Vector[0, 0]
  end

  def velocity=(v)
    if v.magnitude > self.class.terminal_velocity.magnitude
      @velocity = self.class.terminal_velocity.dup
    else
      @velocity = v
    end
  end

  def velocity
    @velocity || Vector[0,0]
  end

  def update(ts)
    if path && (new_location = path.move_along(ts * 0.3))
      self.x, self.y = new_location
    end

    # update_physics(ts)
    # 
    # if is_heading_to_point?
    #   self.x = interpolate(self.x, self.heading.x, @time_until, ts)
    #   self.y = interpolate(self.y, self.heading.y, @time_until, ts)
    # else
    #   self.x += self.velocity.x
    #   self.y += self.velocity.y
    # end
  end
  
  def landed?
    window.field.in_landing_zone?(x, y)
  end

  def destroy
    path.destroy if path
    super
  end

  private

  def update_physics(ts)
    
    @last_update ||= 0
    @last_update += ts
    if @last_update > 1000 # update physics every 1s
      self.velocity += self.acceleration        
      @last_update = 0
    end
  end

  # A is the initial position, at time 0
  # B is the target position, to reach at time P
  # t is the current time, in the range 0..P
  def interpolate(a, b, p, t)
    clamp(t, 0, p) * (b-a) / p + a
  end

  def clamp(val, lower, higher)
    if val < lower
      lower
    elsif val > higher
      higher
    else
      val
    end
  end
  
end


