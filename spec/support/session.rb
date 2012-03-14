def login(userid='test',passwd='correct')
  visit login_path 
  fill_in 'Username', with:userid
  fill_in 'Password', with:passwd
  click_button 'Login'
end

def login_admin
  admin = create_admin(:userid => 'admin')
  login('admin')
  admin 
end

def create_admin(h={})
  create_user_with_role(:admin,h) 
end

private

  def create_user_with_hash(h={})
    Factory(:user,h) 
  end
  def create_user_with_role(s,h={})
    create_user_with_hash h.merge({:roles_mask=>User.role(s)})
  end
