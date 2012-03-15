require 'spec_helper'

describe 'Layout' do
  context 'member' do
    before(:each){ login_member }

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
end
