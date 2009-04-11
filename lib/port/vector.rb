class Vector
  
  attr_accessor :x, :y

  def self.[](x,y)
    Vector.new(x,y)
  end

  def initialize(x,y)
    self.x = x
    self.y = y
  end

  def distance_to(other_vector)
    Math.sqrt(self.dot(other_vector))
  end

  def angle_between(other_vector)
    cos = self.dot(other_vector) / (self.magnitude * other_vector.magnitude)
    Math.acos(cos)
  end

  def magnitude
    Math.sqrt(self.dot(this))
  end

  def dot(other_vector)
    (self.x * other_vector.x) + (self.y  * other_vector.y)
  end

  def cross(other_vector)
    (self.x * other_vector.y) - (self.y * other_vector.x)
  end

  def project(other_vector)
    scalar = self.dot(other_vector) / Math.pow(other_vector.magnitude, 2)
    
  end

  def *(scalar)
    Vector.new(self.x * scalar, self.y * scalar)
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


  
end
