# -*- encoding : utf-8 -*-
require 'builder'

# This module provide Dublin Core export based on the document's semantic values
module MxdSolrDocumentExtension
  include HierarchicalAttributesHelper

  def self.extended(document)
    # Register our exportable formats
    MxdSolrDocumentExtension.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:mxd_xml, "text/xml")
  end

  # dublin core elements are mapped against the #dublin_core_field_names whitelist.
  def export_as_mxd_xml
    curation_concern = ActiveFedora::Base.find(self["id"])
    xml = Builder::XmlMarkup.new
    xml.tag!("mxd:ddf_doc",
             "xmlns:mxd"=>"http://mx.forskningsdatabasen.dk/ns/documents/1.3",
             "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
             format_version: "1.3.0", doc_type:"dja", doc_lang:"en",
             doc_year:"2016", doc_review:"pr", doc_level:"sci", rec_source:"itu",
             rec_id:curation_concern.id, rec_created:self["system_created_dtsi"], rec_upd:self["system_modified_dtsi"], rec_status:"c") do
      xml.mxd(:title) {
        xml.mxd(:original,"xml:lang"=>"en") {
          xml.mxd(:main, curation_concern.title.first, "xmlns:xs"=>"http://www.w3.org/2001/XMLSchema", "xsi:type"=>"xs:string")
          if curation_concern.title.count > 1
            curation_concern.title[1..curation_concern.title.length].each do |subtitle|
              xml.mxd(:sub, subtitle)
            end
          end
        }
      }
      hierarchical_attribute_collection(curation_concern, :person).each do |person|
        xml.mxd(:person, pers_role:person.role.first) {
          xml.mxd(:name) {
            xml.mxd(:first, person.first_name.first)
            xml.mxd(:last,  person.last_name.first)
          }
        }
      end
    end
  end

end
