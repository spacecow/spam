require 'spec_helper'

describe Rule do
  describe "#forward_factory" do
    it "must begin with an asterisk" do
      begin
        Rule.forward_factory(["whatever"])
      rescue RuntimeError => e
        e.message.should eq "Rule is wrongly formatted: 'whatever'."
      end
    end

    it "there can only be one rule" do
      begin
        Rule.forward_factory(["*","*"])
      rescue RuntimeError => e
        e.message.should eq "Can only create one rule."
      end
    end

    context "create one rule" do
      before(:each) do
        @a = ["*","!example@email.com"]
        @rule = Rule.forward_factory(@a)
      end

      it "the return is of type rule" do
        @rule.class.should eq Rule.new.class
      end

      it "its section is nil" do
        @rule.section.should be_nil
      end

      it "its parts is nil" do
        @rule.part.should be_nil
      end

      it "its content is nil" do
        @rule.content.should be_nil
      end

      it "rule is stripped" do
        @a.should eq ["!example@email.com"]
      end
    end
  end
end
