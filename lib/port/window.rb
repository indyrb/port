class Window < Gosu::Window
  attr_accessor :images, :sound, :sounds, :game, :application

  def initialize(application)
    super(480, 512, false)
    GosuExtras::setup_keyboard_constants(self)
        
    self.game = Game.new(self)
    self.sound = true
    self.application = application
  end
  
  def sounds
    unless @sounds
      self.sounds = {}
      Dir.glob(File.join(APP_ROOT, 'sounds', '*')).each do |file|
        self.sounds[File.basename(file, '.wav')] = Gosu::Sample.new(self, file)
      end
    end
    @sounds
  end

  def play_sound(sound)
    if sound && sounds[sound]
      sounds[sound].play
    end
  end
  
  def update
    if button_down?(Gosu::Button::MsLeft)

    end

    game.update
  end

  def draw
    game.draw
  end
  
  def button_down(id)
    case id
    when Gosu::Button::KbEscape
      close
    when Gosu::KbS
      self.sound = !sound
    when Gosu::KbV
      game.add_vehicle
    end
  end
end
