describe REX12::Parser do

  let(:delimiter) { "~" }
  let(:isa) { "ISA*00*          *00*          *ZZ*RECEIVERID     *12*SENDERID       *100325*1113*U*00403*000011436*0*T*>#{delimiter}" }
  let (:gs) { "GS*FA*RECEIVERID*SENDERID*20100325*1113*24712*X*004030#{delimiter}" }
  let(:iea) { "IEA*1*000011436#{delimiter}" }

  let(:base_edi) do
    str = []
    str << "ST*997*1136#{delimiter}"
    str << "AK1*PO*142#{delimiter}"
    str << "AK2*850*01>42#{delimiter}"
    str << "AK5*A#{delimiter}"
    str << "AK9*A*1*1*1#{delimiter}"
    str << "SE*6*1136#{delimiter}"
    str << "GE*1*24712#{delimiter}"
    str.join
  end

  let(:base_text) { isa + gs + base_edi + iea }

  describe "each_transaction" do
    
    context "with single edi transaction" do
      let (:transaction) { isa + gs + base_edi + iea }
      let (:edi_enum) { subject.each_transaction(StringIO.new transaction) }
      let (:edi) { edi_enum.next }

      it "returns a enum with transaction" do
        expect(edi_enum.size).to eq 1
      end

      it "returns a transaction" do
        expect(edi.isa_segment).not_to be_nil
        expect(edi.isa_segment).to be_a(REX12::IsaSegment)
        expect(edi.isa_segment.elements.size).to eq 17
        expect(edi.isa_segment.position).to eq 0
        expect(edi.isa_segment.segment_terminator).to eq "~"
        expect(edi.isa_segment.segment_terminator.encoding).to eq Encoding::UTF_8
        expect(edi.isa_segment.element_delimiter).to eq "*"
        expect(edi.isa_segment.element_delimiter.encoding).to eq Encoding::UTF_8
        expect(edi.isa_segment.sub_element_separator).to eq ">"
        expect(edi.isa_segment.sub_element_separator.encoding).to eq Encoding::UTF_8

        expect(edi.gs_segment).not_to be_nil

        expect(edi.segments.length).to eq 6
      end

      it "yields transaction" do
        transactions = []
        subject.each_transaction(StringIO.new(transaction)) do |t|
          transactions << t
        end
        
        expect(transactions.length).to eq 1
      end

      it "handles sub-elements" do
        subelement_segment = edi.segments[2]
        expect(subelement_segment[2]).to be_a REX12::ElementWithSubElements

        el = subelement_segment[2]
        expect(el.sub_elements?).to eq true
        expect(el.sub_elements.to_a.map(&:to_s)).to eq ["01", "42"]
      end

      context "with alternate segment terminators" do
        after(:each) do 
          expect(edi_enum.size).to eq 1
          expect(edi.segments.length).to eq 6
        end

        it "handles alternate segment terminators" do
          delimiter.clear
          delimiter << "!"
        end

        it "handles linefeed segment terminators" do
          delimiter.clear
          delimiter << "\n"
        end

        it "handles terminator chars w/ linefeed following" do
          delimiter << "\n"
        end

        it "handles terminator chars w/ carriage return following" do
          delimiter << "\r"
        end

        it "handles terminator chars w/ carriage return / linefeed following" do
          delimiter << "\r\n"
        end
      end

      it "raises an error if multi-char terminator is used" do
        delimiter << "!"
        expect { edi_enum }.to raise_error REX12::ParseError, "Invalid ISA segment.  Could not determine segment terminator."
      end

      it "raises an error if multi-char terminator is used with linefeed" do
        delimiter << "\n!"
        expect { edi_enum }.to raise_error REX12::ParseError, "Invalid ISA segment.  Could not determine segment terminator."
      end
    end

    context "with multiple transactions" do
      let (:transactions) { isa + gs + base_edi + base_edi + iea }
      let(:edi_enum) { subject.each_transaction(StringIO.new transactions) }

      it "returns a enum with transactions" do
        expect(edi_enum.size).to eq 2
      end

      it "returns multiple transactions" do
        t = edi_enum.next
        expect(t).not_to be_nil
        isa = t.isa_segment
        gs = t.gs_segment
        expect(isa).not_to be_nil
        expect(gs).not_to be_nil
        expect(t.segments.length).to eq 6

        t = edi_enum.next
        expect(t.isa_segment).to eq isa
        expect(t.gs_segment).to eq gs
        expect(t.segments.length).to eq 6
      end

      it "yields transactions" do
        t = []
        subject.each_transaction(StringIO.new(transactions)) do |transaction|
          t << transaction
        end
        
        expect(t.length).to eq 2
      end
    end

    context "alternate encodings" do
      let (:transaction) { (isa + gs + base_edi + iea).encode("ASCII") }
      let (:first_transaction) { subject.each_transaction(StringIO.new transaction).next}

      it "utilizes the given encoding to split the file into components" do
        expect(first_transaction.isa_segment).not_to be_nil
        expect(first_transaction.isa_segment.segment_terminator.encoding).to eq Encoding::ASCII
        expect(first_transaction.isa_segment.element_delimiter.encoding).to eq Encoding::ASCII
        expect(first_transaction.isa_segment.sub_element_separator.encoding).to eq Encoding::ASCII
        expect(first_transaction.gs_segment).not_to be_nil
        expect(first_transaction.segments.length).to eq 6
      end
    end

    context "parser errors" do

      it "raises an error if EDI doesn't begin with at least 107 chars" do
        expect { subject.each_transaction(StringIO.new "test")}.to raise_error REX12::ParseError, "Invalid EDI.  All EDI documents must start with an ISA segment that is exactly 107 characters long - including the segment terminator."
      end
    end
  end
end