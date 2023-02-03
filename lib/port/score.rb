# frozen_string_literal: true

class Score
  attr_accessor :game, :window, :background, :score, :text
  def initialize(game)
    self.game = game
    self.window = game.window
    self.background = window.assets.by_name("scorebg")
    self.text = Gosu::Font.new(window, Gosu::default_font_name, 20)
  end

  def update
  end

  def draw
    text.draw_text("Score: #{score}", (window.width - 100), 10, Game::ZOrder::Score, 1.0, 1.0, Game::Colors::Score)
    background.draw(window.width-130, 5, Game::ZOrder::Score - 1, 1.0, 1.0)
  end
end
