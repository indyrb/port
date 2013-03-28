class StealthBomber < Vehicle
  score 3
  sprite_options :file => 'stealth_bomber'

  def self.terminal_velocity
    30
  end

end
