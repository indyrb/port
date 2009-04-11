class Vector
  
  attr_accessor :x, :y

  def self.[](x,y)
    Vector.new(x,y)
  end

  def initialize(x,y)
    self.x = x.to_f
    self.y = y.to_f
  end

  def distance_to(other_vector)
    Gosu::distance(self.x, self.y, other_vector.x, other_vector.y)
  end

  def angle_between(other_vector)
    sm = self.magnitude; om = other_vector.magnitude
    if (denom = sm*om) == 0
      if sm == 0
        tan = other_vector.y / other_vector.x
      elsif om == 0
        tan = self.y / self.x
      end
      Math.atan(tan)
    else
      cos = self.dot(other_vector) / denom
      Math.acos(cos)            
    end
  end

  def angle_between_gosu(other_vector)
    Gosu::angle(self.x, self.y, other_vector.x, other_vector.y)    
  end

  def magnitude
    arg = (self.x * self.x) + (self.y * self.y)
    (arg.nan?) ? 0 : Math.sqrt(arg) 
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

  # radians
  def rotate_radians(angle)
    sin = Math.sin(angle)
    cos = Math.cos(angle)
    Vector[cos*self.x - sin*self.y, sin*self.x + cos*self.y]
  end

  # degrees
  def rotate_degrees(angle)
    self.rotate_radians(angle.gosu_to_radians)
  end

  def to_s
    "(#{self.x}, #{self.y})"
  end
  
end
