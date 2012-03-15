class Filter < ActiveRecord::Base
  has_many :rules
  has_many :actions

  class << self
    def read_forward_filters(userid="test",passwd="correct")
      p "Loading .procmailrc..."
      IO.popen("/usr/local/bin/chprocmailrc -g #{userid}", 'r+') do |pipe|
        pipe.write(passwd)
        pipe.close_write
        pipe.read
      end
    end

    def write_forward_filters(s,userid="test")
      IO.popen("/usr/local/bin/chprocmailrc -s #{userid}", 'r+') do |pipe|
        pipe.write("password\n")
        pipe.write("#{s.strip}\n")
        pipe.close_write
      end
    end

    private

      def factory(s)
        a = s.split("\n")
        forward_factory(a)
      end

      def forward_factory(a)
        filters = []
        while !a.empty?
          filter = Filter.new
          op = a.shift
          filter.rules << Rule.forward_factory(a)
          filter.actions << Action.forward_factory(op,a)
          filters << filter
          raise "Filters are wrongly separated." if a.first.present? 
          while !a.empty? && a.first.blank?
            raise "All filters but the last must have the copy operator." if Action.get_operation(op) == Action::FORWARD_MESSAGE_TO
            a.shift 
          end
        end
        filters
      end
  end
end
