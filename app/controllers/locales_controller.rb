class LocalesController < ApplicationController
  skip_load_resource :only => :index
  load_and_authorize_resource
  
  def index
    @locales = Locale.where('name like ?',"%#{params[:q]}%")
  end
end
