class Array
  def classification
    collect(&:last)
  end

  # calculate information entropy
  def entropy
    return 0 if empty?

    info = {}
    each do |i|
      info[i] = !info[i] ? 1 : (info[i] + 1)
    end

    result(info, length)
  end

  private

  def result(info, total)
    final = 0
    info.each do |_symbol, count|
      next unless count > 0
      percentage = count.to_f / total
      final += -percentage * Math.log(percentage) / Math.log(2.0)
    end
    final
  end
end
