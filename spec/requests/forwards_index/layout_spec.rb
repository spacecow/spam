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

  context 'layout, with forward filters', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      login_member
    end

    it "has five fields for address input" do
      form.lis_no('address').should be(5)
    end

    it "address field 1 should contain an address" do
      value("Address 1").should eq "example@email.com"
    end

    4.times do |i|
      it "address field #{i+2} should be empty" do
        value("Address #{i+2}").should be_nil
      end
    end
  end #layout, with filters

  context 'layout, with antispam filters', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag: YES\n.Junk/")
      login_member
    end

    it "has five fields for address input" do
      form.lis_no('address').should be(5)
    end

    5.times do |i|
      it "address field #{i+1} should be empty" do
        value("Address #{i+1}").should be_nil
      end
    end
  end #layout, with filters

  context 'layout, with forward&antispam filters', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0c\n*\n!example@email.com\n\n:0:\n* ^X-Spam-Flag: YES\n.Junk/")
      login_member
    end

    it "address field 1 should contain an address" do
      value("Address 1").should eq "example@email.com"
    end

    it "has five fields for address input" do
      form.lis_no('address').should be(5)
    end

    4.times do |i|
      it "address field #{i+2} should be empty" do
        value("Address #{i+2}").should be_nil
      end
    end

    it "keep a copy on the server checkbox should be checked" do
      find_field("Keep a copy on the server").should be_checked
    end
  end #layout, with forward&antispam filters

  context 'error layout, with antispam filters', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag: YES\n.Junk/")
      login_member
      fill_in 'Address 1', with:'exampleemail.com'
      click_button 'Update'
    end

    it "has five fields for address input" do
      form.lis_no('address').should be(5)
    end

    it "address field 1 should contain an address" do
      value("Address 1").should eq "exampleemail.com"
    end

    4.times do |i|
      it "address field #{i+2} should be empty" do
        value("Address #{i+2}").should be_nil
      end
    end
  end #layout, with filters

  context 'update empty fields', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters("")
      login_member
      click_button 'Update'
    end

    it "should not produce an error" do
    end
  end

  context 'update fields with invalid email address', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters("")
      login_member
      fill_in 'Address 1', with:'exampleemail.com'
      check("Keep a copy on the server")
      click_button 'Update'
    end

    it "shows the error" do
      li(:address,0).should have_error("is invalid")
    end

    it "address field 1 should contain the invalid address" do
      value("Address 1").should eq "exampleemail.com"
    end

    it "has five fields for address input" do
      form.lis_no('address').should be(5)
    end

    4.times do |i|
      it "address field #{i+2} should be empty" do
        value("Address #{i+2}").should be_nil
      end
    end

    it "the Kepp a copy on the server check box should be checked" do
      find_field("Keep a copy on the server").should be_checked
    end

  end

  context 'update filters without copy', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      login_member
      fill_in 'Address 2', with:'example2@email.com'
      click_button 'Update'
    end

    it "the Keep a copy on the server check box should not be checked" do
      find_field("Keep a copy on the server").should_not be_checked
    end

    it "shows a flash message" do
      page.should have_notice('Forward Settings successfully updated.')
    end

    it "address field 1 should contain an address" do
      value("Address 1").should eq "example@email.com"
    end

    it "address field 2 should contain an address" do
      value("Address 2").should eq "example2@email.com"
    end

    3.times do |i|
      it "address field #{i+3} should be empty" do
        value("Address #{i+3}").should be_nil
      end
    end
  end #update filters without copy

  context 'update filter with copy', filters:true do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      login_member
      fill_in 'Address 2', with:'example2@email.com'
      check("Keep a copy on the server")
      click_button 'Update'
    end

    it "the Keep a copy on the server check box should be checked" do
      find_field("Keep a copy on the server").should be_checked
    end

    it "shows a flash message" do
      page.should have_notice('Forward Settings successfully updated.')
    end

    it "address field 1 should contain an address" do
      value("Address 1").should eq "example@email.com"
    end

    it "address field 2 should contain an address" do
      value("Address 2").should eq "example2@email.com"
    end

    3.times do |i|
      it "address field #{i+3} should be empty" do
        value("Address #{i+3}").should be_nil
      end
    end
  end #update filters with copy
end
