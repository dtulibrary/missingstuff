# -*- encoding : utf-8 -*-
require 'builder'
require 'metadata_format/mxd_format'
BlacklightOaiProvider::SolrDocumentProvider.register_format(MxdFormat.instance)

# This module provides MXD export.  It is a replacement for BlacklightOaiProvider::SolrDocumentExtension
module MxdSolrDocumentExtension
  include HierarchicalAttributesHelper

  def self.extended(document)
    # Register our exportable formats
    MxdSolrDocumentExtension.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:mxd_xml, "text/xml")
  end

  def timestamp
    Time.parse get('timestamp')
  end

  # dublin core elements are mapped against the #dublin_core_field_names whitelist.
  def export_as_mxd_xml
    cc = ActiveFedora::Base.find(self["id"])
    case cc.class.to_s
      when 'Book'
        type = 'db'
      when 'BookChapter'
        type = 'dba'
      when 'ComputerProgram'
        type = 'dso'
      when 'JournalArticle'
        type = 'dja'
      when 'LectureNote'
        type = 'dln'
      when 'Report'
        type = 'dr'
      when 'ReportChapter'
        type = 'dra'
      else
        type = 'do'
    end
    year = 0
    if cc.respond_to? :book
      hierarchical_attribute_collection(cc, :book).each do |fld|
        if fld.year
          year = fld.year
        end
      end
    end
    if year == 0 and cc.respond_to? :series
      hierarchical_attribute_collection(cc, :series).each do |fld|
        if fld.year
          year = fld.year
        end
      end
    end
    if year == 0  and cc.respond_to? :computer_program
      hierarchical_attribute_collection(cc, :computer_program).each do |fld|
        if fld.year
          year = fld.year
        end
      end
    end
    if year == 0 and cc.respond_to? :audio_visual
      hierarchical_attribute_collection(cc, :audio_visual).each do |fld|
        if fld.year
          year = fld.year
        end
      end
    end
    xml = Builder::XmlMarkup.new
    xml.tag!("mxd:ddf_doc",
             "xmlns:mxd"=>"http://mx.forskningsdatabasen.dk/ns/documents/1.3",
             "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
             "xmlns:xs"=>"http://www.w3.org/2001/XMLSchema",
             format_version: "1.3.0", doc_type:type, doc_lang:cc.lang,
             doc_year:year, doc_review:'und', doc_level:'und', rec_source:"dtu",
             rec_id:cc.id, rec_created:self["system_create_dtsi"], rec_upd:self["system_modified_dtsi"], rec_status:"c") do
      xml.mxd(:title) {
        xml.mxd(:original,"xml:lang"=>cc.lang) {
          xml.mxd(:main, cc.title)
          cc.subtitle.each do |subtitle|
            xml.mxd(:sub, subtitle)
          end
        }
      }
      if !cc.description.empty? or cc.keyword.length > 0
        xml.mxd(:description) {
          xml.mxd(:abstract, cc.description)
          if cc.keyword.length > 0
            xml.mxd(:subject) {
              cc.keyword.each do |kw|
                xml.mxd(:keyword, key_type:'fre') {
                  xml.text! kw
                }
              end
            }
          end
        }
      end
      affno = 1
      afflist = []
      hierarchical_attribute_collection(cc, :person).each do |person|
        xml.mxd(:person, pers_role:person.role.first, aff_no:affno) {
          xml.mxd(:name) {
            xml.mxd(:first, person.first_name.first)
            xml.mxd(:last,  person.last_name.first)
          }
          if person.person_id.first
            xml.mxd(:id, id_type:person.person_id_type.first) {
              xml.text! person.person_id.first
            }
          end
        }
        if person.affiliation.first
          afflist[affno] = person.affiliation.first
        end
        aff_no += 1
      end
      hierarchical_attribute_collection(cc, :organisation).each do |org|
        xml.mxd(:organisation, org_role:'oau') {
          xml.mxd(:name) {
            xml.mxd(:level1, org.name.first)
          }
        }
      end
      afflist.each_with_index do |aff,i|
        if aff
          xml.mxd(:organisation, org_role:'oaf', aff_no:i) {
            xml.mxd(:name) {
              xml.mxd(:level1, aff)
            }
          }
        end
      end
      cc.requester.each do |req|
        xml.mxd(:local_field, tag_type:'4') {
          xml.mxd(:code, 'requester')
          xml.mxd(:data, req)
        }
      end
      range = chapter = pages = doi = artno = repno = nil;
      hierarchical_attribute_collection(cc, :details).each do |fld|
        range   = fld.page_range.first
        chapter = fld.chapter.first
        pages   = fld.pages.first
        doi     = fld.doi.first
        artno   = fld.article_number.first
        repno   = fld.report_number.first
      end
      xml.mxd(:publication) {
        if cc.class == Book or cc.class == BookChapter
          hierarchical_attribute_collection(cc, :book).each do |book|
              if cc.class == Book
                xml.mxd(:book) {
                  xml.mxd(:edition, book.edition.first)
                  xml.mxd(:isbn, type:'print') {
                    xml.text!  book.isbn.first
                  }
                  xml.mxd(:isbn, type:'electronic') {
                    xml.text!  book.eisbn.first
                  }
                  xml_field(xml, :isbn, book.eisbn.first, type:'electronic')
                  xml.mxd(:place, book.city.first)
                  xml.mxd(:publisher, book.publisher.first)
                  xml.mxd(:year, book.year.first)
                }
              else
                xml.mxd(:in_book) {
                  xml.mxd(:title, book.book_title.first)
                  xml.mxd(:edition, book.edition.first)
                  xml.mxd(:isbn, book.isbn.first)
                  xml.mxd(:publisher, book.publisher.first)
                }
              end
          end
        end
        if cc.linked_resources.present?
          cc.linked_resources.each do |link|
            xml.mxd(:inetpub) {
              if link.title and link.title.length > 0
                xml.mxd(:text, link.title)
              else
                xml.mxd(:text, link.url)
              end
              xml.mxd(:url, link.url)
            }
          end
        end
        cc.generic_files.each do |file|
          hash = file.to_solr.stringify_keys
          access = 'na'
          if hash[Hydra.config.permissions.read.group].present?
            if hash[Hydra.config.permissions.read.group].include?('public')
              if hash[Hydra.config.permissions.embargo.release_date].present?
                access = 'ea'
              else
                access = 'oa'
              end
            elsif hash[Hydra.config.permissions.read.group].include?('registered')
              access = 'ca'
            end
          end
          xml.mxd(:digital_object, id: file.pid, access: access) {
            xml.mxd(:file, filename: file.title.first)
            xml.mxd(:uri, "http://missingStuff.dtic.dk/downloads/#{file.pid}")
          }
        end
      }
    end
  end

  def xml_field(xml, fld, body, attr)
    if body.nil?
        xml.mxd(fld, attr)
    else
        xml.mxd(fld, attr) {
          xml.text! body
        }
    end
  end
end
