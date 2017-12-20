describe REX12::ElementWithSubElements do

  subject { described_class.new subelements, 1, ">" }

  let (:subelements) {
    [REX12::SubElement.new("a", 1), REX12::SubElement.new("b", 2), REX12::SubElement.new("c", 3)]
  }

  describe 'value' do
    it "returns nil" do
      expect(subject.value).to be_nil
    end
  end

  describe "position" do
    it "returns position given in constructor" do
      expect(subject.position).to eq 1
    end

    it "freezes position" do
      expect(subject.position).to be_frozen
    end
  end

  describe "sub_elements?" do
    it "returns false" do
      expect(subject.sub_elements?).to eq true
    end
  end

  describe "to_s" do 
    it "returns value" do
      expect(subject.to_s).to eq "a>b>c"
    end
  end

  describe "sub_elements" do
    it "returns an enum of SubElements" do
      e = subject.sub_elements
      expect(e.next).to eq subelements[0]
      expect(e.next).to eq subelements[1]
      expect(e.next).to eq subelements[2]
      expect { e.next }.to raise_error StopIteration
    end

    it "yields SubElements if block is given" do 
      expect { |b| subject.sub_elements(&b) }.to yield_successive_args(subelements[0], subelements[1], subelements[2]) 
    end
  end

  describe "sub_element" do
    it "returns the subelement at position" do
      expect(subject.sub_element 0).to eq subelements[0]
    end

    it "returns nil for invalid indexes" do
      expect(subject.sub_element 100).to be_nil
    end
  end

  describe "[]" do
    it "returns the subelement value at position" do
      expect(subject[2]).to eq "c"
    end

    it 'returns nil for invalid indexes' do
      expect(subject[100]).to be_nil
    end
  end
  
end
