# frozen_string_literal: true

class Hash

  def choose_weighted
    target = rand
    normalize_weighted.each do |item, weight|
      return item if target <= weight
      target -= weight
    end
  end

  def normalize_weighted
    sum = values.sum.to_f
    each { |item, weight| self[item] = weight/sum }
  end

end
