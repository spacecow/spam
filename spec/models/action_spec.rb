require 'spec_helper'

describe Action do
  describe "#get_operation" do
    it "is a forward message to" do
      Action.get_operation(":0").should eq Action::FORWARD_MESSAGE_TO
    end
    it "is a forward copy to" do
      Action.get_operation(":0c").should eq Action::FORWARD_COPY_TO
    end
    it "cannot be anything else than forward message/copy to" do
      begin
        Action.get_operation(":0cs")
      rescue RuntimeError => e
        e.message.should eq "Operation is wrongly formatted: ':0cs'."
      end
    end
  end

  describe "#forward_factory" do
    it "cannot create two actions" do
      begin
        Action.forward_factory(":0",["!example@email.com","!more@email.com"])
      rescue RuntimeError => e
        e.message.should eq "Can only create one action."
      end
    end

    it "must begin with an exclamation mark" do
      begin
        Action.forward_factory(":0",["example@email.com"])
      rescue RuntimeError => e
        e.message.should eq "Action is wrongly formatted: 'example@email.com'."
      end
    end

    context "create one action" do
      before(:each) do
        @a = ["!example@email.com"]
        @action = Action.forward_factory(":0",@a)
      end

      it "the return is of type action" do
        @action.class.should eq Action.new.class
      end

      it "the destination is filled in" do
        @action.destination.should eq "example@email.com"
      end

      it "the operation is filled in" do
        @action.operation.should eq Action::FORWARD_MESSAGE_TO
      end

      it "action is stripped" do
        @a.should be_empty 
      end
    end
  end
end
