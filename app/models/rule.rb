class Rule < ActiveRecord::Base
  belongs_to :filter

  ENABLED = "enabled"
  ANTI_SPAM_OPTIONS = [ENABLED]

  X_BARRACUDA_SPAM_FLAG = "X-Barracuda-Spam-Flag"
  X_SPAM_FLAG = "X-Spam-Flag"

  BEGINS_WITH = "begins_with"

  def is_antispam?
    Rule.is_antispam?(to_file)
  end
  
  def to_file(op=nil)
    ret = ""
    unless op.nil?
    ret += ":0"
      ret += case op
        when Action::FORWARD_MESSAGE_TO; ""
        when Action::FORWARD_COPY_TO; "c"
        when Action::MOVE_MESSAGE_TO; ":"
        else raise "Action has no operation." 
      end
      ret += "\n"
    end
    ret += "*"
    ret += " #{part_section}:" unless section.blank?
    ret += ".*#{content}" unless content.blank?
    ret
  end

  def part_section; "^#{section}" end
  def part_section_content; "^#{section}: #{content}" end

  class << self
    #def anti_spam_factory(a)
    #  rule = strip_rule(a)
    #  (section, part, content) = Rule.separate_attributes(rule)
    #  Rule.create(section:section,part:part,content:content)
    #end

    def anti_spam_options
      ANTI_SPAM_OPTIONS.map{|e| I18n.t(e)}.zip([X_SPAM_FLAG])
    end

    def factory(a)
      rule = strip_rule(a)
      (section, part, content) = Rule.separate_attributes(rule) unless rule == "*"
      Rule.create(section:section,part:part,content:content)
    end

    def separate_attributes(s)
      data = s.match(/\*\s\^(.*):\.\*YES/)
      [data[1], BEGINS_WITH, 'YES']
    end

    def strip_rule(a)
      rules = []
      rules << a.shift while is_rule?(a.first)
      raise "Can only create one rule." if rules.size > 1
      raise "Rule is wrongly formatted: '#{a.first}'." if rules.size == 0
      rules.first
    end

    def is_rule?(s)
      return true if is_forward?(s)
      return true if is_antispam?(s)
      false
    end

    def is_forward?(s)
      case s
        when "*"; return true
      end
    end

    def is_antispam?(s)
      case s
        when "* ^X-Spam-Flag:.*YES"; return true
        when "* ^X-Barracuda-Spam-Flag:.*YES"; return true
      end
    end
  end
end
