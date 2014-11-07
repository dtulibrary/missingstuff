module HierarchicalAttributesHelper
  include ActionView::Helpers::TagHelper  # This is so failed translation lookups can use content_tag method
  def hierarchical_attribute_to_html(curation_concern, attribute_name, label = nil, options = {})
    if curation_concern.respond_to?(attribute_name)
      markup = ""
      collection = hierarchical_attribute_collection(curation_concern, attribute_name)
      return markup if !collection.present? && !options[:include_empty]
      markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
      collection.each do |entry|
        subfields_markup = "<ul class='tabular'>"
        subfields_for(curation_concern, attribute_name).each do |subfield_key|
          subfield_value = entry.send(subfield_key).first
          subfield_attribute_name = "#{attribute_name}_#{subfield_key}"
          search_field = subfield_attribute_name
          unless subfield_value.nil?
            subfield_label = subfield_label(attribute_name, subfield_key)
            subfield_li_value = link_to_if(options[:catalog_search_link], h(subfield_value), catalog_index_path(search_field: search_field, q: h(subfield_value)))
            subfields_markup << %(<li class="attribute subfield #{subfield_attribute_name}"> <div class="label">#{subfield_label}</div> #{subfield_li_value} </li>\n)
          end
        end
        subfields_markup << "</ul>"
        #li_value = link_to_if(options[:catalog_search_link], h(entry), catalog_index_path(search_field: attribute_name, q: h(entry)))
        #li_value = subfields_for(attribute_name)
        markup << %(<li class="attribute hierarchical #{attribute_name}"> #{subfields_markup} </li>\n)
      end
      markup << %(</ul></td></tr>)
      markup.html_safe
    end
  end

  def subfields_for(curation_concern, attribute_name)
    curation_concern.subfields_for(attribute_name)
  end

  def hierarchical_attribute_collection(curation_concern, attribute_name)
    # By default OM returns the _values_ of nodes rather than the nodes themselves, so we have to build the array of nodes manually.
    begin
      collection = []
      curation_concern.send(attribute_name).count.times do |i|
        collection << curation_concern.send(attribute_name, i)
      end
    end
    collection
  end

  def subfield_label(attribute_name, subfield_name)
    t("simple_form.labels.#{attribute_name}.#{subfield_name}")
  end

end
