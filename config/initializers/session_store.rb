Rails.application.config.session_store :active_record_store, key: (Rails.env.production? ? '_project_session_id' : (Rails.env.demo? ? '_project_demo_session_id' : '_project_dev_session_id')),
                                                             expire_after: (Rails.env.development? ? 99.years :  90.minutes),
                                                             secure: (Rails.env.demo? || Rails.env.production?),
                                                             httponly: true
