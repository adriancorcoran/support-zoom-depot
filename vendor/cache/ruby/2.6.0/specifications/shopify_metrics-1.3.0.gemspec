# -*- encoding: utf-8 -*-
# stub: shopify_metrics 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shopify_metrics".freeze
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://packages.shopify.io/shopify/gems" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Pior Bastida".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-01-08"
  s.description = "".freeze
  s.email = ["pior.bastida@shopify.com".freeze]
  s.homepage = "https://github.com/shopify/shopify_metrics".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Implement standard performance metrics for ruby services".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<raindrops>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<statsd-instrument>.freeze, ["~> 2.7"])
    else
      s.add_dependency(%q<raindrops>.freeze, [">= 0"])
      s.add_dependency(%q<statsd-instrument>.freeze, ["~> 2.7"])
    end
  else
    s.add_dependency(%q<raindrops>.freeze, [">= 0"])
    s.add_dependency(%q<statsd-instrument>.freeze, ["~> 2.7"])
  end
end
