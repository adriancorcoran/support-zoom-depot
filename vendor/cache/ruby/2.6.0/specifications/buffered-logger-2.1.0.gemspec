# -*- encoding: utf-8 -*-
# stub: buffered-logger 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "buffered-logger".freeze
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Samuel Kadolph".freeze]
  s.date = "2019-06-17"
  s.description = "buffered-logger is designed to be used in multithreaded or multifiber rack servers and includes a middleware to\nautomatically capture and write the buffered log statements during each request.\nThis is ideal for keeping requests together for log parsing software such as splunk\n".freeze
  s.email = ["samuel@kadolph.com".freeze]
  s.homepage = "http://samuelkadolph.github.com/buffered-logger/".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "buffered-logger is a concurrency safe logger. It buffers each logging statement and writes to the log file all at once.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>.freeze, ["~> 1.4.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.3.1"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.11.3"])
    else
      s.add_dependency(%q<mocha>.freeze, ["~> 1.4.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.3.1"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.11.3"])
    end
  else
    s.add_dependency(%q<mocha>.freeze, ["~> 1.4.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.3.1"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.11.3"])
  end
end
