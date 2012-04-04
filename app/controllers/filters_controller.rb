class FiltersController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:forward,:update_mulitple_forward,:antispam]

  def forward
    begin
      forward = Filter.read_forward(current_userid,current_password)
      if forward.blank?
        Filter.write_forward(current_userid,current_password)
      elsif forward != "\"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 ##{current_userid}\""
        raise ".forward is wrongly_formatted: '#{forward}'." 
      end

      @filters = Filter.read_filters(current_userid,current_password)
      unless @filters.empty?
        @keep = 'yes' if @filters.last_forward_action_operation == Action::FORWARD_COPY_TO 
      end

      no = @filters.contains_antispam? ? 6 : 5 
      (no-@filters.count).times do
        @filters << Filter.new
      end
    rescue RuntimeError => e
      @error = e.message
    end
  end

  def update_multiple_forward
    @filters = []
    params[:filter].keys.reverse.each do |k|
      if params[:filter][k][:actions_attributes]
        @filters << Filter.create(params[:filter][k])
      else
        value = params[:filter][k][:address]
        if value.present?
          if @filters.empty? && params[:keep].nil?
            @filters << Filter.factory_forward_message(value)
          else
            @filters << Filter.factory_forward_copy(value)
          end
        end
      end
    end
    unless @filters.map(&:valid?).include?(false)
      Filter.write_filters(@filters.reverse.to_file,current_userid,current_password)
      #Filter.write_forward(current_userid,current_password)
      redirect_to forward_url, notice:updated(:forward_settings)
    else
      no = @filters.contains_antispam? ? 6 : 5 
      (no-@filters.count).times do
        @filters << Filter.new
      end
      @keep = params[:keep]
      render :forward
    end
  end

  def antispam
    @filters = Filter.read_filters(current_userid,current_password)
    @filters << Filter.new(actions_attributes:{'0'=>{destination:'Junk'}}) unless @filters.contains_antispam? 
  end

  def update_multiple_antispam
    @filters = []
    params[:filter].keys.each do |k|
      if params[:filter][k][:actions_attributes]
        @filters << Filter.new(params[:filter][k])
      else
        operation = params[:filter][k][:operation]
        destination = params[:filter][k][:destination]
        @filters << Filter.factory_anti_spam(operation,destination) unless operation.blank?
      end
    end
    unless @filters.map(&:valid?).include?(false)
      Filter.write_filters(@filters.to_file,current_userid,current_password)
      redirect_to antispam_url, notice:updated(:anti_spam_settings)
    else
      render :antispam
    end
  end
end
