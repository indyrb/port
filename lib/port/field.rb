class Field
  include Game::Constants

  attr_accessor :window, :background, :clouds, :game

  def initialize(window)
    self.window = window
    self.game = window.game
    self.background = window.assets.by_name("background#{1 + rand(3)}")
    self.clouds = []
    (rand(10) + 3).times do
      clouds << Cloud.new(window.game, window.dimensions.random)
    end
  end
  
  def update(diff, diff_fractional)
    if game.clouds
      clouds.each do |cloud|
        cloud.update(diff, diff_fractional)
      end
    end
  end
  
  def draw
    (window.width.to_f / background.width).ceil.times do |xc|
      (window.height.to_f / background.height).ceil.times do |yc|
        background.draw(xc * background.width, yc * background.height, ZOrder::Field)
      end
    end

    if game.clouds
      clouds.each do |cloud|
        cloud.draw
      end
    end
  end
end
