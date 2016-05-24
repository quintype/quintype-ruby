Gem::Specification.new do |s|
  s.name        = 'quintype'
  s.version     = '0.0.1'
  s.date        = '2016-02-19'
  s.summary     = "quintype!"
  s.description = "A simple hello world gem"
  s.authors     = [""]
  s.email       = 'dev-core@quintype.com'
  s.files       = ["lib/quintype.rb"]
  s.homepage    =
    'http://rubygems.org/gems/quintype'
  s.license       = 'MIT'

  s.add_dependency 'faraday', '~> 0.9'
  s.add_dependency 'activesupport', '~> 4.2'
end
