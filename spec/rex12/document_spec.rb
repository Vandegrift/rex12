require "spec_helper"

describe REX12::Document do
  let :base_text do
    str = <<edi_text
ISA*00*          *00*          *ZZ*RECEIVERID     *12*SENDERID       *100325*1113*U*00403*000011436*0*T*>~
GS*FA*RECEIVERID*SENDERID*20100325*1113*24712*X*004030~
ST*997*1136~
AK1*PO*142~
AK2*850*01>42~
AK5*A~
AK9*A*1*1*1~
SE*6*1136~
GE*1*24712~
IEA*1*000011436~
edi_text
    str
  end
  describe '#parse' do
    it "should handle base text" do
      base_text.gsub!("\n",'')
      segs = described_class.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      st_seg = segs[2]
      expect(st_seg.value).to eq 'ST*997*1136'
      expect(st_seg.elements.length).to eq 3
      expect(st_seg.segment_type).to eq 'ST'
      expect(segs[4].elements.last.sub_elements).to eq ['01','42']
    end
    it "should handle LF after segment terminator" do
      segs = described_class.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end
    it "should handle CR after segment terminator" do
      base_text.gsub!("\n","\r")
      segs = described_class.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end
    it "should handle CRLF after segment terminator" do
      base_text.gsub!("\n","\r\n")
      segs = described_class.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end
    it "should handle block form" do
      segs = []
      expect(described_class.parse(base_text) {|s| segs << s}).to be_nil
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end
    it "should raise parse error if first segment isn't ISA" do
      base_text.gsub!("\n",'')
      base_text.gsub!("ISA*","OTR*")
      expect {described_class.parse(base_text)}.to raise_error REX12::ParseError
    end
    it "should raise parse error if second segment isn't GS" do
      base_text.gsub!("\n",'')
      base_text.gsub!("GS*","OTR*")
      expect {described_class.parse(base_text)}.to raise_error REX12::ParseError
    end
  end
  describe "#read" do
    it "should load file and collect responses from foreach" do
      segs = described_class.read('spec/support/997.txt')
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end
    it "should support block form" do
      segs = []
      expect(described_class.read('spec/support/997.txt') {|s| segs << s}).to be_nil
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end
  end
end
