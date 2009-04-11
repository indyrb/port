class Window < Gosu::Window
  attr_accessor :images, :sound, :sounds, :game, :application, :cursor

  def initialize(application)
    super(480, 512, false)
    GosuExtras::setup_keyboard_constants(self)
        
    self.game = Game.new(self)
    self.sound = true
    self.application = application
    @cursor = Gosu::Image.new(self, File.join(File.dirname(__FILE__), '..', '..', 'images', 'cursor.png'))
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
    if sound && sounds[sound.to_s]
      sounds[sound.to_s].play
    end
  end
  
  def update
    game.update
  end

  def draw
    game.draw
    @cursor.draw(mouse_x, mouse_y, 0)
  end
  
  def cursor
    
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
