require File.expand_path('../boot', __FILE__)

require 'rails/all'
#this was included because if not rolify #scopify which it adds to User would raise
require 'rolify/railtie'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module ActiveModel
  module Serialization
    def serializable_hash(options = nil)
      options ||= {}

      attribute_names = attributes.keys
      if only = options[:only]
        attribute_names &= Array(only).map(&:to_s)
      elsif except = options[:except]
        attribute_names -= Array(except).map(&:to_s)
      end

      hash = {}
      attribute_names.each { |n| hash[n] = read_attribute_for_serialization(n) }

      Array(options[:methods]).each { |m| hash[m.to_s] = send(m) if respond_to?(m) }

      serializable_add_includes(options) do |association, records, opts|
        hash[association.to_s] = if records.respond_to?(:to_ary)
          records.to_ary.map { |a| a.serializable_hash(opts) }
        else
          records.serializable_hash(opts)
        end
      end
      root = options[:root]
      root ? {self.class.name.split("::")[-1].underscore => hash} : hash 
    end
  end
end

module Denty
  class Application < Rails::Application

    config.generators.stylesheets = false
    config.generators.javascripts = false

######## OPAL CONFIG

		# These are the available options with their default value:
    config.opal.method_missing      = true
    config.opal.optimized_operators = true
    config.opal.arity_check         = false
    config.opal.const_missing       = true
    config.opal.dynamic_require_severity = :ignore

    # Enable/disable /opal_specs route
    config.opal.enable_specs        = true

    config.opal.spec_location = 'spec-opal'

######## END OPAL CONFIG
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
