# frozen_string_literal: true

class SpaceShuttle < Vehicle
  score 2
  sprite_options :file => "space_shuttle"

  def self.terminal_velocity
    200
  end

end
