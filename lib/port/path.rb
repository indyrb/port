class Path < Sprite
  z_order 3
  
  attr_accessor :points, :active, :vehicle, :highlighted
  
  def initialize(game, x, y, vehicle)
    self.active = true
    self.points = [[x, y]]
    self.vehicle = vehicle
    vehicle.path = self
    super(game, x, y)
  end
  
  def update(ts, ms)
    if active && window.button_down?(Gosu::Button::MsLeft)
      self.points << [constrained_x, constrained_y]
      if game.in_landing_zone?(constrained_x, constrained_y)
        self.active = false
        self.highlighted = true
      end
    elsif active
      self.active = false
      game.active_path = nil
    end
  end
  
  def constrained_x
    if window.mouse_x > window.width
      window.width
    elsif window.mouse_x < 1
      1
    else
      window.mouse_x
    end
  end
  
  def constrained_y
    # puts window.mouse_y
    if window.mouse_y > window.height
      window.height
    elsif window.mouse_y < 1
      1
    else
      window.mouse_y
    end
  end

  def draw
    previous_x = previous_y = nil
    segment_size = 10.0
    points.each do |x, y|
      if previous_x
        iters = (Gosu::distance(previous_x, previous_y, x, y) / segment_size).ceil
        lpx, lpy = previous_x, previous_y
        1.upto(iters) do |seg|
          if (seg % 2) != 0
            lx, ly = lerp(previous_x, x, iters, seg), lerp(previous_y, y, iters, seg)
            window.draw_line(lpx - 1, lpy, color, lx - 1, ly, color, z_order) 
            window.draw_line(lpx, lpy, color, lx, ly, color, z_order) 
            window.draw_line(lpx, lpy - 1, color, lx , ly - 1, color, z_order)
            lpx, lpy = lx, ly
          end
        end
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
    (highlighted) ? 0x88FF0000 : 0x88ffffff
  end
  
  def contains?(check_x, check_y)
    false
  end
  
  def destroy
    vehicle.path = nil
    super
  end

  def collided?(sprite)
    false
  end
  
  private

  def lerp(a, b, p, t)
    clamp(t, 0, p) * (b - a) / p + a
  end

  def clamp(v, low, high)
    if v < low
      low
    elsif v > high
      high
    else
      v
    end
  end
  
end

