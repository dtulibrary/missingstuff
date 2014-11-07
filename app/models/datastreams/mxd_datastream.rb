class MxdDatastream < ActiveFedora::OmDatastream

  def prefix
    "desc_metadata__"
  end

  set_terminology do |t|
    t.root(:path=>"mxd")
    t.title(index_as: [:stored_searchable, :facetable])
    t.description(index_as: [:stored_searchable, :facetable])
    t.subject(index_as: [:stored_searchable, :facetable])
    t.person {
      t.first_name(index_as: [:stored_searchable, :facetable])
      t.last_name(index_as: [:stored_searchable, :facetable])
      t.role
    }
    t.publication_date(index_as: [:stored_searchable, :facetable])
    t.mxd_type(path:"type", index_as: [:stored_searchable, :facetable])
  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mxd("xmlns:mxd" => "http://purl.org/dc/elements/1.1/", "xmlns:dct" => "http://purl.org/dc/terms/")
    end
    return builder.doc
  end

end

