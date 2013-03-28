class Array
  def rand
    index = (Kernel.rand * size).to_i
    self[index]
  end

  def tail
    if size > 1
      self[1..-1]
    else
      []
    end
  end

  alias :head :first
end
