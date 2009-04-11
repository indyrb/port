class Window < Gosu::Window
  attr_accessor :images, :sound, :sounds, :game, :application, :cursor, :assets, :field

  def initialize(application)
    super(480, 512, false, 0)
    GosuExtras::setup_keyboard_constants(self)
        
    self.game = Game.new(self)
    self.sound = true
    self.application = application
    self.assets = Assets.new(self)
    self.cursor = assets.by_name('cursor')
    self.field = Field.new(self)
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
    cursor.draw(mouse_x - 13, mouse_y - 4, 10)
    field.draw
  end
  
  def button_down(id)
    unless handle_raw_button_down(id)
      handle_char_button_down(button_id_to_char(id))
    end
  end

  def logger
    game.logger
  end

  protected

  def handle_raw_button_down(id)
    case id
    when Gosu::Button::KbEscape
      close
    when Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight
      game.mouse_down(:left, self.mouse_x, self.mouse_y)
    else
      return false
    end

    return true
  end

  def handle_char_button_down(c)
    case c
    when 's'
      self.sound = !sound
    when 'd'
      game.debugging = !game.debugging
    when 'f'
      game.add_vehicle(Fighter)
    when 'v'
      game.add_vehicle(Submarine)
    when 'p'
      game.pause
    else
      return false
    end

    return true
  end

end
