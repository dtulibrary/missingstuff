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
      title: "title_tesim",
      description: "description_tesim",
      creator: "creator_tesim",
      publisher: "publisher_tesim",
      language: "language_tesim",
      subject: "subject_tesim",
      format: "format_tesim"
  )

end
