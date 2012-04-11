require 'spec_helper'

describe 'Filter, antispam: layout,' do
  context 'without filters' do
    before(:each) do
      login_member
      Filter.stub(:read_filters).and_return [[],""] 
      visit filter_path
    end

    it "has a title" do
      page.should have_title('Anti Spam Settings for member')
    end

    it "has only one field for antispam input" do
      form.lis_no(:antispam).should be(1) 
    end

    it "the spam selector is empty" do
      value("Spam Filter").should be_blank 
    end

    it "the spam selector has options" do
      options("Spam Filter").should eq "BLANK, Enable"
    end

    it "the folder field is default to Junk" do
      value("Folder").should eq 'Junk'
    end

    it "has a fields for address input, but it is hidden" do
      form.lis_no('forward').should be(0) 
      form.lis_no('hide').should be(0) 
    end

    it "has an update button" do
      form.should have_button("Update") 
    end
  end

  context 'with forward filters' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0\n*\n!example@email.com")
      login_member
      visit filter_path
    end

    it "layout" do
      #has only one field for antispam input
      form.lis_no(:antispam).should be(1) 
      #has a fields for address input, but it is hidden
      form.lis_no('forward').should be(1) 
      form.lis_no('hide').should be(1) 
    end
  end

  context 'with antispam filter' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0:\n* ^X-Spam-Flag:.*YES\n.Spam/")
      login_member
      visit filter_path
    end

    it "layout" do
      #the spam selector is selected
      value("Spam Filter").should eq 'X-Spam-Flag' 
      #the folder field is default to Junk
      value("Folder").should eq 'Spam'
      #has only one field for antispam input
      form.lis_no(:antispam).should be(1) 
      #has a fields for address input, but it is hidden
      form.lis_no('forward').should be(0) 
      form.lis_no('hide').should be(0) 
    end
  end

  context 'with forward&antispam filters' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters(":0\n*\n!example@email.com\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      login_member
      visit filter_path
    end

    it "layout" do
      #has only one field for antispam input
      form.lis_no(:antispam).should be(1) 
      #has a fields for address input, but it is hidden
      form.lis_no('forward').should be(1) 
      form.lis_no('hide').should be(1) 
    end
  end

  it 'one should not be able to have two antispam filters'
end
