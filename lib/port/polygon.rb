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

end