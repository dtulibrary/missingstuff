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
        if !fld.year.first.nil? and !fld.year.first.empty?
          year = fld.year.first
        end
      end
    end
    if year == 0 and cc.respond_to? :series
      hierarchical_attribute_collection(cc, :series).each do |fld|
        if !fld.year.first.nil? and !fld.year.first.empty?
          year = fld.year.first
        end
      end
    end
    if year == 0  and cc.respond_to? :computer_program
      hierarchical_attribute_collection(cc, :computer_program).each do |fld|
        if !fld.year.first.nil? and !fld.year.first.empty?
          year = fld.year.first
        end
      end
    end
    if year == 0 and cc.respond_to? :audio_visual
      hierarchical_attribute_collection(cc, :audio_visual).each do |fld|
        if !fld.year.first.nil? and !fld.year.empty?
          year = fld.year.first
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
            xml_field(xml, :first, person.first_name)
            xml_field(xml, :last, person.last_name)
          }
          xml_field(xml, :id, person.person_id, id_type:person.person_id_type)
        }
        if person.affiliation.first
          afflist[affno] = person.affiliation.first
        end
        affno += 1
      end
      hierarchical_attribute_collection(cc, :organisation).each do |org|
        xml.mxd(:organisation, org_role:'oau') {
          xml.mxd(:name) {
            xml_field(xml, :level1, org.name)
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
      xml.mxd(:local_field, tag_type:'4') {
        xml.mxd(:code, 'type')
        xml.mxd(:data, cc.class.to_s)
      }
      if cc.class == Other
        hierarchical_attribute_collection(cc, :other).each do |fld|
          xml.mxd(:local_field, tag_type:'4') {
            xml.mxd(:code, 'textType')
            xml_field(xml, :data, fld.type)
          }
          xml.mxd(:local_field, tag_type:'4') {
            xml.mxd(:code, 'lastModified')
            xml_field(xml, :data, fld.date_modified)
          }
          xml.mxd(:local_field, tag_type:'4') {
            xml.mxd(:code, 'lastAccessed')
            xml_field(xml, :data, fld.date_accessed)
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
      xml_field(xml, :id, details(cc, :doi), type:'doi')
      xml_field(xml, :id, details(cc, :article_number), type:'article_number')
      xml.mxd(:publication) {
        if cc.class == Book or cc.class == BookChapter or cc.class == LectureNote or cc.class == Report or cc.class == ReportChapter or cc.class == Other
          hierarchical_attribute_collection(cc, :book).each do |book|
            case cc.class.to_s
              when 'Book'
                xml.mxd(:book) {
                  xml_field(xml, :edition, book.edition)
                  xml_field(xml, :isbn, book.isbn, type:'print')
                  xml_field(xml, :isbn, book.eisbn, type:'electronic')
                  xml_field(xml, :doi, book.doi)
                  xml_field(xml, :place, book.city)
                  xml_field(xml, :publisher, book.publisher)
                  xml_field(xml, :year, book.year)
                  xml_field(xml, :vol, book.volume)
                  xml_field(xml, :pages, details(cc, :pages))
                  xml_field(xml, :series, series(cc))
                }
              when 'BookChapter'
                xml.mxd(:in_book) {
                  xml_field(xml, :title, book.book_title)
                  xml_field(xml, :sub_title, book.book_subtitle)
                  xml_field(xml, :edition, book.edition)
                  xml_field(xml, :editor, editor(cc))
                  xml_field(xml, :isbn, book.isbn, type:'print')
                  xml_field(xml, :isbn, book.eisbn, type:'electronic')
                  xml_field(xml, :place, book.city)
                  xml_field(xml, :publisher, book.publisher)
                  xml_field(xml, :year, book.year)
                  xml_field(xml, :doi, book.doi)
                  xml_field(xml, :vol, book.volume)
                  xml_field(xml, :pages, details(cc, :pages))
                  xml_field(xml, :pages_range, details(cc, :page_range))
                  xml_field(xml, :chapter, details(cc, :chapter))
                  xml_field(xml, :series, series(cc))
                }
              when 'LectureNote'
                xml.mxd(:lecture_notes) {
                  xml_field(xml, :edition, book.edition)
                  xml_field(xml, :isbn, book.isbn, type:'print')
                  xml_field(xml, :isbn, book.eisbn, type:'electronic')
                  xml_field(xml, :doi, book.doi)
                  xml_field(xml, :place, book.city)
                  xml_field(xml, :publisher, book.publisher)
                  xml_field(xml, :year, book.year)
                  xml_field(xml, :vol, book.volume)
                  xml_field(xml, :pages, details(cc, :pages))
                  xml_field(xml, :series, series(cc))
                }
              when 'Report'
                xml.mxd(:report) {
                  xml_field(xml, :edition, book.edition)
                  xml_field(xml, :isbn, book.isbn, type:'print')
                  xml_field(xml, :isbn, book.eisbn, type:'electronic')
                  xml_field(xml, :series, series(cc))
                  xml_field(xml, :rep_no, details(cc, :report_number))
                  xml_field(xml, :doi, book.doi)
                  xml_field(xml, :place, book.city)
                  xml_field(xml, :publisher, book.publisher)
                  xml_field(xml, :year, book.year)
                  xml_field(xml, :vol, book.volume)
                  xml_field(xml, :pages, details(cc, :pages))
                }
              when 'ReportChapter'
                xml.mxd(:in_report) {
                  xml_field(xml, :title, book.book_title)
                  xml_field(xml, :sub_title, book.book_subtitle)
                  xml_field(xml, :edition, book.edition)
                  xml_field(xml, :editor, editor(cc))
                  xml_field(xml, :isbn, book.isbn, type:'print')
                  xml_field(xml, :isbn, book.eisbn, type:'electronic')
                  xml_field(xml, :place, book.city)
                  xml_field(xml, :publisher, book.publisher)
                  xml_field(xml, :year, book.year)
                  xml_field(xml, :doi, book.doi)
                  xml_field(xml, :vol, book.volume)
                  xml_field(xml, :pages, details(cc, :pages))
                  xml_field(xml, :pages_range, details(cc, :page_range))
                  xml_field(xml, :chapter, details(cc, :chapter))
                  xml_field(xml, :series, series(cc))
                }
              when 'Other'
                xml.mxd(:other) {
                  xml_field(xml, :title, book.book_title)
                  xml_field(xml, :sub_title, book.book_subtitle)
                  xml_field(xml, :edition, book.edition)
                  xml_field(xml, :editor, editor(cc))
                  xml_field(xml, :isbn, book.isbn, type:'print')
                  xml_field(xml, :isbn, book.eisbn, type:'electronic')
                  xml_field(xml, :place, book.city)
                  xml_field(xml, :publisher, book.publisher)
                  xml_field(xml, :year, book.year)
                  xml_field(xml, :doi, book.doi)
                  xml_field(xml, :vol, book.volume)
                  xml_field(xml, :pages, details(cc, :pages))
                  xml_field(xml, :pages_range, details(cc, :page_range))
                  xml_field(xml, :chapter, details(cc, :chapter))
                  xml_field(xml, :series, series(cc))
                }
            end
          end
        end
        if cc.class == JournalArticle and cc.respond_to? :series
          hierarchical_attribute_collection(cc, :series).each do |fld|
            if !fld.series_title.first.empty?
              xml.mxd(:in_journal) {
                xml_field(xml, :title, fld.series_title)
                xml_field(xml, :issn, fld.issn, type:'print')
                xml_field(xml, :issn, fld.eissn, type:'electronic')
                xml_field(xml, :year, fld.year)
                xml_field(xml, :volume, fld.volume)
                xml_field(xml, :issue, fld.number)
                xml_field(xml, :pages, details(cc, :pages))
                xml_field(xml, :pages_range, details(cc, :page_range))
                xml_field(xml, :publisher, fld.publisher)
                xml_field(xml, :country, fld.country)
              }
            end
          end
        end
        if cc.class == AudioVisual
          hierarchical_attribute_collection(cc, :audio_visual).each do |av|
            xml.mxd(:audio_visual) {
              xml_field(xml, :year, av.year)
              xml_field(xml, :pages, av.pages)
              xml_field(xml, :version, av.version)
              xml_field(xml, :size, av.size)
              xml_field(xml, :length, av.length)
              xml_field(xml, :media, av.media)
              xml_field(xml, :doi, av.doi)
              xml_field(xml, :publisher, av.publisher)
              xml_field(xml, :city, av.city)
            }
          end
        end
        if cc.class == ComputerProgram
          hierarchical_attribute_collection(cc, :computer_program).each do |cp|
            xml.mxd(:computer_program) {
              xml_field(xml, :year, cp.year)
              xml_field(xml, :version, cp.version)
              xml_field(xml, :size, cp.size)
              xml_field(xml, :media, cp.output_media)
              xml_field(xml, :doi, cp.doi)
              xml_field(xml, :publisher, cp.publisher)
              xml_field(xml, :city, cp.city)
            }
          end
        end
#       Linked resources
        if cc.linked_resources.present?
          cc.linked_resources.each do |link|
            xml.mxd(:inetpub) {
              if link.title and link.title.length > 0
                xml_field(xml, :text, link.title)
              else
                xml_field(xml, :text, link.url)
              end
              xml_field(xml, :url, link.url)
            }
          end
        end
#       Files
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
            xml_field(xml, :file, nil, filename:file.title)
            xml_field(xml, :uri, "http://missingStuff.dtic.dk/downloads/#{file.pid}")
          }
        end
        if cc.class != JournalArticle and cc.respond_to? :series
          hierarchical_attribute_collection(cc, :series).each do |fld|
            if !fld.series_title.first.empty?
              xml.mxd(:series) {
                xml_field(xml, :title, fld.series_title)
                xml_field(xml, :volume, fld.volume)
                xml_field(xml, :number, fld.number)
                xml_field(xml, :issn, fld.issn, type:'print')
                xml_field(xml, :issn, fld.eissn, type:'electronic')
                xml_field(xml, :publisher, fld.publisher)
                xml_field(xml, :country, fld.country)
              }
            end
          end
        end
      }
    end
  end

  def xml_field(xml, fld, body, attributes={})
    Rails.logger.info "xml_field(fld:'#{fld}, body:'#{body}', attributes:'#{attributes.inspect}"
    attr = {}
    attributes.each_pair do |key, value|
      if value.class == String
        attr[key] = value
      else
        attr[key] = value.first
      end
    end
    if body.nil?
      valid=false
      if !attr.nil?
        attr.each_value do |a|
          if !a.nil? and !a.empty?
            valid=true
          end
        end
      end
      if valid
        xml.mxd(fld, attr)
      end
    else
      if body.class == String
        if !body.empty?
          xml.mxd(fld, attr) {
            xml.text! body
          }
        end
      else
        body.each do |b|
          if !b.empty?
            xml.mxd(fld, attr) {
              xml.text! b
            }
          end
        end
      end
    end
  end

  def details(cc, field)
    if cc.respond_to? :details
      hierarchical_attribute_collection(cc, :details).each do |fld|
        begin
          val = fld.send(field).first
          if val.nil? or val.empty?
            return ''
          else
            return val
          end
          rescue NoMethodError
            return ''
        end
      end
    end
    return ''
  end

  def series(cc)
    if cc.respond_to? :series
      hierarchical_attribute_collection(cc, :series).each do |fld|
        val = fld.series_title.first
        if val.nil? or val.empty?
          return ''
        else
          return val
        end
      end
    end
    return ''
  end

  def editor(cc)
    if cc.respond_to? :editor
      hierarchical_attribute_collection(cc, :editor).each do |fld|
        if fld.last_name.first.nil? and fld.first_name.first.nil?
          return ''
        end
        if fld.last_name.first.empty? and fld.first_name.first.empty?
          return ''
        end
        return "#{fld.last_name.first}, #{fld.first_name.first}"
      end
    end
    return '' 
  end
end
