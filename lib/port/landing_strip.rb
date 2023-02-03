# frozen_string_literal: true

class LandingStrip < Sprite
  include Game::Constants

  z_order 1
  sprite_options file: "landing_strip"

  attr_accessor :landing_point

  def initialize(game, position, angle)
    super

    self.landing_point = position - Vector.angle(angle) * (height / 2 - width / 2)
  end

  def draw
    if game.debugging
      window.circle(landing_point, width / 2, Colors::Debug::LandingStrip, ZOrder::Debug::LandingStrip, thickness: 1)
    end
    super
  end

  def contains?(position)
    landing_point.distance_to(position) < width / 2
  end
end
