# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "shopify-cloud/version"

Gem::Specification.new do |spec|
  spec.name          = "shopify-cloud"
  spec.version       = ShopifyCloud::VERSION
  spec.authors       = %w(Shopify)
  spec.email         = ["production-engineering@shopify.com"]

  spec.summary       = "ShopifyCloud automates some requirements needed to deploy your app in Google Cloud"
  spec.description   = <<-EOF
    The end goal of this gem is to allow a rails project to be quickly setup for Google Cloud hosting.
    Some of the tasks might include:
      - auto ping checks for readiness
      - auto CDN upload w/ asset_host patching
      - zero config logging
      - the tracer thing ( allen-key?)
      - auto kafka
  EOF
  spec.homepage      = "https://github.com/Shopify/shopify-cloud"
  spec.license       = "Shopify"
  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/shopify-cloud/releases"

  spec.files = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_dependency("railties", ">= 5.0.0")
  spec.add_dependency("activesupport", ">= 5.0.0")
  spec.add_dependency("actionpack", ">= 5.0.0")
  spec.add_dependency("google-cloud-storage", "~> 1.4")
  spec.add_dependency("statsd-instrument")
  spec.add_dependency("shopify_metrics")
  spec.add_dependency("buffered-logger", "~> 2.1")

  spec.add_development_dependency("rake", "~> 10.0")
  spec.add_development_dependency("minitest", "5.10.1")
  spec.add_development_dependency("byebug")
  spec.add_development_dependency("sewing_kit", "0.7.1")
  spec.add_development_dependency("webpacker")
end
