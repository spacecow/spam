require 'spec_helper'

describe 'Filter, forward: update,' do
  context 'with antispam filters&prolog' do
    before(:each) do
      Filter.unstub(:write_filters)
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      Filter.unstub(:read_filters)
      login_member
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0:\n* ^X-Spam-Flag:.*YES\n.Junk/"
      prolog.should eq "SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log"
    end
  end

  context 'with antispam&forward filters&prolog' do
    before(:each) do
      Filter.unstub(:read_filters)
      Filter.unstub(:write_filters)
      Filter.write_filters("SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/")
      login_member
      fill_in 'Address 1', with:'example@email.com'
      click_button 'Update'
    end

    it "gets saved to .procmailrc" do
      filters, prolog = Filter.read_filters
      filters.to_file.should eq ":0\n*\n!example@email.com\n\n:0:\n* ^X-Spam-Flag:.*YES\n.Junk/"
      prolog.should eq "SHELL=/bin/sh\nMAILDIR=$HOME/Maildir/\nLOGFILE=$HOME/procmail.log"
    end
  end

  context 'updates .forward' do
    before(:each) do
      login_member
      Filter.unstub(:read_forward)
      Filter.stub(:read_filters).and_return [[],[]] 
      fill_in 'Address 1', with:'example@email.com'
      click_button 'Update'
    end
    
    it "gets saved to .forward" do
      Filter.read_forward.should eq "\"|IFS=' ' && exec /usr/local/bin/procmail -f- || exit 75 #member\""
    end
  end
end
