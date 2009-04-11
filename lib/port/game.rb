class Game
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
    add_vehicle
  end
  
  def add_vehicle(type = Submarine)
    obj = type.new(self, rand(window.width), rand(window.height))
    obj.velocity = Vector[0.1, 0.1]
    obj.acceleration = Vector[0.1, 0.1]
    objects << obj
  end
  
  def add_path(target)
    self.active_path = Path.new(self, window.mouse_x, window.mouse_y, target)
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
    object = find_object(x, y)

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
  
  def update(ts=nil)
    clear_landing_strip

    if !active_path && window.button_down?(Gosu::Button::MsLeft)
      if target = find_object(window.mouse_x, window.mouse_y)
        add_path(target)
      end
    end

    @last ||= 0
    ts ||= Gosu::milliseconds
    if in_play?
      diff = ts - @last
      @last = ts
      objects.each do |e|
        e.update(diff)
      end
    end
    self.fps_counter.register_tick
  end

  def clear_landing_strip
    objects.each do |object|
      remove(object) if object.respond_to?(:landed?) && object.landed?
    end
  end

  def draw
    objects.each do |e|
      e.draw
    end

    draw_debuggings if debugging

    @score_text.draw("Score: #{self.score}", (window.width - 75), 10, 1, 1.0, 1.0, 0xffffff00)
    @fps_text.draw("FPS: #{self.fps_counter.fps}", (window.width - 60), (window.height - 20), 1, 1.0, 1.0, 0xffffffff)
  end
  
  def remove(*objs)
    objs = objs.flatten
    @selection = nil if @selection && objs.include?(@selection)

    objs.each do |o|
      self.objects.delete(o)
    end
  end

  protected

  def draw_debuggings
    if @selection
      x = @selection.x - @selection.width / 2.0
      y = @selection.y - @selection.height / 2.0
      window.draw_quad(x, y, 0xffff0000,
                       x + @selection.width, y, 0xffff0000,
                       x, y + @selection.height, 0xffff0000,
                       x + @selection.width, y + @selection.height, 0xffff0000,
                       1)
    end
  end

end

