class CatalogController < ApplicationController
  include Worthwhile::CatalogController
  include BlacklightOaiProvider::ControllerExtension

  configure_blacklight do |config|
    config.oai = {
        :provider => {
            :repository_name => 'Test',
            :repository_url => 'http://localhost',
            :record_prefix => '',
            :admin_email => 'root@localhost'
        },
        :document => {
            :timestamp => 'timestamp',
            :limit => 25
        }
    }
  end
end