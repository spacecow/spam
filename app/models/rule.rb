class Rule < ActiveRecord::Base
  belongs_to :filter

  class << self
    def forward_factory(a)
      strip_rule(a)
      Rule.create
    end

    def strip_rule(a)
      rules = []
      rules << a.shift while is_rule?(a.first)
      raise "Can only create one rule." if rules.size > 1
      raise "Rule is wrongly formatted: '#{a.first}'." if rules.size == 0
    end

    def is_rule?(s) s == "*" end
  end
end
