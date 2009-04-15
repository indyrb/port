class LandingStrip
  include Game::Constants

  attr_accessor :landing_point

  class Sprite < ::Sprite
    z_order 1
    sprite_options :file => 'landing_strip'
  end

  def initialize(game, cx, cy, angle)
    @game = game
    @sprite = Sprite.new(game, Vector[cx, cy], angle)
    off_x = Gosu.offset_x(angle, height / 2)
    off_y = Gosu.offset_y(angle, height / 2)
    @starting = Vector[cx - off_x, cy - off_y]
    @ending = Vector[cx + off_x, cy + off_y]

    self.landing_point = @sprite.position - Vector.angle(angle) * (height / 2 - width / 2)
  end

  def angle
    @sprite.angle
  end

  def width
    @sprite.width
  end

  def height
    @sprite.height
  end

  def draw
    if @game.debugging
      @sprite.window.circle(landing_point, width / 2, Colors::Debug::LandingStrip, ZOrder::Debug::LandingStrip, :thickness => 1)
    end
    @sprite.draw
  end

  def update(ts, millis)
  end

  def contains?(position)
    landing_point.distance_to(position) < width / 2
  end
end
