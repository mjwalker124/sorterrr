require 'delayed-plugins-airbrake'
Delayed::Worker.plugins << Delayed::Plugins::Airbrake::Plugin

Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 2.days
Delayed::Worker.destroy_failed_jobs = false
# Delayed::Worker.delay_jobs = Rails.env.production? || Rails.env.demo? || Rails.env.qa?
Delayed::Worker.delay_jobs = !Rails.env.test?
