class Game
  module Constants
    module Colors
      Selection = 0xffffffff # white
      Proximity = 0xffff0000 # red
      Score = 0xffffffff     # white
      FPS = 0xffffff00       # yellow
      module Debug
        module Sprite
          Outline = 0xff00ff00
          Center = 0xff008800
        end
        Proximity = 0xffff00ff
      end
    end

    module ZOrder
      Score = 100
      FPS = 100
      Field = 0
      module Debug
        module Sprite
          Outline = 10
          Center = 10
        end
        LandingTest = 100
        Proximity = 300
      end
    end
  end
end