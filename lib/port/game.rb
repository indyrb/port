class Game
  attr_accessor :score, :objects, :level, :logger, :window, :active_path

  def initialize(window)
    @start_time = nil
    @end_time = nil
    @font = Gosu::Font.new(window, Gosu::default_font_name, 20)
    self.window = window
    self.score = 0
    self.objects = []
    self.logger = Application.logger
    add_vehicle
  end
  
  def add_vehicle(type = Submarine)
    @cheater = type.new(self, rand(window.width), rand(window.height))
    @cheater.velocity = Vector[0.1, 0.1]
    @cheater.acceleration = Vector[0.1, 0.1]
    objects << @cheater
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
    @cheater.heading = Vector[x, y]
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
    if @cheater.landed?
      remove(@cheater)
    end
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
  end

  def draw
    objects.each do |e|
      e.draw
    end
    @font.draw("Score: #{self.score}", (window.width - 75), 10, 1, 1.0, 1.0, 0xffffff00)
  end
  
  def remove(*objs)
    objs.flatten.each do |o|
      self.objects.delete(o)
    end
  end

end

