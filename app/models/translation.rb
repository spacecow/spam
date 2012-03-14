class Translation < ActiveRecord::Base
  belongs_to :locale

  attr_accessor :locale_token

  validates_presence_of :key,:value,:locale

  def locale_token=(s)
    if s =~ /^\d+$/
      self.locale_id = s 
    elsif !s.blank?
      self.locale_id = Locale.find_or_create_by_name(s).id
    end
  end

  class << self
    def print_keys
      p TRANSLATION_STORE.keys
    end
  end
end
