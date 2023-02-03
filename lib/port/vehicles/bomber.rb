# frozen_string_literal: true

class Bomber < Vehicle
  score 1
  sprite_options file: "black"

  def self.terminal_velocity
    27
  end
end
