class Jet < Vehicle
  score 1
  sprite_options :file => 'black'

  def self.terminal_velocity
    30
  end
  
end
