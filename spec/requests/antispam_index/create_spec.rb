require 'spec_helper'

describe 'Filter, antispam: update filter,' do
  context 'emtpy filter' do
    before(:each) do
      login_member
      Filter.stub(:read_filters).and_return [[],""] 
      visit antispam_path
      Filter.stub(:read_filters).and_return [[],""] 
      click_button 'Update'
    end

    it "should work" do
    end
  end

  context "folder error" do
    before(:each) do
      login_member
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0\n*\n!example@email.com")
      #Filter.stub(:read_filters).and_return [[],""] 
      visit antispam_path
      #Filter.stub(:read_filters).and_return [[],""] 
      select "Enabled", :from => "Spam Filter"
    end

    it "has only one field for antispam input on the error page" do
      fill_in 'Folder', :with => '!"#'
      click_button 'Update'
      form.lis_no(:antispam).should be(1) 
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

  context 'without forward filters' do
    before(:each) do
      login_member
      Filter.stub(:read_filters).and_return [[],""] 
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      fill_in 'Folder', :with => 'Spam'
    end
    
    it "the spam selector is empty" do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      click_button 'Update'
      value("Spam Filter").should eq 'X-Barracuda-Spam-Flag' 
    end

    it "the folder field is changed" do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      click_button 'Update'
      value("Folder").should eq 'Spam'
    end

    it "shows a flash message" do
      Filter.stub(:read_filters).and_return [[],""] 
      click_button 'Update'
      page.should have_notice('Anti-Spam Settings successfully updated.')
    end

    it "gets saved to .procmailrc" do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      click_button 'Update'
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0:\n* ^X-Barracuda-Spam-Flag:.*YES\n.Spam/"
    end
  end

  context 'with forward&prolog' do
    before(:each) do
      Filter.stub(:read_filters).and_return [[],""] 
      login_member
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0\n*\n!example@email.com")
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0\n*\n!example@email.com\n\n:0:\n* ^X-Barracuda-Spam-Flag:.*YES\n.Junk/"
      prolog.should eq "SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log"
    end
  end

  context 'with antispam' do
    before(:each) do
      Filter.stub(:read_filters).and_return [[],""] 
      login_member
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0:\n* ^X-Barracuda-Spam-Flag:.*YES\n.Junk/"
    end
  end

  context 'with antispam&forward' do
    before(:each) do
      Filter.stub(:read_filters).and_return [[],""] 
      login_member
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag:.*YES\n.Junk/\n\n:0\n*\n!example@email.com")
      visit antispam_path
      select "Enabled", :from => "Spam Filter"
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0:\n* ^X-Barracuda-Spam-Flag:.*YES\n.Junk/\n\n:0\n*\n!example@email.com"
    end
  end
end
