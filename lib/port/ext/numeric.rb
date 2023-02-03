# frozen_string_literal: true

class Numeric
  def clamp(low, high)
    if self < low
      low
    elsif self > high
      high
    else
      self
    end
  end
end
