require 'spec_helper'

describe 'Layout' do
  context 'member' do
    before(:each){ login_member }

    it "has a 'Mail-forwarding' link" do
      user_nav.should have_link('Mail-forwarding')
    end

    it "has a 'Spam-filtering' link" do
      user_nav.should have_link('Mail-forwarding')
    end

    it "has no link to translations" do
      user_nav.should_not have_link('Translations')
    end
  end

  context 'admin' do
    before(:each){ login_admin }

    it "has a link to translations" do
      user_nav.should have_link('Translations')
    end

    it "translations link is linked to translations index" do
      user_nav.click_link 'Translations'
      current_path.should eq translations_path
    end
  end

  context 'member links to' do
    before(:each){ login_member }

    it "'Mail-forwarding' links to the forward page" do
      Filter.stub(:read_filters).and_return [] 
      user_nav.click_link('Mail-forwarding')
      current_path.should eq forward_path
    end

    it "'Mail-forwarding' links to the forward page" do
      Filter.stub(:read_filters).and_return [] 
      user_nav.click_link('Spam-filtering')
      current_path.should eq antispam_path
    end
  end
end
