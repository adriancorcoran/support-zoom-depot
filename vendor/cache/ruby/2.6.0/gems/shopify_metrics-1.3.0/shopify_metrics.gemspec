# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shopify_metrics/version'

Gem::Specification.new do |spec|
  spec.name          = "shopify_metrics"
  spec.version       = ShopifyMetrics::VERSION
  spec.authors       = ["Pior Bastida"]
  spec.email         = ["pior.bastida@shopify.com"]

  spec.summary       = "Implement standard performance metrics for ruby services"
  spec.description   = ""
  spec.homepage      = "https://github.com/shopify/shopify_metrics"
  spec.license       = "MIT"

  spec.files         = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_dependency("raindrops")
  spec.add_dependency("statsd-instrument", "~> 2.7")
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://packages.shopify.io/shopify/gems"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end
end
