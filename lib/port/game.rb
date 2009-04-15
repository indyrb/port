class Game
  include Game::Constants
  
  module Direction
  end
  
  attr_accessor :score, :objects, :level, :logger, :window, :active_path, :fps_counter, :debugging, :extras

  def initialize(window)
    @start_time = nil
    @end_time = nil
    @score_text = Gosu::Font.new(window, Gosu::default_font_name, 20)
    @fps_text = Gosu::Font.new(window, Gosu::default_font_name, 15)
    @landing_strips = Array.new

    self.debugging = ENV['DEBUG'] || false
    self.extras = false
    self.window = window
    self.score = 0
    self.objects = []
    self.logger = Application.logger
    self.fps_counter = FpsCounter.new

    reset_landing_strips
    add_vehicle
  end
  
  def add_landing_strip
    obj = LandingStrip.new(self, rand(window.width - 100) + 50, rand(window.height - 100) + 50,
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
    type ||= Vehicle.weighted_options.choose_weighted.to_s.classify.constantize

    position = Vector[rand(window.width - 100) + 50, rand(window.height - 100) + 50]
    obj = type.new(self, position)
    case(rand(4).to_i)
    when 0
      velocity = Vector.angle(90 + rand(90) - 45) * type.terminal_velocity
      position.y = -20
    when 1
      velocity = Vector.angle(180 + rand(90) - 45) * type.terminal_velocity
      position.x = window.width + 20
    when 2
      velocity = Vector.angle(270 + rand(90) - 45) * type.terminal_velocity
      position.y = window.height + 20
    when 3
      velocity = Vector.angle(0 + rand(90) - 45) * type.terminal_velocity
      position.x = -20
    end
    obj.velocity = velocity
    obj.angle = velocity.angle_between(Vector[-velocity.x, -velocity.y]) - 180
    objects << obj
  end
  
  def add_path(target)
    self.active_path = target.new_path(window.mouse_position)
    objects << active_path
  end

  def start
    @start_time = Time.now.to_i
    @pause = false
  end

  def pause
    @last = nil
    @paused = !@paused
  end

  def stop
    @end_time = Time.now
  end

  def paused?
    @paused
  end

  def mouse_down(button, position)
    if in_play?
      object = find_object(position, :clickable?)

      if object
        logger.debug("Selected #{object.object_id}")
        add_path(object)
      end
    end
  end

  def mouse_up(button, position)
  end

  def in_play?
    !(@paused || @end_time)
  end

  def find_object(position, selection_method)
    objects.detect do |object|
      object.send(selection_method) && object.contains?(position)
    end
  end
  
  def update
    diff = diff_fractional = nil

    if @last.nil?
      @last = Gosu.milliseconds
      return
    else
      ts ||= Gosu.milliseconds
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
      e.update(diff, diff_fractional)
      
      objects.each do |o|
        if o.collided?(e)
          window.play_sound("crash#{1 + rand(3)}")
          o.destroy
          e.destroy
          logger.debug("Crash #{o.position} and #{e.position}")
          # Game over, mother fucker.
        end
      end
    end
    
    window.field.update(diff, diff_fractional)
  end

  def in_landing_zone?(points)
    if points.size == 2
      @landing_strips.detect do |ls|
        Gosu.angle_diff(ls.angle - 180, points.first.angle_between(points.last)).abs < 30 &&
        points.all? do |point|
          ls.contains?(point)
        end
      end
    end
  end

  def draw
    @landing_strips.each(&:draw)

    objects.each do |e|
      e.draw
    end

    @score_text.draw("Score: #{self.score}", (window.width - 75), 10, ZOrder::Score, 1.0, 1.0, Colors::Score)
    @fps_text.draw("FPS: #{self.fps_counter.fps}", (window.width - 60), (window.height - 20), ZOrder::FPS, 1.0, 1.0, Colors::FPS)
  end
  
  def remove(*objs)
    objs.flatten.each do |o|
      self.objects.delete(o)
    end
  end

  def exhaust
    extras
  end
  
  def clouds
    extras
  end
  
  protected

  def deg2rad(deg)
    deg * Math::PI / 180.0
  end

end

