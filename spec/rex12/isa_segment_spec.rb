describe REX12::IsaSegment do 

  subject { described_class.new elements, 1, "~", "*", ">"}

  let (:elements) {
    [REX12::Element.new("a", 1), REX12::Element.new("b", 2)]
  }

  describe "position" do
    it "returns the position given in the constructor" do
      expect(subject.position).to eq 1
    end

    it "freezes position" do
      expect(subject.position).to be_frozen
    end
  end

  describe "segment_type" do
    it "returns the first element's value as the segment type" do
      expect(subject.segment_type).to eq "a"
    end

    context "with no elements" do
      subject { described_class.new [], 1, "!", "*", ">"}

      it "returns nil" do
        expect(subject.segment_type).to be_nil
      end
    end
  end

  describe "elements" do
    it "returns an enum of all elements" do
      els = subject.elements

      expect(els.next).to eq elements[0]
      expect(els.next).to eq elements[1]
      expect{ els.next }.to raise_error StopIteration
    end

    it "yields elements" do
      expect { |b| subject.elements(&b) }.to yield_successive_args(elements[0], elements[1]) 
    end
  end

  describe "[]" do 
    it "returns element at index" do 
      expect(subject[1]).to eq elements[1]
    end

    it "returns nil for invalid index" do
      expect(subject[100]).to be_nil
    end
  end

  describe "segment_terminator" do 
    it "returns terminator from constructor" do
      expect(subject.segment_terminator).to eq "~"
    end

    it "freezes terminator" do
      expect(subject.segment_terminator).to be_frozen
    end
  end

  describe "element_delimiter" do 
    it "returns delimiter from constructor" do
      expect(subject.element_delimiter).to eq "*"
    end

    it "freezes delimiter" do
      expect(subject.element_delimiter).to be_frozen
    end
  end

  describe "sub_element_separator" do 
    it "returns terminator from constructor" do
      expect(subject.sub_element_separator).to eq ">"
    end

    it "freezes sub_element_separator" do
      expect(subject.sub_element_separator).to be_frozen
    end
  end

end