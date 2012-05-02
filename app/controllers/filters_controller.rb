class FiltersController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:forward,:update_mulitple_forward,:antispam]

  def forward
    begin
      forward = Filter.read_forward(current_userid,current_password)
      if forward.blank?
        Filter.write_forward(current_userid,current_password)
      elsif forward == "\"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 ##{current_userid}\""
      else
        @filters, p = Filter.send("abstract_factory",Filter.forward_to_procmail(forward.split("\n")))
        if @filters.map(&:valid?).include?(false)
          raise ".forward is wrongly_formatted: '#{forward}'." 
        else
          new_filters, prolog = Filter.read_filters(current_userid,current_password)
          @filters += new_filters
          raise mess(:move_forward_into_procmailrc?) 
        end
      end

      @filters, prolog = Filter.read_filters(current_userid,current_password)
      session_prolog(prolog)
      unless @filters.empty?
        @keep = 'yes' if @filters.last_forward_action_operation == Action::FORWARD_COPY_TO 
      end

      no = @filters.contain_antispam? ? 6 : 5 
      (no-@filters.count).times do
        @filters << Filter.new
      end
    rescue RuntimeError => e
      if e.message == mess(:move_forward_into_procmailrc?)
        @move = e.message
      else
        ErrorMailer.filter_error(session_userid,e).deliver
        @error = e.message
      end
    end
  end

  def update_multiple_forward
    @filters = []

    tot_count = 0
    params[:filter].keys.each do |k|
      if params[:filter][k][:actions_attributes]
      else
        value = params[:filter][k][:address]
        if value.present?
          tot_count += 1
        end
      end
    end

    count = tot_count
    params[:filter].keys.each do |k|
      if params[:filter][k][:actions_attributes]
        @filters << Filter.create(params[:filter][k])
      else
        value = params[:filter][k][:address]
        if value.present?
          if !params[:keep].nil? || (tot_count > 1 && count > 1)
            @filters << Filter.factory_forward_copy(value)
          else
            @filters << Filter.factory_forward_message(value)
          end
          count -= 1
        end
      end
    end
    unless @filters.map(&:valid?).include?(false)
      Filter.write_filters(@filters.to_file,session_prolog,current_userid,current_password)
      Filter.write_forward(current_userid,current_password)
      redirect_to forwarding_url, notice:updated(:forward_settings)
    else
      no = @filters.contain_antispam? ? 6 : 5 
      (no-@filters.count).times do
        @filters << Filter.new
      end
      @keep = params[:keep]
      render :forward
    end
  end

  def antispam
    begin
      forward = Filter.read_forward(current_userid,current_password)
      if forward.blank?
        Filter.write_forward(current_userid,current_password)
      elsif forward != "\"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 ##{current_userid}\""
        raise ".forward is wrongly_formatted: '#{forward}'." 
      end

      @filters, prolog = Filter.read_filters(current_userid,current_password)
      session_prolog(prolog)
      @filters << Filter.new(actions_attributes:{'0'=>{destination:'Junk'}}) unless @filters.contain_antispam? 
    rescue RuntimeError => e
      @error = e.message
    end
  end

  def update_multiple_antispam
    @filters = []
    params[:filter].keys.each do |k|
      if params[:filter][k][:actions_attributes]
        @filters << Filter.create(params[:filter][k])
      else
        operation = params[:filter][k][:operation]
        destination = params[:filter][k][:destination]
        @filters << Filter.factory_anti_spam(operation,destination) unless operation.blank?
      end
    end
    unless @filters.map(&:valid?).include?(false)
      Filter.write_filters(@filters.to_file,session_prolog,current_userid,current_password)
      redirect_to filtering_url, notice:updated(:anti_spam_settings)
    else
      render :antispam
    end
  end
end
