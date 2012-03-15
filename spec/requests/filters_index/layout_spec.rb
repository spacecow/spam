require 'spec_helper'

describe 'Filters, index:' do
  context "layout without filters" do
    before(:each) do
      login_member
      visit filters_path
    end

    it "has a title" do
      page.should have_title('Mail Filter Settings for member')
    end
  end 
end
