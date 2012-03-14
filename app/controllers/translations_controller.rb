class TranslationsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:index,:update_multiple]

  def index
    @translation = Translation.new
    @translations = TRANSLATION_STORE
  end

  def create
    if @translation.valid?
      I18n.backend.store_translations(@translation.locale.name, {@translation.key => @translation.value}, escape:false)
      redirect_to translations_path
    else
      @translation.errors.add(:locale_token,@translation.errors[:locale]) if @translation.errors[:locale]
      @translations = TRANSLATION_STORE
      render :index
    end
  end

  def update_multiple
    (params[:en]||{}).each do |k,v|
      I18n.backend.store_translations(v[:locale], {v[:key]=>v[:value]}, :escape => false) unless v[:value].blank?
    end
    (params[:ja]||{}).each do |k,v|
      I18n.backend.store_translations(v[:locale], {v[:key]=>v[:value]}, :escape => false) unless v[:value].blank?
    end
    redirect_to translations_path
  end
end
