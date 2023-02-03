# frozen_string_literal: true

class Path < Sprite
  z_order 3

  attr_accessor :polygon, :active, :vehicle, :landing_strip

  def initialize(game, position, vehicle)
    self.active = true
    self.polygon = Polygon.new([position], closed: false)
    self.vehicle = vehicle
    vehicle.path = self
    super(game, position)
  end

  def update(_diff, _diff_fractional)
    if active && window.button_down?(Gosu::Button::MsLeft)
      polygon.points << window.mouse_position
      if landing_strip = game.in_landing_zone?(polygon.points.last(2))
        self.landing_strip = landing_strip
        add_landing
        finish
      end
    elsif active
      finish
    end
  end

  def add_landing
    polygon.points << landing_strip.landing_point
    polygon.points << landing_strip.landing_point + Vector.angle(landing_strip.angle) * 25
  end

  def finish
    self.active = false
    game.active_path = nil
    smooth
  end

  def smooth
    steps = (polygon.length / 5).to_f.ceil
    self.polygon = polygon.interpolate(steps, 10).interpolate(steps, 20)
  end

  def draw
    window.draw_polygon(polygon, color, z_order, dashed: active, thickness: 3)
  end

  def move_along(start, distance)
    new_position = polygon.follow_and_remove(start, distance)
    if !active && polygon.empty?
      if landing_strip
        vehicle.land
      else
        destroy
      end
    end
    new_position
  end

  def color
    landing_strip ? 0x8800ff00 : 0x88000000
  end

  def contains?(_check_x, _check_y)
    false
  end

  def destroy
    vehicle.path = nil
    super
  end

  def collided?(_sprite)
    false
  end

  private

  def lerp(a, b, p, t)
    t.clamp(0, p) * (b - a) / p + a
  end

end
