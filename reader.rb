require 'rubygems'
require 'pp'

file = File.open("My Clippings.txt")
contents = file.read

#clean out metadata that we don't want
newlines_and_spaces = "[\s\\r\\n\r\n ]"
junk_meta_regexp = /^.*?Highlight.*?(Added on)(?x)
                    .*?(\d{2}:\d{2}\s(AM|PM))
                    #{newlines_and_spaces}*
                   /
contents = contents.gsub(junk_meta_regexp,"")

#extract dictionary entries               
separator      = "="*10
dictionary     = "The New Oxford American Dictionary"
entry_regexp   = /(?<=#{dictionary})(?x) (?# match dictionary name without consuming it, then turn on ignore whitespace mode)
                 .*?                     (?# non-greedy match of any character until the next expression)
                 (?=#{separator})        (?# stop matching at the separator, which is 10 "="'s by default)
                 /m
                 
all_entries = contents.scan(entry_regexp)
pp all_entries[0]