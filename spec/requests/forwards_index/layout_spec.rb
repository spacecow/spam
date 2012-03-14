require 'spec_helper'

describe 'Forwards, index:' do
  context 'layout, without forwards' do
    before(:each) do
      login_member
      visit forwards_path
    end

    it "has a title" do
      page.should have_title('Mail Forward Settings for member')
    end

    it "has five fields for address input" do
      form.lis_no('address').should be(5)
    end

    5.times do |i|
      it "address field #{i+1} should be empty" do
        value("Address #{i+1}").should be_nil
      end
    end

    it "the Kepp a copy on the server check box should be unchecked" do
      find_field("Keep a copy on the server").should_not be_checked
    end

    it "a button: Add Address Field should exist" do
      form.should have_button("Add Address Field")
    end

    it "a button: Update should exist" do
      form.should have_button("Update")
    end
  end #layout, without forwards

  context 'layout, with forwards', focus:true do
    before(:each) do
      Forward.unstub(:load)
      load_procmail(":0\n*\n!example@email.com")
      login_member
      visit forwards_path
    end

    it "" do
    end
  end
end
