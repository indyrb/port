# frozen_string_literal: true

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
    Gosu.distance(x, y, other_vector.x, other_vector.y)
  end

  def angle_between(other_vector)
    Gosu.angle(x, y, other_vector.x, other_vector.y)
  end

  def magnitude
    Gosu.distance(0, 0, x, y)
  end

  def angle
    self.class.origin.angle_between(self)
  end

  def dot(other_vector)
    (x * other_vector.x) + (y  * other_vector.y)
  end

  def cross(other_vector)
    (x * other_vector.y) - (y * other_vector.x)
  end

  def project(other_vector)
    scalar = dot(other_vector) / (other_vector.magnitude**2)
    other_vector.unit * scalar
  end

  def unit
    mag = magnitude
    Vector.new(x / mag, y / mag)
  end

  def *(scalar)
    Vector.new(x * scalar, y * scalar)
  end

  def /(scalar)
    Vector.new(x / scalar, y / scalar)
  end

  def +(other_vector_or_scalar)
    xm = (other_vector_or_scalar.respond_to?(:x)) ? other_vector_or_scalar.x : other_vector_or_scalar
    ym = (other_vector_or_scalar.respond_to?(:y)) ? other_vector_or_scalar.y : other_vector_or_scalar
    Vector.new(x + xm, y + ym)
  end

  def -(other_vector_or_scalar)
    xm = (other_vector_or_scalar.respond_to?(:x)) ? other_vector_or_scalar.x : other_vector_or_scalar
    ym = (other_vector_or_scalar.respond_to?(:y)) ? other_vector_or_scalar.y : other_vector_or_scalar
    Vector.new(x - xm, y - ym)
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
    "<Vector #{self}>"
  end

  def to_s
    "(%.2f, %.2f)" % [x, y]
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
