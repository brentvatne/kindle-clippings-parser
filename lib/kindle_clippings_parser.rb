require 'rubygems'
require 'pp'

class KindleClippingsParser
  
  def initialize(file_path)
    @file_path = file_path
    @author_regexp =  /(\()        (?# opening parenthesis)
                       [^\)^\(]*?  (?# anything that is not a parenthesis - non-greedy)
                       (\))        (?# closing parenthesis)
                       \Z          (?# this must be at the end of the line because book title may contain parenthesis)
                      /x
  end
  
  def entries
    return @entries if @entries
    contents = load(@file_path)
    separator   = "="*10
    raw_entries = contents.split(separator)
    raw_entries.map! { |entry| trim_leading_newline(entry) }
    
    parsed_entries = []

    raw_entries.each do |entry|
      parsed_entries << parse_entry(entry)
    end
    
    @entries = parsed_entries
  end
  
  def load(file_path)
    contents = File.read(file_path)
    delete_returns(contents)
  end
  
  def delete_returns(str)
    str = str.gsub(/[\r]/,"")
  end
  
  #eg: "For Whom the Bell Tolls (Ernest Hemingway)"
  #Matches: "(Ernest Hemingway)"  
  def parse_author(entry)
    parenthesis_regexp = /[\(\)]/ #matches ( or )
    
    author = entry[0].match(@author_regexp).to_a.first || ""
    author.gsub!(parenthesis_regexp,"")              
    
    return author
  end
  
  #eg: "- Highlight Loc. 10177-78 | Added on Sunday, October 24, 2010, 04:32 PM" 
  #Matches: "Sunday, October 24, 2010, 04:32 PM" 
  def parse_date(entry)
    days = %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday}.join("|")
    months = %w{January February March April May June July August September October November December}.join("|")
    
    date_regexp = /(#{days}),\s           (?# "Monday, " days followed by comma and a space)
                   (#{months})\s\d{2},\s  (?# "January 05, " month followed by comma and a space)
                   \d{4},\s               (?# "2011, " year followed by comma and space)
                   \d{2}:\d{2}\s          (?# "02:24 " time followed by a space)
                   (AM|PM)                (?# "AM")
                   \Z                     (?# End of string)
                  /x
                  
    date = lines[1].match(date_regexp).to_a.first or ""
  end
  
  def parse_title(entry)
    entry.first.gsub!(@author_regexp,"") #clear out the author to simplify getting the title
    title = entry.first.strip    
  end
  
  #eg: "- Highlight Loc. 10177-78 | Added on Sunday, October 24, 2010, 04:32 PM"            
  #Matches: "Highlight"
  def parse_type(entry)
    entry_type_regexp = /(?<=-\s)         (?# look behind for "- " this marks the beginning of the line)
                         (Highlight|Note) (?# match either Highlight or Note, the two types of entries to clippings)
                        /x        
    #highlight type
    entry_type = entry[1].match(entry_type_regexp).to_a.first || ""
  end
  
  #Matches: "0177-78" 
  def parse_location(entry)
    highlight_position_regexp = /(?<=Loc\.\s) (?# look behind to match "Loc. " which appears before the position number)
                                 \d*          (?# match any number of digits - books can be any length)
                                 ([-]\d*)?    (?# may have a - followed by another number of arbitrary length)
                                 (?=\s|)      (?# lastly just to be safe double check that it is followed by a " | ")
                                /x

    highlight_location = entry[1].match(highlight_position_regexp).to_a.first || ""
  end
  
  def parse_content(entries)
    contents = entries[2..entries.length].join
  end
  

  def parse_entry(entry)
    lines = entry.split(/\n/)
    
    unless lines.length == 0
      author = parse_author(lines)
      title = parse_title(lines)
      type = parse_type(lines)
      location = parse_location(lines)
      contents = parse_content(lines)
      # TODO: add date
      { :title  => title, :author => author, :type => type, 
        :location => location, :contents => contents }  
    end
  end

  
  def trim_leading_newline(str)
    str.gsub(/\A\n/,"")
  end
  
end

#clippings_parsers = KindleClippingsParser.new("My Clippings.txt")
#clippings_parsers.parse
