class FiltersController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :forward

  def forward
    Filter.read_forward_filters(current_userid,current_password)

    @filters = []
    5.times do
      @filters << Filter.new
    end
  end

  def new
  end
end
