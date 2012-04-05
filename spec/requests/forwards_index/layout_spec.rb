require 'spec_helper'

describe 'Filter, forward:' do
  context 'layout, without filters' do
    before(:each) do
      login_member
    end

    it "has a title" do
      page.should have_title('Mail Forward Settings for member')
    end

    it "has five fields for address input" do
      form.lis_no(:address).should be(5)
    end

    5.times do |i|
      it "address field #{i+1} should be empty" do
        value("Address #{i+1}").should be_nil
      end
    end

    it "the Kepp a copy on the server check box should be unchecked" do
      find_field("Keep a copy on the server").should_not be_checked
    end

    it "a button: Add Address Field should no t exist" do
      form.should_not have_button("Add Address Field")
    end

    it "a button: Update should exist" do
      form.should have_button("Update")
    end
  end #layout, without filters

  context 'if .forward is wrongly formatted, an error page will show' do
    before(:each) do
      Filter.unstub(:read_forward)
      login_member('wrong')
    end

    it "has a title" do
      page.should have_title('Error')
    end
  end

  context 'layout, with forward filters&prolog', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0\n*\n!example@email.com")
      login_member
    end

    it "layout" do
      #has five fields for address input"
      form.lis_no('address').should be(5)
      #address field 1 should contain an address"
      value("Address 1").should eq "example@email.com"
      #4 address fields should be empty
      4.times do |i|
        value("Address #{i+2}").should be_nil
      end
    end
  end #layout, with forward filters&prolog

  context 'layout, with antispam filters&prolog', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      login_member
    end

    it "layout" do
      #has five fields for address input"
      form.lis_no('address').should be(5)
      #5 address fields should be empty
      5.times do |i|
        value("Address #{i+1}").should be_nil
      end
    end
  end #layout, with antispam filters&prolog 

  context 'layout, with forward&antispam filters', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0c\n*\n!example@email.com\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      login_member
    end

    it "layout" do
      #address field 1 should contain an address
      value("Address 1").should eq "example@email.com"
      #has five fields for address input
      form.lis_no('address').should be(5)
      #4 address fields should be empty
      4.times do |i|
        value("Address #{i+2}").should be_nil
      end
      #keep a copy on the server checkbox should be checked
      find_field("Keep a copy on the server").should be_checked
    end
  end #layout, with forward&antispam filters

  context 'update empty fields', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters("")
      login_member
      click_button 'Update'
    end

    it "should not produce an error" do
    end
  end

  context 'error layout, with antispam filters', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      login_member
      fill_in 'Address 1', with:'exampleemail.com'
      check("Keep a copy on the server")
      click_button 'Update'
    end

    it "layout" do
      #has five fields for address input"
      form.lis_no('address').should be(5)
      #address field 1 should contain an address
      value("Address 1").should eq "exampleemail.com"
      #address field 1 should show an error
      li(:address,0).should have_error("is invalid")
      #4 address fields should be empty
      4.times do |i|
        value("Address #{i+2}").should be_nil
      end
      #keep a copy on the server checkbox should be checked
      find_field("Keep a copy on the server").should be_checked
    end
  end #error layout, with antispam filters

  context 'update filters without copy', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      login_member
      fill_in 'Address 2', with:'example2@email.com'
      click_button 'Update'
    end

    it "layout" do
      #the Keep a copy on the server check box should not be checked
      find_field("Keep a copy on the server").should_not be_checked
      #shows a flash message
      page.should have_notice('Forward Settings successfully updated.')
      #address field 1 should contain an address
      value("Address 1").should eq "example@email.com"
      #address field 2 should contain an address
      value("Address 2").should eq "example2@email.com"
      #3 address fields should be empty
      3.times do |i|
        value("Address #{i+3}").should be_nil
      end
    end
  end #update filters without copy

  context 'update filter with copy', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      login_member
      fill_in 'Address 2', with:'example2@email.com'
      check("Keep a copy on the server")
      click_button 'Update'
    end

    it "layout" do
      #the Keep a copy on the server check box should be checked
      find_field("Keep a copy on the server").should be_checked
      #shows a flash message
      page.should have_notice('Forward Settings successfully updated.')
      #address field 1 should contain an address
      value("Address 1").should eq "example@email.com"
      #address field 2 should contain an address
      value("Address 2").should eq "example2@email.com"
      #3 address fields should be empty
      3.times do |i|
        value("Address #{i+3}").should be_nil
      end
    end
  end #update filters with copy
end
