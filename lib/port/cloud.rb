# frozen_string_literal: true

class Cloud < MovingSprite
  z_order 100
  sprite_options file: "cloud"

  def initialize(game, position)
    super
    restart(rand(window.width))
  end

  def restart(x = nil)
    self.scale = rand(4) + 2

    linear_max = 0.1
    linear_min = 0.003
    self.velocity = Vector[-rand(linear_max - linear_min) + linear_min, 0]

    angle_max = 0.1
    av = rand * angle_max - angle_max / 2
    self.angular_velocity = av/av.abs * angle_max

    self.angle = rand(360)
    position.x = x || window.width + width * scale
    self.color = Gosu::Color.new(255 / scale, 255, 255, 255)
  end

  def update(diff, diff_fractional)
    super
    if position.x + width < 0
      restart
    end
  end
end
