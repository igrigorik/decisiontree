class Array
  def classification
    collect(&:last)
  end

  # calculate information entropy
  def entropy
    return 0 if empty?

    info = {}
    total = 0
    each do |i|
      info[i] = !info[i] ? 1 : (info[i] + 1)
      total += 1
    end

    result = 0
    info.each do |_symbol, count|
      if count > 0
        result += -count.to_f / total * Math.log(count.to_f / total) / Math.log(2.0)
      end
    end
    result
  end
end
