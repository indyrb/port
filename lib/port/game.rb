class Game
  module Colors
    Selection = 0xffff0000 # red
    Score = 0xffffffff     # white
    FPS = 0xffffff00       # yellow
  end

  attr_accessor :score, :objects, :level, :logger, :window, :active_path, :fps_counter, :debugging

  def initialize(window)
    @start_time = nil
    @end_time = nil
    @score_text = Gosu::Font.new(window, Gosu::default_font_name, 20)
    @fps_text = Gosu::Font.new(window, Gosu::default_font_name, 15)
    self.debugging = ENV['DEBUG'] || false
    self.window = window
    self.score = 0
    self.objects = []
    self.logger = Application.logger
    self.fps_counter = FpsCounter.new

    add_landing_strip
    add_vehicle
  end
  
  def add_landing_strip
#     obj = LandingStrip.new(self, rand * window.width, rand * window.height,
#                            rand * 360)
    obj = LandingStrip.new(self, window.width / 2, window.height / 2, 0)
    @landing_strip = obj
  end

  def reset_landing_strip
    logger.info("Resetting landing strip")
    @landing_strip = nil
    add_landing_strip
  end

  def add_vehicle(type = nil)
    type ||= [ Submarine, Fighter, Jet ].rand

    obj = type.new(self, rand(window.width), rand(window.height))
    case(rand(4).to_i)
    when 0
      vector = Vector[0, 40]
      obj.y = -30
    when 1
      vector = Vector[-40, 0]
      obj.x = window.width + 30
    when 2
      vector = Vector[0, -40]
      obj.y = window.height + 30
    when 3
      vector = Vector[40, 0]
      obj.x = -30
    end
    obj.velocity = vector
    obj.angle = vector.angle_between_gosu(Vector[-vector.x, -vector.y]) - 180
    objects << obj
  end
  
  def add_path(target)
    self.active_path = target.new_path(window.mouse_x, window.mouse_y)
    objects << active_path
  end

  def start
    @start_time = Time.now.to_i
    @pause = false
  end

  def pause
    @paused = !@paused
  end

  def stop
    @end_time = Time.now
  end

  def paused?
    @paused
  end

  def mouse_down(button, x, y)
    @landing_strip.contains?(x, y)
    object = find_vehicle(x, y)

    if object
      logger.debug("Selected #{object.object_id}")
      @selection = object
    elsif @selection
      @selection.heading = Vector[x, y]
    end
  end

  def in_play?
    !(@paused || @end_time)
  end

  def find_object(x, y)
    objects.detect do |object|
      object.contains?(x, y)
    end
  end

  def find_vehicle(x, y)
    obj = find_object(x, y)
    return obj if obj.kind_of?(Vehicle)
  end
  
  def update(ts=nil)
    diff = diff_fractional = nil

    if @last.nil?
      @last = Gosu::milliseconds
      return
    else
      ts ||= Gosu::milliseconds
      if in_play?
        diff = ts - @last
        @last = ts
        diff_fractional = diff / 1000.0
      end
    end

    if in_play?
      update_path
      update_objects(diff, diff_fractional)
    end

    ((score / 2) - objects.size).times do
      add_vehicle
    end

    self.fps_counter.register_tick
  end

  def update_path
    if !active_path && window.button_down?(Gosu::Button::MsLeft)
      if target = find_vehicle(window.mouse_x, window.mouse_y)
        add_path(target)
      end
    end
  end

  def update_objects(diff, fractional)
    objects.each do |e|
      if @landing_strip.contains?(e.x, e.y)
        land(e)
      else
        e.update(diff, fractional)
      end
    end
  end

  def land(obj)
    @score += obj.score if obj.respond_to?(:score)
    obj.destroy
  end

  def draw
    @landing_strip.draw

    objects.each do |e|
      e.draw
    end

    draw_selection
    draw_debuggings if debugging

    @score_text.draw("Score: #{self.score}", (window.width - 75), 10, 1, 1.0, 1.0, Colors::Score)
    @fps_text.draw("FPS: #{self.fps_counter.fps}", (window.width - 60), (window.height - 20), 1, 1.0, 1.0, Colors::FPS)
  end
  
  def remove(*objs)
    objs = objs.flatten
    @selection = nil if @selection && objs.include?(@selection)

    objs.each do |o|
      self.objects.delete(o)
    end
  end

  protected

  def draw_selection
    return unless @selection

    draw_circle(@selection.x, @selection.y, 1.1 * @selection.width / 2.0,
                Colors::Selection, 50)
  end

  def deg2rad(deg)
    deg * Math::PI / 180.0
  end

  def draw_debuggings
  end

  def draw_circle(cx, cy, radius, color, z = 0, steps = 20)
    zx = lx = cx + radius * Math.sin(0)
    zy = ly = cy + radius * Math.cos(0)

    steps.times do |step|
      angle = step * 2.0 * Math::PI / steps
      x = cx + radius * Math.sin(angle)
      y = cy + radius * Math.cos(angle)

      window.draw_line(lx, ly, color, x, y, color, z)

      lx, ly = x, y
    end

    # connect the end to the beginning
    window.draw_line(lx, ly, color, zx, zy, color, z)
  end

end

