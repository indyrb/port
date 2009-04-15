class Polygon
  attr_accessor :points, :center, :closed
  
  def initialize(points, options = {})
    self.points = points
    self.center = options[:center]  || points.first
    self.closed = options[:closed]
  end
  
  def rotate(angle)
    new_points = points.collect do |point|
      (point - center).rotate(angle) + center
    end
    
    self.class.new(new_points, options)
  end
  
  def options
    { :center => center, :closed => closed }
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
  
  def average
    unless empty?
      average_x = points.collect(&:x).sum.to_f / points.size
      average_y = points.collect(&:y).sum.to_f / points.size
      Vector[average_x, average_y]
    end
  end
  
  def split(count)
    segment_legnth = length.to_f / count
    polygons = []
    count.times do |i|
      polygons << Polygon.new([
        follow(segment_legnth * i),
        follow(segment_legnth * (i + 1))
      ], :closed => false)
    end
    polygons
  end
  
  def interpolate(count, width)
    segment_legnth = length.to_f / count
    averages = []
    count.times do |i|
      averages << Polygon.new([
        follow(segment_legnth * i - width / 2),
        follow(segment_legnth * i + width / 2)
      ]).average
    end
    self.class.new([points.first] + averages + [points.last], options)
  end
  
  def follow(distance)
    unless empty?
      if distance < 0
        return points.first
      end
      current, *tail = points
      tail.each do |point|
        new_distance = distance - current.distance_to(point)
        if new_distance <= 0
          # hit reverse!
          current += ((current - point) * -1).unit * distance
          return current
        end
        distance = new_distance
        current = point
      end
    end
    current || points.last
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
  
  def +(vector)
    new_points = points.collect { |p| p + vector }
    Polygon.new(new_points, options)
  end
  
end