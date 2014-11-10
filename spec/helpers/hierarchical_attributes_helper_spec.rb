require 'rails_helper'
require 'erb'

describe HierarchicalAttributesHelper do
  let(:curation_concern) { FactoryGirl.create(:kind_of_blue) }

  subject { hierarchical_attribute_to_html(curation_concern, :person, "Person", {}) }

  context "when document is a Worthwhile::GenericFile" do
    it "should render all subfields" do
      expect(subject).to have_selector 'ul li.attribute.hierarchical.person', :count => 2
      expect(subject).to have_selector '.hierarchical.person ul li.subfield.person_first_name', :text => "Miles"
      expect(subject).to have_selector '.hierarchical.person ul li.subfield.person_last_name', :text => "Davis"
      expect(subject).to have_selector '.hierarchical.person ul li.subfield.person_role', :text => "Trumpet"
      expect(subject).to have_selector '.hierarchical.person ul li.subfield.person_first_name', :text => "Julian \"cannonball\""
      expect(subject).to have_selector '.hierarchical.person ul li.subfield.person_last_name', :text => "Adderly"
      expect(subject).to have_selector '.hierarchical.person ul li.subfield.person_role', :text => "Alto saxophone"
    end
  end

  # this allows the helper to use the h() method, which is usually mixed in by Rails from ERB::Util
  def h(string)
    return string
  end
end
