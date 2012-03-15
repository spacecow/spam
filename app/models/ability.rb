class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role? :member
        can [:index,:forward], Filter 
      elsif user.role? :admin
        can [:index,:create,:update_multiple], Translation
        can :index, Locale
        can [:index,:forward], Filter 
      end
    end
  end
end
