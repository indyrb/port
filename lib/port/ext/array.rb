class Array
  def rand
    index = (Kernel.rand * size).to_i
    self[index]
  end
end
