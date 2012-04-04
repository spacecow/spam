require 'spec_helper'

describe Action do
  describe "#is_destination?" do
    correct = ["!example@email.com",".Junk/"]
    non_correct = ["Junk/", ".Junk", "Junk"]
    
    correct.each do |s|
      it "YES: #{s}" do
        Action.is_destination?(s).should be_true
      end
    end

    non_correct.each do |s|
      it "NO: #{s}" do
        Action.is_destination?(s).should be_false
      end
    end
  end

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
        false.should be_true
      rescue RuntimeError => e
        e.message.should eq "Operation is wrongly formatted: ':0cs'."
      end
    end
  end

  describe "#factory" do
    it "cannot create two actions" do
      begin
        Action.factory(":0",["!example@email.com","!more@email.com"])
        false.should be_true
      rescue RuntimeError => e
        e.message.should eq "Can only create one action."
      end
    end

    it "must have a valid email address" do
      action = Action.factory(":0",["!exampleemail.com"])
      action.errors[:destination].should eq ["is invalid"]
    end
  
    it "must begin with an exclamation mark" do
      begin
        Action.factory(":0",["example@email.com"])
        false.should be_true
      rescue RuntimeError => e
        e.message.should eq "Destination is wrongly formatted: 'example@email.com'."
      end
    end

    context "create one forward action" do
      before(:each) do
        @a = ["!example@email.com"]
        @action = Action.factory(":0",@a)
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

    context "create one move action" do
      before(:each) do
        @a = [".Junk/"]
        @action = Action.factory(":0:",@a)
      end

      it "the return is of type action" do
        @action.class.should eq Action.new.class
      end

      it "the destination is filled in" do
        @action.destination.should eq "Junk"
      end

      it "the operation is filled in" do
        @action.operation.should eq Action::MOVE_MESSAGE_TO
      end

      it "action is stripped" do
        @a.should be_empty 
      end
    end
  end
end
