require 'spec_helper'

describe Filter do
  context "read prolog from .procmailrc" do
    before(:each) do
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      Filter.unstub(:read_filters)
      @filters, @prolog = Filter.read_filters
    end

    it "the prolog is returned" do
      @prolog.should eq "SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log"
    end

    it "prolog is saved together with the filters" do
      Filter.write_filters(@filters.to_file,@prolog)
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0:\n* ^X-Spam-Flag:.*YES\n.Junk/"
      prolog.should eq "SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log"
    end
  end

  describe "#read/write medium anti spam filters" do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters("")
    end

    context "works" do
      it "without trailing enter" do
        Filter.write_filters(":0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      end

      it "with trailing enter" do
        Filter.write_filters(":0\n*\n!example@email.com\n")
      end

      it "" do
        Filter.write_filters(
          Filter.factory_forward_message("example@email.com").to_file
        )
      end

      after(:each) do
        filters, prolog = Filter.read_filters
        filters.should eq [Filter.last]
      end
    end
  end

  describe "#read/write forward filters" do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.write_filters("")
    end

    context "works" do
      it "without trailing enter" do
        Filter.write_filters(":0\n*\n!example@email.com")
      end

      it "with trailing enter" do
        Filter.write_filters(":0\n*\n!example@email.com\n")
      end

      it "" do
        Filter.write_filters(
          Filter.factory_forward_message("example@email.com").to_file
        )
      end

      after(:each) do
        filters, prolog = Filter.read_filters
        filters.should eq [Filter.last]
      end
    end
  end

  describe "#spam_filter_factory" do
    context "create a medium level spam filter with #factory_anti_spam_medium" do
      before(:each) do
        @filter = Filter.factory_anti_spam_medium
      end

      it "the return is of type filter" do
        @filter.class.should eq Filter.new.class
      end

      it "filter has a rule" do
        @filter.rules.should eq [Rule.last]
      end

      it "the rule section is filled in" do
        Rule.last.section.should eq Rule::X_SPAM_FLAG
      end

      it "the rule part is filled in" do
        Rule.last.part.should eq Rule::BEGINS_WITH 
      end

      it "the rule content is filled in" do
        Rule.last.content.should eq 'YES'
      end

      it "filter has an action" do
        @filter.actions.should eq [Action.last]
      end

      it "the action destination is filled in" do
        Action.last.destination.should eq "Junk"
      end

      it "the action operation is filled in" do
        Action.last.operation.should eq Action::MOVE_MESSAGE_TO
      end

      it "correct #to_file method" do
        @filter.to_file.should eq ":0:\n* ^X-Spam-Flag:.*YES\n.Junk/"
      end
    end

    context "create a high level spam filter with #factory_anti_spam_medium" do
      before(:each) do
        @filter = Filter.factory_anti_spam_high
      end

      it "the return is of type filter" do
        @filter.class.should eq Filter.new.class
      end

      it "filter has a rule" do
        @filter.rules.should eq [Rule.last]
      end

      it "the rule section is filled in" do
        Rule.last.section.should eq Rule::X_BARRACUDA_SPAM_FLAG
      end

      it "the rule part is filled in" do
        Rule.last.part.should eq Rule::BEGINS_WITH 
      end

      it "the rule content is filled in" do
        Rule.last.content.should eq 'YES'
      end

      it "filter has an action" do
        @filter.actions.should eq [Action.last]
      end

      it "the action destination is filled in" do
        Action.last.destination.should eq "Junk"
      end

      it "the action operation is filled in" do
        Action.last.operation.should eq Action::MOVE_MESSAGE_TO
      end

      it "correct #to_file method" do
        @filter.to_file.should eq ":0:\n* ^X-Barracuda-Spam-Flag:.*YES\n.Junk/"
      end
    end
  end

  describe "#forward_factory" do
    it "filters must have space between them" do
      begin
        Filter.send(:abstract_factory,":0\n*\n!example@email.com\n:0\n*\n!example@email.com")
      rescue RuntimeError => e
        e.message.should eq "Filters are wrongly separated."
      end
    end

    context "create a forward message filter with #factory_message_forward" do
      before(:each) do
        @filter = Filter.factory_forward_message("example@email.com")
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

      it "correct #to_file method" do
        @filter.to_file.should eq ":0\n*\n\!example@email.com"
      end
    end

    context "create a forward copy filter with #factory_copy_forward" do
      before(:each) do
        @filter = Filter.factory_forward_copy("example@email.com")
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
        Action.last.operation.should eq Action::FORWARD_COPY_TO
      end

      it "correct #to_file method" do
        @filter.to_file.should eq ":0c\n*\n\!example@email.com"
      end
    end

    context "create a message forward filter with #factory" do
      before(:each) do
        filters, prolog = Filter.send(:abstract_factory,":0\n*\n!example@email.com")
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
        @filters, prolog = Filter.send(:abstract_factory,":0c\n*\n!example@email.com\n\n:0\n*\n!example@gmail.com")
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
        @filter = Filter.send(:abstract_factory,":0\n*\n!example@email.com\n\n:0\n*\n!example@email.com")
      rescue RuntimeError => e
        e.message.should eq "All filters but the last must have the copy operator."
      end
    end
  end
end
