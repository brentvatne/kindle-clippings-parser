$LOAD_PATH.unshift Dir.pwd unless $LOAD_PATH.include? Dir.pwd

require 'rspec'
require 'kindle_clippings_parser'

#check out rcov

describe KindleClippingsParser do

  before(:each) do
    @parser = KindleClippingsParser.new('path')
    @sample_content = "A short history of nearly everything (Bill Bryson)
- Highlight Loc. 2254-61 | Added on Saturday, February 13, 2010, 09:45 AM

Perhaps the most arresting of quantum improbabilitie etc.
==========
What Technology Wants (Kevin Kelly)
- Highlight Loc. 1432-36 | Added on Wednesday, November 03, 2010, 05:43 PM

Keep in mind that an enduring global fertility slow population decline?
==========" 
  end

  #acceptance tests are what a non-programmer would expect out of the software
  describe "acceptance tests" do
    it "should return an array of hashes with author, title, type, location, and contents keys" do
      #anytime you're interacting with something outside of your library maybe you should stub
      File.stub(:read).and_return(@sample_content)
      entry = @parser.entries.first
      expected_result = { :author   => "Bill Bryson",
                          :title    => "A short history of nearly everything",
                          :type     => "Highlight",
                          :location => "2254-61",
                          :contents => "Perhaps the most arresting of quantum improbabilitie etc." }
     entry.each do |key,value| 
       value.should == expected_result[key]
     end
    end
  end

  it "should " do 

  end

end
