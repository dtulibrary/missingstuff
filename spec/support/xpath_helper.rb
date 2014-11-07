# Runs xpath_query against the document, returning the text value from each node in the returned NodeSet
# @param  [Nokogiri::XML::Document] document to query against
# @param  [String] xpath_query to run
# @param  [Hash] options to pass into xpath method (defaults to nil)
def values_at_xpath(document, xpath_query, options=nil)
  document.xpath(xpath_query, options).map{|node| node.text}
end