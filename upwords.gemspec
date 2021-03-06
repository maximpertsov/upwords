# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'upwords/version'

Gem::Specification.new do |s|
  s.name          = "upwords"
  s.version       = Upwords::VERSION
  s.author        = "Maxim Pertsov"
  s.email         = "maxim.pertsov@gmail.com"
  s.summary       = %q{Command-line version of the Upwords boardgame. Upwords is similar to Scrabble, except you can stack new letters on top of previously-played letters. Play with 1 to 4 human or computer players.}
  s.description   = %q{Command-line version of the Upwords boardgame. Upwords is similar to Scrabble, except you can stack new letters on top of previously-played letters. Play with 1 to 4 human or computer players.}
  s.homepage      = "https://github.com/maximpertsov/upwords"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = "exe" 
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib", "data"]

  s.add_dependency "curses", "~> 1.0"
  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "minitest-reporters", "~> 1.1"
  s.add_development_dependency "pry", "~> 0.10"
end
