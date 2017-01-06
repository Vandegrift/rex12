describe REX12::ParseError do
  it "should extend StandardError" do
    expect(described_class.new("my message").is_a?(StandardError)).to be_truthy
  end
  it "should take a segment & element" do
    seg = double('segment')
    el = double('el')
    e = described_class.new("message",seg,el)
    expect(e.segment).to eq seg
    expect(e.element).to eq el
  end
  it "should default segment & element to nil" do
    e = described_class.new("message")
    expect(e.segment).to be_nil
    expect(e.element).to be_nil
  end
  it "should return message" do
    expect(described_class.new("my message").message).to eq "my message"
  end
end
