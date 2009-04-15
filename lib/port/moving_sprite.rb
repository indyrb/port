class MovingSprite < Sprite
  attr_accessor :velocity, :angular_velocity
  
  def initialize(game, position)
    super(game, position)
    self.velocity = Vector[0, 0]
    self.angle = 0
    self.angular_velocity = 0
  end
  
  def update(diff, diff_fractional)
    position.x += velocity.x
    position.x += velocity.x
    self.angle += angular_velocity
  end

end
