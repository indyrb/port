class LandingStrip
  class Sprite < ::Sprite
    z_order 1
    sprite_options :file => 'landing_strip'
  end

  def initialize(game, cx, cy, angle)
    @game = game
    @sprite = Sprite.new(game, cx, cy, angle)
    off_x = Gosu.offset_x(angle, height / 2)
    off_y = Gosu.offset_y(angle, height / 2)
    @starting = Vector[cx - off_x, cy - off_y]
    @ending = Vector[cx + off_x, cy + off_y]
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
    @sprite.draw

    if @game.debugging
      @game.window.draw_line(@starting.x, @starting.y, 0xffff0000,
                             @ending.x, @ending.y, 0xff0000ff,
                             100)
    end
  end

  def update(ts, millis)
  end

  def contains?(x, y)
    hw = width / 2

    v = @starting - Vector[x, y]
    # v.y *= -1
    # v.x *= -1
    # ov = v.dup
    v = v.rotate_degrees(-angle)
    # ret = (-hw..hw).include?(v.x) && (0..height).include?(v.y)
    ret = Range.new(-hw, hw).include?(v.x) && Range.new(0.0, height).include?(v.y)

#     @game.logger.debug("Rotated #{ov} by #{angle} to #{v}")
#     @game.logger.debug("\tStarting: #{@starting}")
#     @game.logger.debug("\tTranslated: #{@starting - Vector[x, y]}")
#     @game.logger.debug("\tPoint: #{x}, #{y}")
#     @game.logger.debug("\tBounds: #{-hw}..#{hw}, #{0}..#{height}")
#     @game.logger.debug("#{x}, #{y} is landing") if ret

    ret
  end
end
