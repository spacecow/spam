require 'spec_helper'

describe 'Move forwarding, layout:' do
  context ".forward contains gibberish" do
    before(:each) do
      Filter.unstub(:write_forward)
      Filter.write_forward("test","password","gibberish")
      Filter.unstub(:read_forward)
      login_member
    end

    it "shows a question to the user" do  
      page.should have_content(".forward is wrongly_formatted: 'gibberish'.")
    end
  end

  context ".forward contains an email address" do
    before(:each) do
      Filter.unstub(:write_forward)
      Filter.write_forward("test","password","example@email.com")
      Filter.unstub(:read_forward)
      login_member
    end

    it "layout" do
      #value("Address 1").should eq "example@email.com"
      #shows a question to the user
      page.should have_content("To continue, you need to move your .forward entries into .procmailrc.")
      #has a move button
      page.should have_button("Move them")
    end
  end

  context "move entries in .forward to .procmailrc" do
    before(:each) do
      Filter.unstub(:write_forward)
      Filter.write_forward("test","password","example@email.com\nexample2@email.com")
      Filter.unstub(:read_forward)
      login_member
      Filter.unstub(:write_filters)
      Filter.unstub(:read_filters)
      click_button 'Move them'
    end

    it "layout" do
      #address field 1 should contain an address"
      value("Address 1").should eq "example@email.com"
      value("Address 2").should eq "example2@email.com"
    end
  end

  context "add entries in .forward to .procmailrc" do
    before(:each) do
      Filter.unstub(:write_forward)
      Filter.write_forward("test","password","example@email.com")
      Filter.unstub(:read_forward)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0\n*\n!example2@email.com")
      Filter.unstub(:read_filters)
      login_member
      click_button 'Move them'
    end

    it "layout" do
      #address field 1&2 should contain an address"
      value("Address 1").should eq "example@email.com"
      value("Address 2").should eq "example2@email.com"
    end
  end
end
