#<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
#<responseDate>2014-11-07T15:03:41Z</responseDate>
#  <request verb="ListRecords">https://pure.itu.dk/ws/oai</request>
#  <ListRecords>
#    <record>
#      <header>
#        <identifier>oai:pure.atira.dk:publications/794f93e5-a85d-4e33-b795-a6517146bda2</identifier>
#        <datestamp>2014-09-01T05:23:59Z</datestamp>
#<setSpec>publications:all</setSpec>
#        <setSpec>publications:submissionYear2016</setSpec>
#<setSpec>publications:year2016</setSpec>
#      </header>
#<metadata>

xml.instruct! :xml, :version=>"1.0"
xml.tag!("OAI-PMH", xmlns:"http://www.openarchives.org/OAI/2.0/", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation"=>"http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd") {
  xml.responseDate Time.now.utc.iso8601
  xml.request("https://pure.itu.dk/ws/oai", verb:"ListRecords")
  xml.ListRecords {
    @document_list.each do |doc|
      xml.record do
        xml.header {
          xml.identifier(doc["id"])
          xml.datestamp(doc["system_modified_dtsi"])
        }
        xml.metadata() {
          xml.target! << doc.export_as_mxd_xml
        }
      end
    end
  }
}
