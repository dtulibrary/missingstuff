require 'rails_helper'

describe WithMxdMetadata do
  before do
    class ClassWithMxdMetadata < ActiveFedora::Base
      include WithMxdMetadata
    end
  end
  after do
    Object.send(:remove_const, :ClassWithMxdMetadata)
  end

  subject { ClassWithMxdMetadata.new({publication_date:"1929",person:[{first_name:"Nella", last_name:"Larsen", role:"author"}]}) }

  it "should track special attributes" do
    expect(WithMxdMetadata.special_attributes).to eq [:person]
  end

  describe "#subfields_for" do
    it "should report the subfields for the specified term" do
      expect(subject.subfields_for(:person)).to eq([:first_name, :last_name, :role])
    end
  end

  it "should allow updating nested metadata from hash" do
    subject = Book.new
    update_hash = {"publication_date"=>"1968","person"=>[{"first_name"=>"Joan", "last_name"=>"Didion", "role"=>"author"}, {"first_name"=>"Henry", "last_name"=>"Robbins", "role"=>"editor"}]}.with_indifferent_access
    subject.update(update_hash)
    expect(subject.publication_date).to eq("1968")
    expect(subject.person.count).to eq(2)
    person1 = subject.person(0)
    expect(person1.first_name).to eq(["Joan"])
    expect(person1.last_name).to eq(["Didion"])
    expect(person1.role).to eq(["author"])
    expect(subject.person(1).last_name).to eq(["Robbins"])
  end
  it "should allow replacing nested metadata from hash" do
    expect(subject.person.count).to eq(1)
    update_hash = {"publication_date"=>"1969","person"=>[{"first_name"=>"Martin Luther", "last_name"=>"King", "role"=>"leader"}]}.with_indifferent_access
    subject.update(update_hash)
    expect(subject.publication_date).to eq("1969")
    expect(subject.person.count).to eq(1)
    person1 = subject.person(0)
    expect(person1.first_name).to eq(["Martin Luther"])
    expect(person1.last_name).to eq(["King"])
    expect(person1.role).to eq(["leader"])
  end
  it "should allow emptying out nested metadata" do
    expect(subject.person.count).to eq(1)
    update_hash = {"publication_date"=>"1969","person"=>[]}.with_indifferent_access
    subject.update(update_hash)
    expect(subject.person.count).to eq(0)
  end
  it "should leave nested metadata untouched if no new values are provided" do
    expect(subject.person.count).to eq(1)
    update_hash = {"publication_date"=>"1969"}.with_indifferent_access
    subject.update(update_hash)
    expect(subject.person.count).to eq(1)
    expect(subject.person(0).first_name).to eq(["Nella"])
  end
end
