class FiltersController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :forward

  def forward
    @filters = Filter.read_forward_filters(current_userid,current_password)

    (5-@filters.count).times do
      @filters << Filter.new
    end
  end

  def new
  end
end
