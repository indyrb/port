class Field
  
  attr_accessor :window, :background, :clouds

  def initialize(window)
    self.window = window
    self.background = window.assets.by_name('background')
    self.clouds = []
    (rand(10) + 3).times do
      clouds << Cloud.new(window.game, rand(window.width), rand(window.height))
    end
  end
  
  def update
    clouds.each do |cloud|
      cloud.update
    end
  end
  
  def draw
    (window.width.to_f / background.width).ceil.times do |xc|
      (window.height.to_f / background.height).ceil.times do |yc|
        background.draw(xc * background.width, yc * background.height, 0)
      end
    end

    clouds.each do |cloud|
      cloud.draw
    end
  end
end
