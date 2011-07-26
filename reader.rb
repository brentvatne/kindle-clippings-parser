require 'rubygems'
require 'pp'

class KindleClippingsParser
  
  def initialize(file_path)
    @contents = load(file_path)
    @entries  = parse_entries
  end
  
  def load(file_path)
    file = File.open(file_path)
    clear_unwanted_returns_and_newlines(file.read)
  end
  
  def clear_unwanted_returns_and_newlines(str)
    str = str.gsub(/[\r]/,"")
  end

  def parse_entries
    #split by separator
    separator   = "="*10
    raw_entries = @contents.split(separator)
    raw_entries.map! { |entry| trim_leading_newline(entry) }
    
    #now that we have individual entries, for each one we want to get:
    #Title (author) --- if author does not exist use ""
    #Highlight location
    #Added on date (February 10, 2010, 01:39 PM)
    #Contents
    
    parenthesis_regexp = /[\(\)]/
    author_regexp =  /(\()        (?# opening parenthesis)
                      [^\)^\(]*?  (?# anything that is not a parenthesis - non-greedy)
                      (\))        (?# closing parenthesis)
                      \Z          (?# this must be at the end of the line because book title may contain parenthesis)
                     /x
                     
    days = %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday}.join("|")
    months = %w{January February March April May June July August September October November December}.join("|")
    
    date_regexp = /(#{days}),\s           (?# "Monday, " days followed by comma and a space)
                   (#{months})\s\d{2},\s  (?# "January 05, " month followed by comma and a space)
                   \d{4},\s               (?# "2011, " year followed by comma and space)
                   \d{2}:\d{2}\s          (?# "")
                   (AM|PM)
                   \Z
                  /x
                  
    entries = []
    
    raw_entries.each do |entry|
      lines = entry.split(/\n/)
      if lines.length > 0
        #author
        author = lines[0].match(author_regexp).to_a.first
        author.gsub!(parenthesis_regexp,"") unless author.nil?
        
        #title
        lines.first.gsub!(author_regexp,"") #clear out the author to simplify getting the title
        title = lines.first.strip
        
        #highlight location
        highlight_location = ""
        
        #added date
        date_added = lines[1].match(date_regexp).to_a.first
        
        #contents
        contents = lines[2..lines.length].join
        
        #push to entries
        entries.push( { :title  => title, 
                        :author => author,
                        :date_added => date_added,
                        :contents => contents } )
      end
    end
    
    entries
    
  end
  
  def trim_leading_newline(str)
    str.gsub(/\A\n/,"")
  end
  
  def get_dictionary_entries(dictionary = "The New Oxford American Dictionary")
    #clean out metadata that we don't want
    newlines_and_spaces = "[\s\\r\\n\r\n ]"
    junk_meta_regexp = /^.*?Highlight.*?(Added on)(?x) (?# beginning of highlight and added on string, then turn on ignore whitespace)
                        .*?(\d{2}:\d{2}\s(AM|PM))      (?# match the time)
                        #{newlines_and_spaces}*        (?# any newline and spaces after)
                       /
    junk_free_contents = @contents.gsub(junk_meta_regexp,"")    

    #extract dictionary entries               
    separator      = "="*10
    dictionary     = "The New Oxford American Dictionary"
    entry_regexp   = /(?<=#{dictionary})(?x) (?# match dictionary name without consuming it, then turn on ignore whitespace mode)
                     .*?                     (?# non-greedy match of any character until the next expression)
                     (?=#{separator})        (?# stop matching at the separator, which is 10 "="'s by default)
                     /m 
    @dictionary_entries = junk_free_contents.scan(entry_regexp)
  end
  
  #this is a good opportunity to use some metaprogramming - get it by some characteristic
  def get_entries_by_book_name(book_name)
    
  end
  
  def get_entries_containing_string(str)
    
  end
  
end

parser = KindleClippingsParser.new("My Clippings.txt")
#puts parser.get_dictionary_entries()