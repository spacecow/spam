class ForwardsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :index

  def index
    Forward.load(current_userid,current_password)

    @forwards = []
    5.times do
      @forwards << Forward.new
    end
  end
end
