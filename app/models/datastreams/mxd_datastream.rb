class MxdDatastream < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(:path=>"mxd")
    t.title
    t.description
    t.subject
    t.person {
      t.first_name
      t.last_name
      t.role
    }
    t.publication_date
    t.mxd_type(path:"type")
  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mxd("xmlns:mxd" => "http://purl.org/dc/elements/1.1/", "xmlns:dct" => "http://purl.org/dc/terms/")
    end
    return builder.doc
  end

end

