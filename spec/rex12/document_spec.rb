describe REX12::Document do
  subject { described_class }

  let(:isa) { "ISA*00*          *00*          *ZZ*RECEIVERID     *12*SENDERID       *100325*1113*U*00403*000011436*0*T*>~\n" }
  let(:iea) { "IEA*1*000011436~\n" }

  let(:base_edi) do
    str = <<edi_text
GS*FA*RECEIVERID*SENDERID*20100325*1113*24712*X*004030~
ST*997*1136~
AK1*PO*142~
AK2*850*01>42~
AK5*A~
AK9*A*1*1*1~
SE*6*1136~
GE*1*24712~
edi_text
        str
  end

  let(:base_text) { isa + base_edi + iea }

  describe '#parse' do
    it "should handle base text" do
      base_text.gsub!("\n",'')
      segs = subject.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      st_seg = segs[2]
      expect(st_seg.value).to eq 'ST*997*1136'
      expect(st_seg.elements.length).to eq 3
      expect(st_seg.segment_type).to eq 'ST'
      expect(segs[4].elements.last.sub_elements).to eq ['01','42']
    end

    it "should handle LF after segment terminator" do
      segs = subject.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end

    it "should handle CR after segment terminator" do
      base_text.gsub!("\n","\r")
      segs = subject.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end

    it "should handle CRLF after segment terminator" do
      base_text.gsub!("\n","\r\n")
      segs = subject.parse(base_text)
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end

    it "should handle block form" do
      segs = []
      expect(subject.parse(base_text) {|s| segs << s}).to be_nil
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end

    it "should raise parse error if first segment isn't ISA" do
      base_text.gsub!("\n",'')
      base_text.gsub!("ISA*","OTR*")
      expect {subject.parse(base_text)}.to raise_error REX12::ParseError
    end

    it "should raise parse error if second segment isn't GS" do
      base_text.gsub!("\n",'')
      base_text.gsub!("GS*","OTR*")
      expect {subject.parse(base_text)}.to raise_error REX12::ParseError
    end
  end

  describe "#read" do
    it "should load file and collect responses from foreach" do
      segs = subject.read('spec/support/997.txt')
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end

    it "should support block form" do
      segs = []
      expect(subject.read('spec/support/997.txt') {|s| segs << s}).to be_nil
      expect(segs.length).to eq 10
      # make sure it's parsing segments properly
      expect(segs[2].value).to eq 'ST*997*1136'
    end

    context "with IO object" do
      it "reads edi data from an IO object" do
        File.open("spec/support/997.txt", "r") do |f|
          segs = subject.read('spec/support/997.txt')
          expect(segs.length).to eq 10
        end
      end
    end
  end

  describe "each_transaction" do
    let (:multiple_transactions) { isa + base_edi + base_edi + iea }

    def evaluate_transactions transactions
      expect(transactions.length).to eq 2
      transaction = transactions.first
      # Make sure the ISA and GS segements are attached to the transaction
      expect(transaction.isa_segment).not_to be_nil
      expect(transaction.isa_segment.value).to eq "ISA*00*          *00*          *ZZ*RECEIVERID     *12*SENDERID       *100325*1113*U*00403*000011436*0*T*>"
      expect(transaction.gs_segment).not_to be_nil
      expect(transaction.gs_segment.value).to eq "GS*FA*RECEIVERID*SENDERID*20100325*1113*24712*X*004030"
      expect(transaction.segments.length).to eq 6
      # Make sure the segments are in order and the ST/SE ones are captured
      expect(transaction.segments.first.value).to eq "ST*997*1136"
      expect(transaction.segments.last.value).to eq "SE*6*1136"
    end

    it "parses all transactions from EDI text using block" do
      yielded = []
      subject.each_transaction(multiple_transactions) {|transaction| yielded << transaction }
      evaluate_transactions(yielded)
    end

    it "parses all transactions from EDI text" do
      evaluate_transactions(subject.each_transaction(multiple_transactions))
    end
  end
end
