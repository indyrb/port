class Vehicle < Sprite
  
  score 1
  z_order 1

  class << self

    def max_acceleration()
      Vector[0.5, 0.5]
    end

    def terminal_velocity()
      Vector[0.5, 0.5]
    end
    
  end

  attr_accessor :heading

  def heading
    @heading || Vector[0, 0]
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
    update_physics(ts)
    time_until = (self.velocity.magnitude() / self.acceleration.magnitude())
    old_x = self.x
    old_y = self.y
    self.x = interpolate(self.x, self.heading.x, time_until, ts)
    self.y = interpolate(self.y, self.heading.y, time_until, ts)
    self.game.logger.info("Updating from #{old_x}, #{old_y} to #{self.x}, #{self.y}: V#{self.velocity} A#{self.acceleration}")
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


