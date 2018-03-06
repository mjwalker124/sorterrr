Airbrake.configure do |config|
  config.api_key = 'fdffd2f0800fb8db884b22500d1c556b'
  config.host    = 'errbit.software-hut.org.uk'
  config.port    = 443
  config.secure  = config.port == 443
end
