class Smoke < MovingSprite
  attr_accessor :life

  MaxLife = 150
  z_order 9
  sprite_options :file => 'cloud'

  def initialize(game, position, velocity)
    super(game, position)
    self.velocity = velocity / 2000
    self.velocity.x += rand * 0.03
    self.velocity.y += rand * 0.03
    self.life = MaxLife
  end

  def update(diff, diff_fractional)
    self.life -= 1
    destroy if life < 0

    self.velocity = velocity * 0.95
    self.angular_velocity = 0.4 + rand / 10

    super
  end

  def life_percent
    life.to_f / MaxLife
  end

  def scale
    1 / (life_percent * 2.5 + 0.7)
  end

  def color
    Gosu::Color.new((50 * life_percent).to_i, 255, 255, 255)
  end
end
