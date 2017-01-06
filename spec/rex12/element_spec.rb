describe REX12::Element do
  describe '#value' do
    it "should return raw text" do
      expect(described_class.new('abc>def','>',1).value).to eq 'abc>def'
    end
  end
  describe '#sub_elements?' do
    it "should return true if sub element separator exists in value" do
      expect(described_class.new('abc>def','>',1).sub_elements?).to be_truthy
    end
    it "should return false if sub element separator does not exist in value" do
      expect(described_class.new('abcdef','>',1).sub_elements?).to be_falsey
    end
  end
  describe '#sub_elements' do
    it "should return array with value if no separator in value" do
      expect(described_class.new('abcdef','>',1).sub_elements).to eq ['abcdef']
    end
    it "should return split array if separator in value" do
      expect(described_class.new('abc>def','>',1).sub_elements).to eq ['abc','def']
    end
    it "should yield to block" do
      r = []
      expect(described_class.new('abc>def','>',1).sub_elements {|se| r << se}).to be_nil
      expect(r).to eq ['abc','def']
    end
  end
  describe '#position' do
    it 'should return position' do
      expect(described_class.new('abc>def','>',1).position).to eq 1
    end
  end
end
