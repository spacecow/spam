class Forward < ActiveRecord::Base
  attr_accessible :address

  class << self
    def load(userid,passwd)
      p "Loading .procmailrc"
      IO.popen("/usr/local/bin/chprocmailrc -g #{userid}", 'r+') do |pipe|
        pipe.write(passwd)
        pipe.close_write
        pipe.read
      end
    end
  end
end
