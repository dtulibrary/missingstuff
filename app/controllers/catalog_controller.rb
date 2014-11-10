class CatalogController < ApplicationController
  include Worthwhile::CatalogController
  include ::BlacklightOaiProvider::ControllerExtension

  configure_blacklight do |config|
    config.oai = {
        :provider => {
            :repository_name => 'Test',
            :repository_url => 'http://localhost',
            :record_prefix => '',
            :admin_email => 'root@localhost'
        },
        :document => {
            :timestamp => 'system_create_dtsi',
            :limit => 25
        }
    }
  end

  # get search results from the solr index
  # Overriding this method in order to enable rendering of OAI-PMH responses when .oaipmh is the requested format
  def index
    (@response, @document_list) = get_search_results

    respond_to do |format|
      format.html { }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.oaipmh { render :layout => false }     # <-- This is the only line that we actually want to override.
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end


end