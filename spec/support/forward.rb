def load_procmail(s,userid="test")
  IO.popen("/usr/local/bin/chprocmailrc -s #{userid}", 'r+') do |pipe|
    pipe.write("password\n")
    pipe.write("#{s.strip}\n")
    pipe.close_write
  end
end
