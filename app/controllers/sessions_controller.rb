class SessionsController < ApplicationController
  def new
  end

  def create
    userid = params[:username]
    passwd = params[:password]
    if authpam(userid,passwd)
      user = User.find_or_create_by_userid(userid)
      session_userid(user.id)
      session_password(passwd)
      redirect_to forward_path, :notice => notify(:logged_in)
    else
      redirect_to login_path, :alert => alertify(:invalid_login_or_password)
    end
  end

  def destroy
    session_userid(nil)
    session_password(nil)
    redirect_to login_path, :notice => notify(:logged_out)
  end

  private

    def authpam(user,pass); pass == "correct" ? true : false end

end
