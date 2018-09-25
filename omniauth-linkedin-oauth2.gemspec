# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-linkedin-oauth2/version'

Gem::Specification.new do |gem|
  gem.name          = "omniauth-linkedin-oauth2"
  gem.version       = OmniAuth::LinkedInOAuth2::VERSION
  gem.authors       = ["Level 29"]
  gem.email         = ["tech@gleanin.com"]
  gem.description   = %q{A LinkedIn OAuth2 strategy for OmniAuth.}
  gem.summary       = %q{A LinkedIn OAuth2 strategy for OmniAuth.}
  gem.homepage      = "https://github.com/level29/omniauth-linkedin-oauth2"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'omniauth-oauth2'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'simplecov'
end
