require 'rubygems'
require 'pp'

class KindleClippingsParser
  
  def initialize(file_path)
    @contents = load(file_path)
    @entries  = parse_entries
  end
  
  def load(file_path)
    file = File.open(file_path)
    delete_returns(file.read)
  end
  
  def delete_returns(str)
    str = str.gsub(/[\r]/,"")
  end

  def parse_entries
    #split by separator
    separator   = "="*10
    raw_entries = @contents.split(separator)
    raw_entries.map! { |entry| trim_leading_newline(entry) }
    parsed_entries = []
    
    #Author
    #eg: "For Whom the Bell Tolls (Ernest Hemingway)"
    parenthesis_regexp = /[\(\)]/ #matches ( or )
    #Matches: "(Ernest Hemingway)"
    author_regexp =  /(\()        (?# opening parenthesis)
                      [^\)^\(]*?  (?# anything that is not a parenthesis - non-greedy)
                      (\))        (?# closing parenthesis)
                      \Z          (?# this must be at the end of the line because book title may contain parenthesis)
                     /x
    
    #Date Added
    #eg: "- Highlight Loc. 10177-78 | Added on Sunday, October 24, 2010, 04:32 PM"       
    days = %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday}.join("|")
    months = %w{January February March April May June July August September October November December}.join("|")
    #Matches: "Sunday, October 24, 2010, 04:32 PM"
    date_regexp = /(#{days}),\s           (?# "Monday, " days followed by comma and a space)
                   (#{months})\s\d{2},\s  (?# "January 05, " month followed by comma and a space)
                   \d{4},\s               (?# "2011, " year followed by comma and space)
                   \d{2}:\d{2}\s          (?# "02:24 " time followed by a space)
                   (AM|PM)                (?# "AM")
                   \Z                     (?# End of string)
                  /x
     
    #Entry Type and Position:
    #eg: "- Highlight Loc. 10177-78 | Added on Sunday, October 24, 2010, 04:32 PM"            
    #Matches: "Highlight"
    entry_type_regexp = /(?<=-\s)         (?# look behind for "- " this marks the beginning of the line)
                         (Highlight|Note) (?# match either Highlight or Note, the two types of entries to clippings)
                        /x
    #Matches: "0177-78" 
    highlight_position_regexp = /(?<=Loc\.\s) (?# look behind to match "Loc. " which appears before the position number)
                                 \d*          (?# match any number of digits - books can be any length)
                                 ([-]\d*)?    (?# may have a - followed by another number of arbitrary length)
                                 (?=\s|)      (?# lastly just to be safe double check that it is followed by a " | ")
                                /x
    
    raw_entries.each do |entry|
      lines = entry.split(/\n/)
      if lines.length > 0
        #author
        author = lines[0].match(author_regexp).to_a.first
        author.gsub!(parenthesis_regexp,"") unless author.nil?
        
        #title
        lines.first.gsub!(author_regexp,"") #clear out the author to simplify getting the title
        title = lines.first.strip
        
        #highlight type
        entry_type = lines[1].match(entry_type_regexp).to_a.first
        
        #highlight location
        highlight_location = lines[1].match(highlight_position_regexp).to_a.first
        
        #added date
        date = lines[1].match(date_regexp).to_a.first
        
        #contents
        contents = lines[2..lines.length].join
        
        #push to entries
        parsed_entries.push( { :title  => title,
                               :author => author,
                               :date => date,
                               :type => entry_type,
                               :location => highlight_location,
                               :contents => contents } )
      end
    end
    
    parsed_entries
  end
  
  def trim_leading_newline(str)
    str.gsub(/\A\n/,"")
  end
  
  def get_dictionary_entries(dictionary = "The New Oxford American Dictionary")
  end
  
  def get_entries_by_book_name(book_name)
    
  end
  
  def get_entries_containing_string(str)
    
  end
  
end

parser = KindleClippingsParser.new("My Clippings.txt")
#puts parser.get_dictionary_entries()