class Field
  
  attr_accessor :window, :background

  def initialize(window)
    self.window = window
    self.background = window.assets.by_name('background')
  end
  
  def draw
    background.draw(0, 0, 0)
  end
  
  def landing_zones
    [[[208, 271], [218, 512]]]
  end
  
  def in_landing_zone?(x, y)
    landing_zones.any? do |landing_zone|
      Range.new(*landing_zone.first).include?(x) && Range.new(*landing_zone.last).include?(y)
    end
  end
end
