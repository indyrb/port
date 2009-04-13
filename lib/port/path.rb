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
      polygon.points << window.mouse_position
      if game.in_landing_zone?(window.mouse_position)
        self.active = false
        self.highlighted = true
      end
    elsif active
      self.active = false
      game.active_path = nil
    end
  end

  def draw
    previous_x = previous_y = nil
    segment_size = 10.0
    window.draw_polygon(polygon, color, z_order, :dashed => true, :thickness => 2)
  end

  def move_along(start, distance)
    new_position = polygon.follow_and_remove(start, distance)
    if !active && polygon.empty?
      destroy
    end
    new_position
  end
  
  def color
    (highlighted) ? 0x8800ff00 : 0x88ffffff
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

