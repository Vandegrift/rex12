# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'REX12/version'

Gem::Specification.new do |spec|
  spec.name          = "REX12"
  spec.version       = REX12::VERSION
  spec.authors       = ["Brian Glick"]
  spec.email         = ["brian@brian-glick.com"]

  spec.summary       = "Simple ANSI X.12 reading"
  spec.description   = "Read ANSI X.12 files"
  spec.homepage      = "https://github.com/Vandegrift/rex12"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "byebug", "~> 11.1"
end
