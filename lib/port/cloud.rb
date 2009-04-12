class Cloud < Sprite
  z_order 100
  sprite_options :file => 'cloud'
  
  def initialize(game, position)
    super
    start
  end


  def start
    restart
    position.x = rand(window.width)
  end
  
  def restart
    self.scale = rand(4) + 2

    linear_max = 0.1
    linear_min = 0.003
    @xv = rand(linear_max - linear_min) + linear_min

    angle_max = 0.1
    @av = rand * angle_max - angle_max / 2
    @av = @av/@av.abs * angle_max

    self.angle = rand(360)
    position.x = window.width + width * scale
    self.color = Gosu::Color.new(255 / scale, 255, 255, 255)
  end
  
  def update
    position.x -= @xv
    self.angle += @av
    if position.x + width < 0
      restart
    end
  end
  
end