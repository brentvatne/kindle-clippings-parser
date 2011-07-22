require 'rubygems'
require 'pp'

file = File.open("My Clippings.txt")
contents = file.read

separator = "="*10
dictionary = "The New Oxford American Dictionary"
entry_regexp = /(?<=#{dictionary})(?x) (?# match dictionary name without consuming it, then turn on ignore whitespace mode)
                .*?                         (?# non-greedy match of any character until the next expression)
                (?=[=]{10})                 (?# stop matching at the separator, which is 10 "="'s by default)
               /m

all_entries = contents.scan(entry_regexp)
pp all_entries[0]