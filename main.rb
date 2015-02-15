#!/usr/bin/env ruby

require_relative 'lib/upwords'

# new Curses window subroutine (STILL BEING IMPLEMENTED!)
if ARGV.size > 0 && ARGV[0].upcase == "CURSES"
  ARGV.clear
  Upwords::Game.new(nil, nil, true).run  
# old basic console subroutine
else
  ARGV.clear
  Upwords::Game.new.run
end
