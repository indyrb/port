class Game
  attr_accessor :score, :objects, :level, :logger, :window, :active_path

  def initialize(window)
    @start_time = nil
    @end_time = nil
    self.window = window
    self.score = 0
    self.objects = []
    
    announce_game
    watch_for_games
    add_vehicle
  end
  
  def hostname
    @hostname ||= `hostname`.chomp
  end
  
  def announce_game
    puts "Annoucing new game at #{hostname}"
    Easyjour.serve(hostname, 'port', 4815)
  end
  
  def watch_for_games
    Easyjour::Search.new('port') do |result|
      if !(result.target.sub(/\.$/, '') == hostname && result.port == 4815)
        puts "Discovered a game at #{result.target}:#{result.port}"
      end
    end
  end
  
  def add_vehicle
    objects << Submarine.new(self, rand(window.width), rand(window.height))
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

  def in_play?
    !(@paused || @end_time)
  end

  def find_object(x, y)
    objects.detect do |object|
      object.contains?(x, y)
    end
  end
  
  def update(ts=nil)
    if !active_path && window.button_down?(Gosu::Button::MsLeft)
      if target = find_object(window.mouse_x, window.mouse_y)
        add_path(target)
      end
    end
    
    ts ||= Gosu::milliseconds
    if in_play?
      objects.each do |e|
        e.update(ts)
      end
    end
  end

  def draw
    objects.each do |e|
      e.draw
    end
  end
  
  def remove(*objs)
    objs.flatten.each do |o|
      self.objects.delete(o)
    end
  end

end

