lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/mastodon/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruboty-mastodon'
  spec.version       = Ruboty::Mastodon::VERSION
  spec.authors       = ['Sho Kusano']
  spec.email         = ['rosylilly@aduca.org']

  spec.summary       = 'Mastodon adapter for ruboty'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/rosylilly/ruboty-mastodon'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'lru_redux'
  spec.add_dependency 'mastodon-api'
  spec.add_dependency 'ruboty'
end
