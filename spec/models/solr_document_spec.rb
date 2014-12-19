require 'rails_helper'
require 'support/xpath_helper'

describe SolrDocument do
  include Blacklight::SolrHelper # this allows us to use the get_solr_response_for_doc_id method to load the SolrDocument
  let(:blacklight_config) {CatalogController.blacklight_config}
  let(:logger) {Rails.logger}
  let(:book) { FactoryGirl.create(:theory_of_moral_sentiments) }
  subject { get_solr_response_for_doc_id(book.pid)[1] } # get_solr_response_for_doc_id returns [response, document].  We want the document.

  it "should return complete metadata for OAI harvest" do
    oai_xml = Nokogiri::XML::Document.parse( subject.export_as(:oai_dc_xml) )
    expect( values_at_xpath(oai_xml, "//dc:description").first ).to eq(book.description)
    expect( values_at_xpath(oai_xml, "//dc:title").first ).to eq(book.title)
    expect( values_at_xpath(oai_xml, "//dc:subject") ).to eq(book.subject)
    expect( values_at_xpath(oai_xml, "//dc:publisher") ).to eq(book.publisher)
  end
end
