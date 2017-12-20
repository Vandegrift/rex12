describe REX12::SubElement do

  subject { described_class.new "abc", 1 }

  describe 'value' do
    it "returns value given in constructor" do
      expect(subject.value).to eq "abc"
    end

    it "freezes value" do
      expect(subject.value).to be_frozen
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

  describe "to_s" do 
    it "returns value" do
      expect(subject.to_s).to eq "abc"
    end
  end
  
end
