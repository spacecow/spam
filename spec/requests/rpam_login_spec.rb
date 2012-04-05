require 'spec_helper'

describe "Sessions" do
  describe "new" do
    context "layout" do
      before(:each){ visit root_path }

      it "has a login link" do
        user_nav.should_not have_link('Login')
      end

      it "the login page has a title" do
        visit login_path
        page.should have_title('Login')
      end

      it "has no logout link" do
        user_nav.should_not have_link('Logout')
      end
    end

    context "login user" do
      it "should not take you to the login path" do
        login
        page.current_path.should_not eq login_path
      end

      it "shows a logged-in flash message" do
        login
        page.should have_notice("Logged in.")
      end

      it "has a logout link" do
        login
        user_nav.should have_link('Logout')
      end

      it "has no login link" do
        login
        user_nav.should_not have_link('Login')
      end

      it "a user is saved to the database" do
        lambda{ login
        }.should change(User,:count).by(1)
      end
    end

    context "logout user" do
      before(:each) do
        login
        user_nav.click_link 'Logout'
      end

      it "redirects to the login page" do
        current_path.should eq login_path
      end

      it "has no logout link" do
        user_nav.should_not have_link('Logout')
      end  

      it "shows a logged-out flash message" do
        page.should have_notice("Logged out.")
      end
    end

    it "login fails with incorrect information" do
      login("test","wrong")
      page.should have_alert("Invalid login or password.")
    end
  end
end
