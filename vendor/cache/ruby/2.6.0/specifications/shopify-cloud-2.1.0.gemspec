# -*- encoding: utf-8 -*-
# stub: shopify-cloud 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shopify-cloud".freeze
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.pkg.github.com", "changelog_uri" => "https://github.com/Shopify/shopify-cloud/releases" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shopify".freeze]
  s.bindir = "exe".freeze
  s.date = "2019-10-04"
  s.description = "    The end goal of this gem is to allow a rails project to be quickly setup for Google Cloud hosting.\n    Some of the tasks might include:\n      - auto ping checks for readiness\n      - auto CDN upload w/ asset_host patching\n      - zero config logging\n      - the tracer thing ( allen-key?)\n      - auto kafka\n".freeze
  s.email = ["production-engineering@shopify.com".freeze]
  s.homepage = "https://github.com/Shopify/shopify-cloud".freeze
  s.licenses = ["Shopify".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "ShopifyCloud automates some requirements needed to deploy your app in Google Cloud".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
      s.add_runtime_dependency(%q<actionpack>.freeze, [">= 5.0.0"])
      s.add_runtime_dependency(%q<google-cloud-storage>.freeze, ["~> 1.4"])
      s.add_runtime_dependency(%q<statsd-instrument>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<shopify_metrics>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<buffered-logger>.freeze, ["~> 2.1"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["= 5.10.1"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<sewing_kit>.freeze, ["= 0.7.1"])
      s.add_development_dependency(%q<webpacker>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 5.0.0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
      s.add_dependency(%q<actionpack>.freeze, [">= 5.0.0"])
      s.add_dependency(%q<google-cloud-storage>.freeze, ["~> 1.4"])
      s.add_dependency(%q<statsd-instrument>.freeze, [">= 0"])
      s.add_dependency(%q<shopify_metrics>.freeze, [">= 0"])
      s.add_dependency(%q<buffered-logger>.freeze, ["~> 2.1"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<minitest>.freeze, ["= 5.10.1"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_dependency(%q<sewing_kit>.freeze, ["= 0.7.1"])
      s.add_dependency(%q<webpacker>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 5.0.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
    s.add_dependency(%q<actionpack>.freeze, [">= 5.0.0"])
    s.add_dependency(%q<google-cloud-storage>.freeze, ["~> 1.4"])
    s.add_dependency(%q<statsd-instrument>.freeze, [">= 0"])
    s.add_dependency(%q<shopify_metrics>.freeze, [">= 0"])
    s.add_dependency(%q<buffered-logger>.freeze, ["~> 2.1"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, ["= 5.10.1"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<sewing_kit>.freeze, ["= 0.7.1"])
    s.add_dependency(%q<webpacker>.freeze, [">= 0"])
  end
end
