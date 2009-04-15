class Vector
  attr_accessor :x, :y
  def self.origin
    Vector[0, 0]
  end

  def self.north
    Vector[0, -1]
  end
  
  def self.east
    Vector[1,0]
  end
  
  def self.south
    Vector[ 0,  1]
  end
  
  def self.west
    Vector[-1,  0]
  end
  
  def self.[](x,y)
    Vector.new(x,y)
  end
  
  def self.angle(angle)
    Vector[0,1].rotate(angle)
  end

  def initialize(x,y)
    self.x = x.to_f
    self.y = y.to_f
  end

  def distance_to(other_vector)
    Gosu.distance(self.x, self.y, other_vector.x, other_vector.y)
  end

  def angle_between(other_vector)
    Gosu.angle(self.x, self.y, other_vector.x, other_vector.y)    
  end

  def magnitude
    Gosu.distance(0, 0, x, y)
  end
  
  def angle
    self.class.origin.angle_between(self)
  end

  def dot(other_vector)
    (self.x * other_vector.x) + (self.y  * other_vector.y)
  end

  def cross(other_vector)
    (self.x * other_vector.y) - (self.y * other_vector.x)
  end

  def project(other_vector)
    scalar = self.dot(other_vector) / (other_vector.magnitude**2)
    other_vector.unit * scalar
  end

  def unit
    mag = self.magnitude
    Vector.new(self.x / mag, self.y / mag)
  end

  def *(scalar)
    Vector.new(self.x * scalar, self.y * scalar)
  end

  def /(scalar)
    Vector.new(self.x / scalar, self.y / scalar)
  end

  def +(other_vector_or_scalar)
    xm = (other_vector_or_scalar.respond_to?(:x)) ? other_vector_or_scalar.x : other_vector_or_scalar
    ym = (other_vector_or_scalar.respond_to?(:y)) ? other_vector_or_scalar.y : other_vector_or_scalar
    Vector.new(self.x + xm, self.y + ym)    
  end

  def -(other_vector_or_scalar)
    xm = (other_vector_or_scalar.respond_to?(:x)) ? other_vector_or_scalar.x : other_vector_or_scalar
    ym = (other_vector_or_scalar.respond_to?(:y)) ? other_vector_or_scalar.y : other_vector_or_scalar
    Vector.new(self.x - xm, self.y - ym)
  end

  def rotate(angle)
    new_angle = Gosu.angle(0, 0, x, y) + angle
    distance = magnitude
    Vector[
      Gosu.offset_x(new_angle, distance),
      Gosu.offset_y(new_angle, distance)
    ]
  end
  
  def clamp(low, high)
    clamped_x = x.clamp(low.x, high.x)
    clamped_y = y.clamp(low.y, high.y)
    Vector[clamped_x, clamped_y]
  end

  def to_a
    [x, y]
  end
  
  def inspect
    "<Vector #{to_s}>"
  end
  
  def to_s
    "(%.2f, %.2f)" % [x, y]
  end
  
  def distance_to(point)
    (self - point).magnitude
  end
  
  def distance_steps_to(point, step_distance, offset = 0)
    points = []
    base = (point - self).unit
    distance = distance_to(point) + offset
    points << self
    (distance / step_distance - 1).ceil.times do |step|
      points << (base * ((step + 1) * step_distance - offset)) + self
    end
    points << point
    [points, distance % step_distance]
  end
  
  def random
    Vector[rand * x, rand * y]
  end
  
end
