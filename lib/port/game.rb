# frozen_string_literal: true

class Game
  include Game::Constants

  attr_reader :debugging, :paused, :music
  attr_accessor :score, :objects, :level, :logger, :window, :active_path, :fps_counter, :extras, :landing_strips

  def initialize(window, options = {})
    self.logger = options[:logger]
    self.debugging = ENV["DEBUG"] || false

    @end_time = nil
    @fps_text = Gosu::Font.new(window, Gosu::default_font_name, 15)
    @landing_strips = []

    self.extras = true
    self.window = window
    self.score = 0
    self.objects = []
    self.fps_counter = FpsCounter.new

    self.landing_strips = []
    add_landing_strips
    @score_display = Score.new(self)
    add_vehicle

    @music_player = window.choose_random_loop
    @music_player.volume = 0.3
    self.music = true
  end

  def add_landing_strips
    self.landing_strips << LandingStrip.new(self, window.center + Vector[-50, 0], -90)
    self.landing_strips << LandingStrip.new(self, window.center + Vector[30, 50], -135)
  end

  def add_vehicle(type = nil)
    type ||= Vehicle.weighted_options.choose_weighted

    position = Vector[rand(window.width - 100) + 50, rand(window.height - 100) + 50]
    obj = type.new(self, position)
    case(rand(4).to_i)
    when 0
      position.y = -20
    when 1
      position.x = window.width + 20
    when 2
      position.y = window.height + 20
    when 3
      position.x = -20
    end

    random_spread = 45.0
    obj.angle = position.angle_between(window.center) + rand(random_spread) - random_spread / 2

    obj.velocity = Vector.angle(obj.angle) * -obj.class.terminal_velocity
    objects << obj
  end

  def add_path(target)
    self.active_path = target.new_path(window.mouse_position)
    objects << active_path
  end

  def paused=(value)
    @last = nil
    @paused = value
    play_or_pause_music
  end

  def sound
    window.sound
  end

  def sound=(value)
    @window.sound = value
    play_or_pause_music
  end

  def music=(value)
    @music = value
    play_or_pause_music
  end

  def play_or_pause_music
    if !paused && music && sound
      @music_player.play
    else
      @music_player.pause
    end
  end

  def muted?
    @muted
  end

  def mouse_down(_button, position)
    if in_play?
      object = find_object(position, :clickable?)

      if object
        logger&.debug("Selected #{object.object_id}")
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

    if rand((215 - score).clamp(50, 200) + (vehicle_count * 2) ** 2) == 0
      add_vehicle
    end

    self.fps_counter.register_tick
  end

  def vehicle_count
    objects.count { |o| o.is_a?(Vehicle) }
  end

  def update_objects(diff, diff_fractional)
    objects.each do |e|
      e.update(diff, diff_fractional)

      objects.each do |o|
        if o.collided?(e)
          window.play_sound("crash#{1 + rand(3)}")
          o.destroy
          e.destroy
          logger&.debug("Crash #{o.position} and #{e.position}")
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

    @score_display.score = score
    @score_display.draw
    @fps_text.draw_text("FPS: #{fps_counter.fps}", (window.width - 60), (window.height - 20), ZOrder::FPS, 1.0, 1.0, Colors::FPS)
  end

  def remove(*objs)
    objs.flatten.each do |o|
      objects.delete(o)
    end
  end

  def exhaust
    extras
  end

  def clouds
    extras
  end

  def debugging=(value)
    if value
      logger&.level = :debug
    else
      logger&.level = :error
    end
    @debugging = value
  end
end
