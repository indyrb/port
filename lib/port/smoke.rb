class Smoke < Sprite
  attr_accessor :velocity, :life
  MaxLife = 150
  z_order 9
  sprite_options :file => 'cloud'
  
  def initialize(game, x, y, velocity)
    super(game, x, y)
    self.velocity = velocity / 2000
    self.velocity.x += rand * 0.03
    self.velocity.y += rand * 0.03
    self.life = MaxLife
  end
  
  def update(ts, ts_frac)
    self.life -= 1
    destroy if life < 0
    
    self.angle += 0.4 + rand / 10
    self.x += velocity.x * (life_percent + 0.5)
    self.y += velocity.y * (life_percent + 0.5)
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
  
  def collided?(other)
    false
  end
end