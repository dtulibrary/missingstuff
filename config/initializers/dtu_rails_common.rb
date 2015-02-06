module DtuRailsCommon
  class Engine < Rails::Engine
    config.app_name = 'DTU Findit - Local Publications'
    config.dtu_font_enabled = Rails.application.config.try(:dtu_common_layout) && Rails.application.config.dtu_common_layout[:dtu_font_enabled]
    config.auth = {
      :cas_url => 'http://staging.auth.cvt.dk/users',
      :api_url => 'http://staging.auth.cvt.dk/rest',
      :ip => {
        :walk_in  => [],
        :campus   => [],
        :internal => [],
      }
    }
  end
end
