class Window < Gosu::Window
  attr_accessor :images, :sound, :sounds, :game, :application, :cursor, :assets, :field, :loops, :messages, :message_font

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

    self.messages = []
    self.message_font = Gosu::Font.new(self, Gosu::default_font_name, 30)
  end

  def sounds
    unless @sounds
      self.sounds = {}
      Dir.glob(File.join(APP_ROOT, 'sounds', '*')).each do |file|
        self.sounds[File.basename(file, File.extname(file))] = Gosu::Sample.new(self, file)
      end
    end
    @sounds
  end

  def play_sound(sample_name)
    if sound && sounds[sample_name.to_s]
      sounds[sample_name.to_s].play
    end
  end

  def loops
    unless @loops
      self.loops = {}
      Dir.glob(File.join(APP_ROOT, 'loops', '*')).each do |file|
        self.loops[File.basename(file, File.extname(file))] = Gosu::Song.new(self, file)
      end
    end
    @loops
  end

  def choose_random_loop
    loops.values[rand(loops.size)]
  end

  def update
    game.update
  end

  def draw
    game.draw
    cursor.draw(mouse_x - 13, mouse_y - 4, 10)
    field.draw
    self.messages = messages.collect do |message, time|
      [message, time - 1]
    end
    messages.reject! { |m, t| t < 0 }
    messages.reverse.each_with_index do |message_and_time, index|
      message, time = message_and_time
      scale = time.to_f / 100
      message_font.draw_rel( message, width / 2, height - 20 * (index + 1), 100, 0.5, 0.5, scale, scale, Gosu::Color.new((time * 2.55).to_i, 255, 255, 255))
    end
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
      thickness = options[:thickness] || 1
      if thickness == 1
        draw_line(one.x, one.y, color, two.x, two.y, color, z_order)
      else
        right_angle = Vector.angle(one.angle_between(two) + 90) * (thickness / 2)
        polygon = Polygon.new([one + right_angle, two + right_angle, two - right_angle, one - right_angle], :closed => true)
        quad(polygon, color, z_order, options.except(:thickness))
      end
      if options[:highlight_points]
        circle(one, thickness * 2, 0xff00ffff, z_order)
        circle(two, thickness * 2, 0xff00ffff, z_order)
      end

    end
  end

  def quad(polygon, color, z_order, options = {})
    a, b, c, d = polygon.points
    draw_quad(
      a.x, a.y, color,
      b.x, b.y, color,
      d.x, d.y, color,  # reordered for solid drawing
      c.x, c.y, color,  # reordered for solid drawing
      z_order
    )
  end

  def circle(center, radius, color, z_order, options = {})
    steps = options[:steps] || radius.ceil

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

  def center
    Vector[width / 2, height / 2]
  end

  def alert(message, time = 100)
    messages << [message, time]
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
    when 'm' # mute all
      self.sound = !sound unless game.sfx_muted?
      game.mute
      alert("mute #{game.muted? ? 'on' : 'off'}")
    when 'b' # background music
      game.mute_music
      alert("music #{game.music_muted? ? 'off' : 'on'}")
    when 's' # sound effects
      self.sound = !sound unless game.muted?
      game.mute_sfx
      alert("sound effects #{game.sfx_muted? ? 'off' : 'on'}")
    when 'd'
      game.debugging = !game.debugging
      alert("debug mode #{game.debugging ? 'on' : 'off'}")
    when 'v'
      game.add_vehicle
    when 'p'
      game.pause
      alert("#{game.paused? ? 'paused' : 'unpaused'}")
    when 'e'
      game.extras = !game.extras
      alert("extras #{game.extras ? 'on' : 'off'}")
    else
      return false
    end

    return true
  end

  def handle_char_button_up(c)
    false
  end

end
