Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
           :url   => 'http://staging.auth.cvt.dk/users',
           :name  => :cas,
           :setup => true
end

OmniAuth.config.logger = Rails.logger
