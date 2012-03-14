class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role? :admin
        can [:index,:create,:update_multiple], Translation
      end
    end
  end
end
