class Vehicle < Sprite
  
  score 1
  z_order 1

  class << self

    def max_acceleration()
    end
    
  end

  attr_accessor :velocity, :acceleration, :heading
  

  def update

  end

end


