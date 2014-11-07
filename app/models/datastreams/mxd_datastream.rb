class MxdDatastream < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(:path=>"mxd")
    t.lang
    t.review
    t.level
    t.title
    t.subtitle
    t.description
    t.keyword
    t.person {
      t.first_name
      t.last_name
      t.role
    }
    t.organisation {
      t.level1
      t.level2
      t.level3
      t.level4
      t.role
    }
    t.event {
        t.title
        t.start
        t.end
        t.place
    }
    t.book {
        t.publisher
        t.edition
        t.isbn
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

