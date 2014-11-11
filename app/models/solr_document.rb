# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document
  # Adds Worthwhile behaviors to the SolrDocument.
  include Worthwhile::SolrDocumentBehavior


  # self.unique_key = 'id'
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)
  use_extension(MxdSolrDocumentExtension) # Using this instead of BlacklightOaiProvider::SolrDocumentExtension

  field_semantics.merge!(
      title: "desc_metadata__title_tesim",
      description: "desc_metadata__description_tesim",
      creator: "desc_metadata__creator_tesim",
      publisher: "desc_metadata__publisher_tesim",
      language: "desc_metadata__language_tesim",
      subject: "misc_metadata__subject_tesim",
      format: "desc_metadata__format_tesim"
  )

  def to_oai_dc
    export_as(:mxd_xml)
  end

end
