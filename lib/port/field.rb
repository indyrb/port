class Field
  
  attr_accessor :window, :background

  def initialize(window)
    self.window = window
    self.background = window.assets.by_name('background')
  end
  
  def draw
    background.draw(0, 0, 0)
  end
end