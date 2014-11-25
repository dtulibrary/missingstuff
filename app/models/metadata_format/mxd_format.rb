# This is required by the OAI Provider in order to support encoding MXD documents
class MxdFormat < OAI::Provider::Metadata::Format

  def initialize
    @prefix = 'mxd'
    @schema = ''
    @namespace = 'http://mx.forskningsdatabasen.dk/ns/documents/1.3'
    @element_namespace = 'mxd'
    @fields = []
  end

  def encode(model, record)
    record.export_as_mxd_xml
  end

  def header_specification
    {}
  end

end
