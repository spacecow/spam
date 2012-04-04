class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role?(:member) || user.role?(:admin)
        can [:index,:forward,:update_multiple_forward,:antispam,:update_multiple_antispam], Filter 
      end
      if user.role? :admin
        can [:index,:create,:update_multiple], Translation
        can :index, Locale
      end
    end
  end
end
