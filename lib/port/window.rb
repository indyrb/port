class Window < Gosu::Window
  attr_accessor :images, :sound, :sounds, :game, :application, :cursor, :assets, :field

  def initialize(application, options = {})
    options.reverse_merge!(:width => 550, :height => 400, :sound => true)
    super(options[:width], options[:height], !!options[:fullscreen], 0)
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
  
  def draw_crosshairs(point, c, z)
    line(Vector[point.x, 0], Vector[point.x, height], c, z)
    line(Vector[0, point.y], Vector[width, point.y], c, z)
  end

  def draw_polygon(polygon, color, z_order, options = {})
    draw_path(polygon.points, color, z_order, polygon.closed, options)
  end

  def draw_path(points, color, z_order, close = false, options = {})
    index = options[:index] || 0
    offset = options[:offset]
    last_point = points.first
    points.tail.each do |point|
      offset, index = line(last_point, point, color, z_order, options.merge(:offset => offset, :index => index))
      last_point = point
    end
    line(last_point, points.first, color, z_order, options.merge(:offset => offset, :index => index)) if close
  end
  
  def line(one, two, color, z_order, options = {})
    if options[:dashed]
      last = nil
      points, offset = one.distance_steps_to(two, 10, options[:offset] || 0)
      index = options[:index] || 0
      points.each do |position|
        if (index += 1) % 2 == 0 && last 
          line(last, position, color, z_order, options.except(:dashed))
        end
        
        last = position
      end
      [offset, index]
    else
      draw_line(one.x, one.y, color, two.x, two.y, color, z_order)
      (options[:thickness] || 0).times do |i|
        offset = i + 1
        draw_line(one.x - offset, one.y         , color, two.x - offset, two.y         , color, z_order)
        draw_line(one.x         , one.y + offset, color, two.x         , two.y + offset, color, z_order)
      end
    end
  end
  
  def circle(center, radius, color, z_order, options = {})
    steps = options[:steps] || 20
    
    zx = lx = center.x + radius * Math.sin(0)
    zy = ly = center.y + radius * Math.cos(0)

    steps.times do |step|
      angle = step * 2.0 * Math::PI / steps
      x = center.x + radius * Math.sin(angle)
      y = center.y + radius * Math.cos(angle)

      line(Vector[lx, ly], Vector[x, y], color, z_order, options)

      lx, ly = x, y
    end

    # connect the end to the beginning
    line(Vector[lx, ly], Vector[zx, zy], color, z_order, options)
  end
  
  def mouse_position
    Vector[mouse_x, mouse_y].clamp(Vector.origin, dimensions)
  end
  
  def dimensions
    Vector[width, height]
  end

  protected

  def handle_raw_button_down(id)

    case id
    when Gosu::Button::KbEscape
      close
    when Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight
      game.mouse_down(id, Vector[self.mouse_x, self.mouse_y])
    else
      return false
    end

    return true
  end

  def handle_raw_button_up(id)
    case id
    when Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight
      game.mouse_up(id, Vector[self.mouse_x, self.mouse_y])
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
    when 'e'
      game.extras = !game.extras
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
