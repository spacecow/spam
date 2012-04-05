class Array
  def contains_antispam?
    self.present? && self.map(&:is_antispam?).include?(true)
  end

  def last_forward_action_operation
    self.reverse.each do |filter|
      return filter.action_operation if filter.is_forward?
    end
  end

  def to_file
    self.sort.map(&:to_file).join("\n\n")
  end
end
