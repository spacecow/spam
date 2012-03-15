require 'spec_helper'

describe Filter do
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
    it "filters must have space between them" do
      begin
        Filter.send(:factory,":0\n*\n!example@email.com\n:0\n*\n!example@email.com")
      rescue RuntimeError => e
        e.message.should eq "Filters are wrongly separated."
      end
    end

    context "create one filter" do
      before(:each) do
        filters = Filter.send(:factory,":0\n*\n!example@email.com")
        @filter = filters.first
      end

      it "the return is of type filter" do
        @filter.class.should eq Filter.new.class
      end

      it "filter has a rule" do
        @filter.rules.should eq [Rule.last]
      end

      it "filter has an action" do
        @filter.actions.should eq [Action.last]
      end

      it "the action destination is filled in" do
        Action.last.destination.should eq "example@email.com"
      end

      it "the action operation is filled in" do
        Action.last.operation.should eq Action::FORWARD_MESSAGE_TO
      end
    end

    context "create two filters" do
      before(:each) do
        @filters = Filter.send(:factory,":0c\n*\n!example@email.com\n\n:0\n*\n!example@gmail.com")
      end

      it "the return is of type filter" do
        @filters.map(&:class).should eq [Filter.new.class,Filter.new.class]
      end

      it "filters have a rule" do
        @filters.map(&:rules).flatten.should eq [Rule.first,Rule.last]
      end

      it "filters have an action" do
        @filters.map(&:actions).flatten.should eq [Action.first,Action.last]
      end

      it "the action destination is filled in" do
        Action.all.map(&:destination).should eq ["example@email.com","example@gmail.com"]
      end

      it "the action operation is filled in" do
        Action.all.map(&:operation).should eq [Action::FORWARD_COPY_TO,Action::FORWARD_MESSAGE_TO]
      end
    end

    it "if more than one filter, all but last must have copy operation" do
      begin
        @filter = Filter.send(:factory,":0\n*\n!example@email.com\n\n:0\n*\n!example@email.com")
      rescue RuntimeError => e
        e.message.should eq "All filters but the last must have the copy operator."
      end
    end
  end
end
