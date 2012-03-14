require 'spec_helper'

describe 'Forwards, index:' do
  context 'layout, without forwards' do
  end

  it "has a title" do
    page.should have_title('Mail Forward Settings for admin')
  end
end
