class Filter < ActiveRecord::Base
  has_many :rules
  has_many :actions
  accepts_nested_attributes_for :rules
  accepts_nested_attributes_for :actions

  def <=>(filter)
    self.action <=> filter.action
  end

  def action
    raise "There exists more than one action for a filter." if actions.first != actions.last
    actions.first
  end
  def action_operation; action.operation end

  def is_antispam?; rule.is_antispam? end
  def is_forward?; action.is_forward? end

  def destination
    return nil if actions.empty?
    action.destination
  end

  def rule
    raise "There exists more than one rule for a filter." if rules.first != rules.last
    rules.first
  end

  def rule_section; rule && rule.section end

  def to_file
    rules_to_file(action.operation)+"\n"+actions_to_file
  end

  class << self
    def factory_anti_spam(operation,destination='Junk')
      factory([":0:","* ^#{operation}:.*YES", ".#{destination}/"])
    end
    def factory_anti_spam_medium
      factory_anti_spam(Rule::X_SPAM_FLAG)
    end
    def factory_anti_spam_high
      factory_anti_spam(Rule::X_BARRACUDA_SPAM_FLAG)
    end

    def factory_forward_copy(email)
      factory([":0c","*","!#{email}"]) 
    end
    def factory_forward_message(email)
      factory([":0","*","!#{email}"]) 
    end

    def copy_forward_to_procmail(s)
      ":0c\n*\n!#{s}"
    end
    def message_forward_to_procmail(s)
      ":0\n*\n!#{s}"
    end

    def forward_to_procmail(a)
      copy = false
      a.map do |e|
        if e =~ /\/usr\/local\/bin\/procmail/
          nil
        elsif e =~ /^\\\w+/
          copy = true
          nil
        elsif copy
          copy_forward_to_procmail(e)
        elsif a.last == e
          message_forward_to_procmail(e)
        else
          copy_forward_to_procmail(e)
        end
      end.compact.join("\n\n") 
    end

    def read_forward(userid="test",passwd="correct")
      p "Loading .forward..."
      IO.popen("/usr/local/sbin/chfwd -g #{userid}", 'r+') do |pipe|
        pipe.write(passwd)
        pipe.close_write
        pipe.read.strip
      end
    end

    def read_filters(userid="test",passwd="correct")
      p "Loading .procmailrc..."
      IO.popen("/usr/local/sbin/chprocmailrc -g #{userid}", 'r+') do |pipe|
        pipe.write(passwd)
        pipe.close_write
        abstract_factory(pipe.read)
      end
    end

    def write_filters(s,prolog=nil,userid="test",password="password")
      p "Writing .procmailrc..."
      IO.popen("/usr/local/sbin/chprocmailrc -s #{userid}", 'r+') do |pipe|
        pipe.write("#{password}\n")
        if prolog.nil?
          pipe.write("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=/var/log/procmail/#{userid}.log\nVERBOSE=on")
        else
          pipe.write "#{prolog}" 
        end
        pipe.write "\n\n" 
        pipe.write("#{s.strip}\n")
        pipe.close_write
      end
    end
    def write_forward(userid="test",password="password", s=nil)
      p "Writing .forward..."
      IO.popen("/usr/local/sbin/chfwd -s #{userid}", 'r+') do |pipe|
        pipe.write("#{password}\n")
        if s.nil?
          pipe.write("\"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 ##{userid}\"\n")
        else
          pipe.write("#{s.strip}\n")
        end
        pipe.close_write
      end
    end

    private

      def abstract_factory(s)
        a = s.split("\n")
        prolog = []
        prolog << a.shift while a.present? && !(a.first =~ /^:0/)
        prolog.pop while prolog.present? && prolog.last.blank?
        [factories(a), prolog.join("\n")]
      end

      #def anti_spam_factory(a)
      #  filter = Filter.create
      #  op = a.shift
      #  filter.rules << Rule.anti_spam_factory(a)
      #  filter.actions << Action.factory(op,a)
      #  filter
      #end

      def factory(a)
        filter = Filter.create
        op = a.shift
        filter.rules << Rule.factory(a)
        filter.actions << Action.factory(op,a)
        raise "Filters are wrongly separated." if a.first.present? 
        #while !a.empty? && a.first.blank?
          #raise "All filters but the last must have the copy operator." if Action.get_operation(op) == Action::FORWARD_MESSAGE_TO
        #  a.shift 
        #end
        filter
      end

      def factories(a)
        filters = []
        while !a.empty?
          a.shift while a.first.blank?
          filters << factory(a) 
        end
        filters
      end

  end

private

    def actions_to_file
      action.to_file
    end

    def rules_to_file(op)
      rule.to_file(op)
    end
end
