require 'spec_helper'

describe Rule do
  describe "#separate_attributes" do
    describe "medium level anti spam rule" do
      before(:each) do
        s = "* ^X-Spam-Flag:.*YES"
        (@section, @part, @content) = Rule.separate_attributes(s)
      end

      it "section is set to x spam flag" do
        @section.should eq Rule::X_SPAM_FLAG
      end

      it "part is set to begins with" do
        @part.should eq Rule::BEGINS_WITH
      end

      it "content is set to yes" do
        @content.should eq 'YES'
      end
    end

    describe "high level anti spam rule" do
      before(:each) do
        s = "* ^X-Barracuda-Spam-Flag:.*YES"
        (@section, @part, @content) = Rule.separate_attributes(s)
      end

      it "section is set to x barracuda spam flag" do
        @section.should eq Rule::X_BARRACUDA_SPAM_FLAG
      end

      it "part is set to begins with" do
        @part.should eq Rule::BEGINS_WITH
      end

      it "content is set to yes" do
        @content.should eq 'YES'
      end
    end
  end

  describe "#anti_spam_factory" do
    context "create a medium level anti spam rule" do
      before(:each) do
        @a = ["* ^X-Spam-Flag:.*YES",".Junk/"]
        @rule = Rule.factory(@a)
      end

      it "the return is of type rule" do
        @rule.class.should eq Rule.new.class
      end

      it "its section is set to x spam flag" do
        @rule.section.should eq Rule::X_SPAM_FLAG 
      end

      it "its parts is set to begins with" do
        @rule.part.should eq Rule::BEGINS_WITH 
      end

      it "its content is set to yes" do
        @rule.content.should eq "YES" 
      end

      it "rule is stripped" do
        @a.should eq [".Junk/"]
      end
    end

    context "create a high level anti spam rule" do
      before(:each) do
        @a = ["* ^X-Barracuda-Spam-Flag:.*YES",".Junk/"]
        @rule = Rule.factory(@a)
      end

      it "the return is of type rule" do
        @rule.class.should eq Rule.new.class
      end

      it "its section is set to x spam flag" do
        @rule.section.should eq Rule::X_BARRACUDA_SPAM_FLAG 
      end

      it "its parts is set to begins with" do
        @rule.part.should eq Rule::BEGINS_WITH 
      end

      it "its content is set to yes" do
        @rule.content.should eq "YES" 
      end

      it "rule is stripped" do
        @a.should eq [".Junk/"]
      end
    end
  end

  describe "#forward_factory" do
    it "must begin with an asterisk" do
      begin
        Rule.factory(["whatever"])
      rescue RuntimeError => e
        e.message.should eq "Rule is wrongly formatted: 'whatever'."
      end
    end

    it "there can only be one rule" do
      begin
        Rule.factory(["*","*"])
      rescue RuntimeError => e
        e.message.should eq "Can only create one rule."
      end
    end


    context "create a forward rule" do
      before(:each) do
        @a = ["*","!example@email.com"]
        @rule = Rule.factory(@a)
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
