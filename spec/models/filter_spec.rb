require 'spec_helper'

describe Filter, focus:true do
  describe "#read/write_procmail" do
    before(:each) do
      Filter.unstub(:read_forward_filters)
    end

    context "works" do
      it "without trailing enter" do
        Filter.write_forward_filters(":0\n*\n!example@email.com")
      end

      it "with trailing enter" do
        Filter.write_forward_filters(":0\n*\n!example@email.com\n")
      end

      after(:each) do
        Filter.read_forward_filters.should eq ":0\n*\n!example@email.com\n"
      end
    end
  end

  describe "#forward_factory" do
    context "create one filter" do
      before(:each) do
        @filter = Filter.send(:factory,":0\n*\n!example@email.com")
      end

      it "the return is of type filter" do
        @filter.class.should eq Filter.new.class
      end
    end
  end
end
