class Path < Sprite
  z_order 3
  score 0
  
  attr_accessor :points, :active, :vehicle
  
  def initialize(game, x, y, vehicle)
    self.active = true
    self.points = [[x, y]]
    self.vehicle = vehicle
    vehicle.path = self
    super(game, x, y)
  end
  
  def update(ts, ms)
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
        window.draw_line(previous_x - 1, previous_y, color, x - 1, y, color, z_order) 
        window.draw_line(previous_x, previous_y, color, x, y, color, z_order) 
        window.draw_line(previous_x, previous_y - 1, color, x , y - 1, color, z_order) 
      end
      previous_x, previous_y = x, y
    end
  end

  
  def move_along(sx, sy, distance)
    if !points.empty?
      # logger.debug "Moving along path #{distance}, #{points.size} points."
      current_x, current_y = sx, sy #points.shift
      loop do
        x, y = points.first
        if !x && !active
          destroy
        end
        new_distance = distance - Gosu::distance(current_x.to_i, current_y.to_i, x.to_i, y.to_i)
        if new_distance <= 0
          # logger.debug "  reached endpoint, last step was #{distance}"
          angle = Gosu::angle(current_x.to_i, current_y.to_i, x.to_i, y.to_i)
          current_x += Gosu::offset_x(angle, distance)
          current_y += Gosu::offset_y(angle, distance)

          #points.unshift [current_x, current_y]
          return points.first
        end
        points.shift
        # logger.debug "  stepped #{distance - new_distance}, #{points.size} points."
        distance = new_distance
        current_x = x
        current_y = y
      end
    end
  end
  
  def color
    0x88ffffff
  end
  
  def contains?(check_x, check_y)
    false
  end
  
  def destroy
    vehicle.path = nil
    super
  end
  
end

