require 'spec_helper'

describe 'Filter, forward: update,' do
  context 'with antispam filters' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag: YES\n.Junk/")
      @member = login_member
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      Filter.read_filters(@member.id,"correct").map(&:to_file).should eq [":0:\n* ^X-Spam-Flag: YES\n.Junk/"]
    end
  end

  context 'with antispam&forward filters' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag: YES\n.Junk/")
      @member = login_member
      fill_in 'Address 1', with:'example@email.com'
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      Filter.read_filters(@member.id,"correct").map(&:to_file).should eq [":0:\n* ^X-Spam-Flag: YES\n.Junk/",":0\n*\n!example@email.com"]
    end
  end

  context 'updates .forward' do
    before(:each) do
      @member = login_member
      Filter.stub(:read_filters).and_return [] 
      fill_in 'Address 1', with:'example@email.com'
      click_button 'Update'
    end
    
    it "gets saved to .forward" do
      Filter.read_forward(@member.id,"correct").should eq "\"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 #member\""
    end
  end
end
