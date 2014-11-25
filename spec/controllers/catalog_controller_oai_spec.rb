require 'rails_helper'

describe CatalogController do
  let(:user) { FactoryGirl.create(:user) }
  let(:book1) {FactoryGirl.create(:kind_of_blue, user:user)}
  let(:xml_namespaces) { {"oai"=>"http://www.openarchives.org/OAI/2.0/", "mxd"=>"http://mx.forskningsdatabasen.dk/ns/documents/1.3"} }
  before do
    sign_in user
    book1  # creates the book
  end
  it "should support OAI-PMH ListRecords" do
    get :oai, verb:"ListRecords", metadataPrefix:"mxd"
    response_xml = Nokogiri::XML::Document.parse(response.body)
    expect(response_xml.xpath("//oai:OAI-PMH/oai:ListRecords/oai:record/oai:metadata/mxd:ddf_doc", xml_namespaces).count).to be >= 1
  end
end
