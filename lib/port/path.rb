class Path < Sprite
  z_order 3
  score 0
  
  attr_accessor :points, :active, :vehicle
  
  def initialize(game, x, y, vehicle)
    self.active = true
    self.points = [[x, y]]
    super(game, x, y)
  end
  
  def update(ts)
    if active && window.button_down?(Gosu::Button::MsLeft)
      self.points << [window.mouse_x, window.mouse_y]
    elsif active
      self.active = false
      game.active_path = nil
    end
  end
  
  def draw
    previous_x = previous_y = nil
    points.each do |x, y|
      if previous_x
        window.draw_line(previous_x, previous_y, color, x, y, color, z_order)
      end
      previous_x, previous_y = x, y
    end
  end
  
  def color
    0xffff0000
  end
  
  def contains?(check_x, check_y)
    false
  end
end