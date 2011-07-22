require 'rubygems'
require 'pp'

file = File.open("My Clippings.txt")
contents = file.read

separator = "="*10
dictionary_name = "The New Oxford American Dictionary"
dict_entry_regexp = /(?<=#{dictionary_name})(?x) (?# match dictionary name without consuming it, then turn on ignore whitespace mode)
                     
                     .*?                         (?# non-greedy match of any character until the next expression)
                     (?=[=]{10})                 (?# stop matching at the separator, which is 10 "="'s by default)
                    /m

all_entries = contents.scan(dict_entry_regexp)
                      #.join
                      #.split(separator)
pp all_entries[0]

#contents.scan(dictionary_entry) do |line|
#  puts line
#end


# 
# .gsub(header_line_regexp,"")
# .gsub(highlight_info_line_regexp,"")