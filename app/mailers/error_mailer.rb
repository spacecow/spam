class ErrorMailer < ActionMailer::Base
  default :from => "from@example.com"

  def filter_error(userid, error)
    @class = error.class
    @error = error.message
    @trace = error.backtrace
    @username = User.find(userid).userid
    mail(:to => "jsveholm@fir.riec.tohoku.ac.jp",
         :subject => "Procmail:Exception")
  end
end
