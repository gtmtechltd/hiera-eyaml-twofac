# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/eyaml/encryptors/twofac'

Gem::Specification.new do |gem|
  gem.name          = "hiera-eyaml-twofac"
  gem.version       = Hiera::Backend::Eyaml::Encryptors::Twofac::VERSION
  gem.description   = "PKCS7 + AES256 2-factor encryptor for use with hiera-eyaml"
  gem.summary       = "Encryption plugin for hiera-eyaml backend for Hiera"
  gem.author        = "Geoff Meakin"
  gem.license       = "MIT"

  gem.homepage      = "http://github.com/gtmtechltd/hiera-eyaml-twofac"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
