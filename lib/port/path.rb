class Path < Sprite
  z_order 3
  
  attr_accessor :polygon, :active, :vehicle, :highlighted
  
  def initialize(game, position, vehicle)
    self.active = true
    self.polygon = Polygon.new([position], :closed => false)
    self.vehicle = vehicle
    vehicle.path = self
    super(game, position)
  end
  
  def update(diff, diff_fractional)
    if active && window.button_down?(Gosu::Button::MsLeft)
      polygon.points << constrained_position
      if game.in_landing_zone?(constrained_position)
        self.active = false
        self.highlighted = true
      end
    elsif active
      self.active = false
      game.active_path = nil
    end
  end
  
  def constrained_position
    Vector[constrained_x, constrained_y]
  end
  
  def constrained_x
    if window.mouse_x > window.width
      window.width
    elsif window.mouse_x < 1
      1
    else
      window.mouse_x
    end
  end
  
  def constrained_y
    if window.mouse_y > window.height
      window.height
    elsif window.mouse_y < 1
      1
    else
      window.mouse_y
    end
  end

  def draw
    previous_x = previous_y = nil
    segment_size = 10.0
    polygon.points.each do |point|
      x, y = point.to_a
      if previous_x
        iters = (Gosu.distance(previous_x, previous_y, x, y) / segment_size).ceil
        lpx, lpy = previous_x, previous_y
        1.upto(iters) do |seg|
          if (seg % 2) != 0
            lx, ly = lerp(previous_x, x, iters, seg), lerp(previous_y, y, iters, seg)
            window.line(Vector[lpx, lpy], Vector[lx, ly], color, z_order, :thickness => 1)
            lpx, lpy = lx, ly
          end
        end
      end
      previous_x, previous_y = x, y
    end
  end

  def move_along(start, distance)
    new_position = polygon.follow_and_remove(start, distance)
    if !active && polygon.empty?
      destroy
    end
    new_position
  end
  
  def color
    (highlighted) ? 0x88FF0000 : 0x88ffffff
  end
  
  def contains?(check_x, check_y)
    false
  end
  
  def destroy
    vehicle.path = nil
    super
  end

  def collided?(sprite)
    false
  end
  
  private

  def lerp(a, b, p, t)
    t.clamp(0, p) * (b - a) / p + a
  end
  
end

