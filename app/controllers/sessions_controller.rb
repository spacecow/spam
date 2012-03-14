class SessionsController < ApplicationController
  def new
  end

  def create
    userid = params[:username]
    passwd = params[:password]
    if authpam(userid,passwd)
      user = User.find_or_create_by_userid(userid)
      session_userid(user.id)
      redirect_to forwards_path, :notice => notify(:logged_in)
    else
      redirect_to login_path, :alert => alertify(:invalid_login_or_password)
    end
  end

  def destroy
    session_userid(nil)
    redirect_to login_path, :notice => notify(:logged_out)
  end

  private

    def authpam(user,pass); pass == "correct" ? true : false end

end
