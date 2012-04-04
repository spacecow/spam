require 'spec_helper'

describe 'Filter, antispam: update filter,' do
  context 'emtpy filter' do
    before(:each) do
      login_member
      Filter.stub(:read_filters).and_return [] 
      visit antispam_path
      Filter.stub(:read_filters).and_return [] 
      click_button 'Update'
    end

    it "should work" do
    end
  end

  context "folder error" do
    before(:each) do
      login_member
      Filter.stub(:read_filters).and_return [] 
      visit antispam_path
      Filter.stub(:read_filters).and_return [] 
      select "Enabled", :from => "Spam Filter"
    end

    it 'can only contain letters or numbers' do
      fill_in 'Folder', :with => '!"#'
      click_button 'Update'
      li(:folder,0).should have_error("can only contain letters or numbers")
    end

    it 'cannot be blank' do
      fill_in 'Folder', :with => ''
      click_button 'Update'
      li(:folder,0).should have_error("can only contain letters or numbers")
    end
  end

  context 'without forward' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters("")
      @member = login_member
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      fill_in 'Folder', :with => 'Spam'
      click_button 'Update'
    end
    
    it "the spam selector is empty" do
      value("Spam Filter").should eq 'X-Barracuda-Spam-Flag' 
    end

    it "the folder field is default to Junk" do
      value("Folder").should eq 'Spam'
    end

    it "shows a flash message" do
      page.should have_notice('Anti-Spam Settings successfully updated.')
    end

    it "gets saved to .procmailrc" do
      Filter.read_filters(@member.id,"correct").map(&:to_file).should eq [":0:\n* ^X-Barracuda-Spam-Flag: YES\n.Spam/"]
    end
  end

  context 'with forward' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      @member = login_member
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      Filter.read_filters(@member.id,"correct").map(&:to_file).should eq [":0\n*\n!example@email.com",":0:\n* ^X-Barracuda-Spam-Flag: YES\n.Junk/"]
    end
  end

  context 'with antispam' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag: YES\n.Junk/")
      @member = login_member
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      Filter.read_filters(@member.id,"correct").map(&:to_file).should eq [":0:\n* ^X-Barracuda-Spam-Flag: YES\n.Junk/"]
    end
  end

  context 'with antispam&forward' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag: YES\n.Junk/\n\n:0\n*\n!example@email.com")
      @member = login_member
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      Filter.read_filters(@member.id,"correct").map(&:to_file).should eq [":0:\n* ^X-Barracuda-Spam-Flag: YES\n.Junk/",":0\n*\n!example@email.com"]
    end
  end
end
