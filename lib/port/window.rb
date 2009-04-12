class Window < Gosu::Window
  attr_accessor :images, :sound, :sounds, :game, :application, :cursor, :assets, :field

  def initialize(application, options = {})
    options = { :width => 480, :height => 512, :fullscreen => false, :sound => true }.merge(options)
    super(options[:width], options[:height], options[:fullscreen], 0)
    GosuExtras::setup_keyboard_constants(self)
        
    self.sound = options[:sound]
    self.application = application
    self.assets = Assets.new(self)
    self.cursor = assets.by_name('cursor')
    self.game = Game.new(self)
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

  def button_up(id)
    unless handle_raw_button_up(id)
      handle_raw_button_up(button_id_to_char(id))
    end
  end

  def logger
    game.logger
  end
  
  def draw_rect(x1, y1, x2, y2, c, z)
    draw_line(x1, y1, c, x2, y1, c, z)
    draw_line(x2, y1, c, x2, y2, c, z)
    draw_line(x2, y2, c, x1, y2, c, z)
    draw_line(x1, y2, c, x1, y1, c, z)
  end

  def draw_crosshairs(x, y, c, z)
    draw_line(x, 0, c, x, height, c, z)
    draw_line(0, y, c, width, y, c, z)
  end
  
  protected

  def handle_raw_button_down(id)

    case id
    when Gosu::Button::KbEscape
      close
    when Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight
      game.mouse_down(id, self.mouse_x, self.mouse_y)
    else
      return false
    end

    return true
  end

  def handle_raw_button_up(id)
    case id
    when Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight
      game.mouse_up(id, self.mouse_x, self.mouse_y)
    end
  end

  def handle_char_button_down(c)
    case c
    when 's'
      self.sound = !sound
    when 'd'
      game.debugging = !game.debugging
    when 'v'
      game.add_vehicle(Vehicle.subclasses.rand.constantize)
    when 'p'
      game.pause
    when 'l'
      game.reset_landing_strips
    when 'k'
      game.add_landing_strip
    else
      return false
    end

    return true
  end

  def handle_char_button_up(c)
    false
  end

end
