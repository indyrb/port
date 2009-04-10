class Game
  attr_accessor :score, :objects, :level, :logger, :window

  def initialize(window)
    @start_time = nil
    @end_time = nil
    self.window = window
    self.score = 0
    self.objects = []
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

  def update(ts=nil)
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

