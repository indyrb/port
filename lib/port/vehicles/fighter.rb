class Fighter < Vehicle
  score 2
  sprite_options :file => 'cyan'

  def self.terminal_velocity
    45
  end

end
