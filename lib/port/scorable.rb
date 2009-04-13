class Scorable < Sprite
  class << self
    def score(value = nil)
      if value
        @score = value
      end
      @score || superclass.score if superclass.respond_to?(:score)
    end
  end

  def score
    self.class.score
  end

  def add_score
    game.score += score
  end
end
