class Hash
  
  def choose_weighted
    target = rand
    self.normalize_weighted.each do |item, weight|
      return item if target <= weight
      target -= weight
    end
  end

  def normalize_weighted
    sum = self.inject(0) do |sum, item_and_weight|
      sum += item_and_weight[1]
    end
    sum = sum.to_f
    self.each { |item, weight| self[item] = weight/sum }
  end
  
end