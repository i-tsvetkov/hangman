require './hangman-common.rb'
begin
  require 'sqlite3'
rescue LoadError
  warn "Please install the sqlite gem to use this implementation"
end

warn "You must have hangman.db to use this implementation" unless File.exist?('hangman.db')

