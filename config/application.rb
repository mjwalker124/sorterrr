require_relative 'boot'

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sorterrr
  class Application < Rails::Application
    # Send queued jobs to delayed_job
    config.active_job.queue_adapter = :delayed_job

    # This points to our own routes middleware to handle exceptions
    config.exceptions_app = self.routes

    I18n.enforce_available_locales = false
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      g.fixture_replacement    :factory_girl, dir:  'spec/factories'
      g.test_framework :rspec, fixture:  true,
                               helper_specs:  true,
                               routing_specs:  false,
                               controller_specs:  false,
                               view_specs:  false,
                               integration_tool:  false
    end

    config.time_zone = 'London'
    config.browser_validations = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
