class Polygon
  attr_accessor :points, :center, :closed
  
  def initialize(points, options = {})
    self.points = points
    self.center = options[:center]  || points.first
    self.closed = options[:closed]
  end
  
  def rotate_degrees(angle)
    new_points = points.collect do |point|
      (point - center).rotate_degrees(angle) + center
    end
    
    self.class.new(new_points, :center => center, :closed => closed)
  end
  
  def length
    last_point = points.first
    points.tail.inject(0) do |memo, point|
      memo += last_point.distance_to(point)
      last_point = point
      memo
    end
  end
  
  def perimeter
    length + points.last.distance_to(points.first)
  end

  def empty?
    points.empty?
  end
  
  def follow_and_remove(start, distance)
    unless empty?
      current = start
      loop do
        if points.size < 1
          break
        else
          point = points.first
          new_distance = distance - current.distance_to(point)
          if new_distance <= 0
            # hit reverse!
            current += ((current - point) * -1).unit * distance
            points.unshift current
            return current
          end
          points.shift
          distance = new_distance
          current = point
        end
      end
    end
  end
  
end