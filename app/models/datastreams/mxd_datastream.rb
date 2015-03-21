class MxdDatastream < ActiveFedora::OmDatastream

  def prefix(ds_name)
    ""
  end

  set_terminology do |t|
    t.root(:path=>"mxd")
    t.lang
    t.title(index_as: [:stored_searchable, :facetable])
    t.subtitle(index_as: [:stored_searchable, :facetable])

    t.description(index_as: [:stored_searchable, :facetable])
    t.keyword(index_as: [:stored_searchable, :facetable])
    t.person {
      t.person_id_type
      t.person_id(index_as: [:stored_searchable, :facetable])
      t.first_name(index_as: [:stored_searchable, :facetable])
      t.last_name(index_as: [:stored_searchable, :facetable])
      t.role
      t.affiliation
    }
    t.organisation {
      t.name
    }
    t.editor {
      t.first_name(index_as: [:stored_searchable, :facetable])
      t.last_name(index_as: [:stored_searchable, :facetable])
    }
    t.event {
        t.title
        t.start
        t.end
        t.place
    }
    t.details {
        t.page_range
        t.chapter
        t.pages
        t.doi
        t.article_number
    }
    t.book {
        t.book_title
        t.book_subtitle
        t.publisher
        t.city
        t.year
        t.volume
        t.edition
        t.doi
        t.isbn
        t.eisbn
    }
    t.series {
        t.series_title
        t.year
        t.volume
        t.number
        t.country
        t.issn
        t.eissn
        t.publisher
    }
    t.requester
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

