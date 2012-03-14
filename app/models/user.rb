class User < ActiveRecord::Base
  before_create :set_role

  ADMIN     = 'admin'
  GOD       = 'god'
  MEMBER    = 'member'
  MINIADMIN = 'miniadmin'
  VIP       = 'vip'
  ROLES     = [GOD,ADMIN,MINIADMIN,VIP,MEMBER]

  def role?(s) roles.include?(s.to_s) end
  def roles
    ROLES.reject{|r| ((roles_mask||0) & 2**ROLES.index(r)).zero? }
  end

  class << self
    def role(s) 2**ROLES.index(s.to_s) end
  end

  private

    def set_role
      self.roles_mask = User.role(User::MEMBER) unless roles_mask
    end
end
