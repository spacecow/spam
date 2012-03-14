require 'spec_helper'

describe 'Filters, index:' do
  context "layout without filters" do
    before(:each) do
      login
      visit filters_path
    end

    it "has a title" do
      page.should have_title('Mail Filter Settings for test')
    end

    it "has a bottom links section" do
      page.should have_div('bottom_links')
    end

    it "has a link to a new filter in the bottom links section" do
      bottom_links.should have_link('New Filtering Rule')
    end
  end 

  context "links without filters" do
    before(:each) do
      login
      visit filters_path
    end

    it "new filtering rule redirects to the new filter page" do
      bottom_links.click_link 'New Filtering Rule'
      current_path.should eq new_filter_path
    end
  end
end
