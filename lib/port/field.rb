class Field
  
  attr_accessor :window, :background, :clouds, :game

  def initialize(window)
    self.window = window
    self.game = window.game
    self.background = window.assets.by_name('background')
    self.clouds = []
    (rand(10) + 3).times do
      clouds << Cloud.new(window.game, Vector[rand(window.width), rand(window.height)])
    end
  end
  
  def update
    if game.clouds
      clouds.each do |cloud|
        cloud.update
      end
    end
  end
  
  def draw
    (window.width.to_f / background.width).ceil.times do |xc|
      (window.height.to_f / background.height).ceil.times do |yc|
        background.draw(xc * background.width, yc * background.height, 0)
      end
    end

    if game.clouds
      clouds.each do |cloud|
        cloud.draw
      end
    end
  end
end
