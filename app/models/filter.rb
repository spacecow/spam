class Filter < ActiveRecord::Base
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
        filter = Filter.new
        filter.rules << Rule.foward_rule(a)
      end
  end
end
