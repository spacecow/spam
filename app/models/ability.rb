class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role? :member
        can :index, Forward 
      elsif user.role? :admin
        can [:index,:create,:update_multiple], Translation
        can :index, Locale
        can :index, Forward 
      end
    end
  end
end
