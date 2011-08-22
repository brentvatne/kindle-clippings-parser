require 'rubygems'
require 'pp'

class KindleClippingsParser
  
  def initialize(file_path)
    @file_path = file_path
  end
  
  def entries
    return @entries if @entries
    contents = File.read(@file_path)
    raw_entries = split_entries(contents)

    @entries = raw_entries.map do |entry|
      parse_entry(entry)
    end
  end

  def split_entries(contents)
    delete_carriage_returns!(contents)
    raw_entries = contents.split("="*10)
    raw_entries.map { |entry| trim_leading_newline(entry) }
  end

  def delete_carriage_returns!(str)
    str.gsub!(/[\r]/,"")
  end
 
  def trim_leading_newline(str)
    str.gsub(/\A\n/,"")
  end

  def parse_entry(entry)
    lines    = entry.split(/\n/)

    author   = parse_author(lines.first)
    title    = parse_title(lines.first)
    type     = parse_type(lines)
    location = parse_location(lines)
    contents = parse_content(lines)

    { :title    => title, 
      :author   => author, 
      :type     => type, 
      :location => location, 
      :contents => contents }  
  end
  
  #eg: "For Whom the Bell Tolls (Ernest Hemingway)"
  #Matches: "(Ernest Hemingway)"  
  def parse_author(text)
    return '' unless has_author?(text) 
    author = text.split('(').last
    author = author.gsub(')', '')
  end
  
  def parse_title(text)
    return text unless has_author?(text) 
    split_text = text.split('(')
    if split_text.length > 2 
      split_text.pop
      title = split_text.join('(')
    else
      title = split_text[0]
    end

    title.strip
  end

  def has_author?(text)
    !!(text =~ /\)\z/)
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
                  
    date = entry[1].match(date_regexp).to_a.first or ""
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
  
   
end

#clippings_parsers = KindleClippingsParser.new("My Clippings.txt")
#clippings_parsers.parse
