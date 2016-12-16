require "spec_helper"

describe REX12::Segment do
  let :base_text do
    'DTM*ACK*20000415*0830*ED>XYZ'
  end
  let :base_object do
    described_class.new(base_text,'*','>',10)
  end
  describe '#value' do
    it "should return the raw text value" do
      expect(base_object.value).to eq base_text
    end
  end
  describe '#segment_type' do
    it "should return first segment value" do
      expect(base_object.segment_type).to eq 'DTM'
    end
  end
  describe '#elements' do
    it "should return elements as array" do
      r = base_object.elements
      expect(r.length).to eq 5
      expect(r.collect {|el| el.value}).to eq base_text.split('*')
    end
    it "should yield elements in block" do
      r = []
      expect(base_object.elements {|el| r << el}).to be_nil
      expect(r.length).to eq 5
      expect(r.collect {|el| el.value}).to eq base_text.split('*')
    end
    it "should properly pass sub_element_separator" do
      expect(base_object.elements.last.sub_elements).to eq ['ED','XYZ']
    end
  end
  describe '#position' do
    it "should return position" do
      expect(base_object.position).to eq 10
    end
  end
end
