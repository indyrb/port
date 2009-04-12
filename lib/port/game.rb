class Game
  module Direction
    North = Vector[ 0, -1]
    East =  Vector[ 1,  0]
    South = Vector[ 0,  1]
    West =  Vector[-1,  0]
  end
  
  module Colors
    Selection = 0xffffffff # white
    Score = 0xffffffff     # white
    FPS = 0xffffff00       # yellow
    module Debug
      Sprite = 0xff00ff00
    end
  end

  attr_accessor :score, :objects, :level, :logger, :window, :active_path, :fps_counter, :debugging

  def initialize(window)
    @start_time = nil
    @end_time = nil
    @score_text = Gosu::Font.new(window, Gosu::default_font_name, 20)
    @fps_text = Gosu::Font.new(window, Gosu::default_font_name, 15)
    @landing_strips = Array.new

    self.debugging = ENV['DEBUG'] || false
    self.window = window
    self.score = 0
    self.objects = []
    self.logger = Application.logger
    self.fps_counter = FpsCounter.new

    @angle = 0.0

    reset_landing_strips
    add_vehicle
  end
  
  def add_landing_strip
    obj = LandingStrip.new(self, rand * window.width, rand * window.height,
                           rand * 360)
    # obj = LandingStrip.new(self, window.width / 2, window.height / 2, rand(360))
    @landing_strips << obj
  end

  def reset_landing_strips
    logger.info("Resetting landing strip")
    @landing_strips = Array.new
    add_landing_strip
    add_landing_strip
  end

  def add_vehicle(type = nil)
    type ||= Vehicle.subclasses.rand.constantize

    obj = type.new(self, rand(window.width - 100) + 50, rand(window.height - 100) + 50)
    case(rand(4).to_i)
    when 0
      vector = Direction::South * type.terminal_velocity
      obj.y = -20
    when 1
      vector = Direction::West * type.terminal_velocity
      obj.x = window.width + 20
    when 2
      vector = Direction::North * type.terminal_velocity
      obj.y = window.height + 20
    when 3
      vector = Direction::East * type.terminal_velocity
      obj.x = -20
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
    object = find_vehicle(x, y)

    if object
      logger.debug("Selected #{object.object_id}")
      add_path(object)
    end
  end

  def mouse_up(button, x, y)
  end

  def in_play?
    !(@paused || @end_time)
  end

  def find_object(x, y)
    objects.detect do |object|
      object.is_a?(Vehicle) && object.contains?(x, y)
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
      update_objects(diff, diff_fractional)
    end

    ((score / 2) - objects.size).times do
      add_vehicle
    end

    self.fps_counter.register_tick
  end

  def update_objects(diff, diff_fractional)
    objects.each_with_index do |e, i|
      if in_landing_zone?(e.x, e.y)
        land(e)
      else
        e.update(diff, diff_fractional)
        
        (objects[(i + 1)..-1] || []).each do |o|
          if o != e && o.collided?(e)
            window.play_sound('death')
            o.destroy
            e.destroy
            logger.debug("Destroyed #{o.center_x},#{o.center_y} and #{e.center_x},#{e.center_y}")
            # Game over, mother fucker.
          end
        end
      end
    end
    
    window.field.update
  end

  def in_landing_zone?(x, y)
    @landing_strips.any? { |ls| ls.contains?(x, y) }
  end

  def land(obj)
    @score += obj.score if obj.respond_to?(:score)
    obj.destroy
  end

  def draw
    @landing_strips.each(&:draw)

    objects.each do |e|
      e.draw
    end

    draw_debuggings if debugging

    @score_text.draw("Score: #{self.score}", (window.width - 75), 10, 1, 1.0, 1.0, Colors::Score)
    @fps_text.draw("FPS: #{self.fps_counter.fps}", (window.width - 60), (window.height - 20), 1, 1.0, 1.0, Colors::FPS)
  end
  
  def remove(*objs)
    objs.flatten.each do |o|
      self.objects.delete(o)
    end
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

  protected

  def deg2rad(deg)
    deg * Math::PI / 180.0
  end

  Steps = 20.0
  def draw_debuggings
    Steps.to_i.times do |xi|
      x = xi / Steps * window.width
      Steps.to_i.times do |yi|
        y = yi / Steps * window.height
        color = in_landing_zone?(x, y) ? 0x40ff0000 : 0x400000ff
        window.draw_quad(x, y, color,
                         x + Steps, y, color,
                         x, y + Steps, color,
                         x+Steps, y+Steps, color,
                         100)
      end
    end
  end


end

