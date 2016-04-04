# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upwords/version'

Gem::Specification.new do |spec|
  spec.name          = "upwords"
  spec.version       = Upwords::VERSION
  spec.authors       = ["Maxim Pertsov"]
  spec.email         = ["maxim.pertsov@gmail.com"]

  spec.summary       = "Command-line version of the Upwords boardgame. Upwords is similar to Scrabble, except you can stack new letters on top of previously-played letters. Play with 1 to 4 human or computer players."
  spec.homepage      = "https://github.com/maximpertsov/upwords"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe" 
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "data"]

  spec.add_dependency "curses", "~> 1.0"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "pry", "~> 0.10"
end
