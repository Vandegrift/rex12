require 'pathname'

describe REX12 do

  subject { described_class }

  it "has a version number" do
    expect(subject::VERSION).not_to be nil
  end

  let (:current_file) { __FILE__ }
  let (:edi_path) { Pathname.new(current_file).split.first.join(Pathname.new("support/997.txt"))}
  let (:io) { StringIO.new edi_path.read }

  describe "each_transaction" do

    before :each do
      expect(subject).to receive(:parser).and_return REX12::Parser.new
    end

    context "with IO" do
      it "utilizes parser to parse each transaction from an IO object" do
        expect(subject.each_transaction(io).size).to eq 1
      end

      it "yields transactions" do 
        t = []
        subject.each_transaction(io) {|v| t << v}
        expect(t.length).to eq 1
      end
    end

    context "with Pathname" do
      it "reads data from Pathname" do
        expect(subject.each_transaction(edi_path).size).to eq 1
      end

      it "correctly handles file open / close" do
        expect(File).to receive(:open).with(edi_path.to_s, "r").and_yield io
        subject.each_transaction(edi_path)
      end
    end

    context "with String path" do
      it "reads data from String path" do
        expect(subject.each_transaction(edi_path.to_s).size).to eq 1
      end

      it "correctly handles file open / close" do
        expect(File).to receive(:open).with(edi_path.to_s, "r").and_yield io
        subject.each_transaction(edi_path.to_s)
      end
    end
  end

  describe "each_segment" do

    before :each do
      expect(subject).to receive(:parser).and_return REX12::Parser.new
    end

    context "with IO" do
      it "utilizes parser to parse each transaction from an IO object" do
        expect(subject.each_segment(io).size).to eq 10
      end

      it "yields transactions" do 
        t = []
        subject.each_segment(io) {|v| t << v}
        expect(t.length).to eq 10
      end
    end

    context "with Pathname" do
      it "reads data from Pathname" do
        expect(subject.each_segment(edi_path).size).to eq 10
      end

      it "correctly handles file open / close" do
        expect(File).to receive(:open).with(edi_path.to_s, "r").and_yield io
        subject.each_segment(edi_path)
      end
    end

    context "with String path" do
      it "reads data from String path" do
        expect(subject.each_segment(edi_path.to_s).size).to eq 10
      end

      it "correctly handles file open / close" do
        expect(File).to receive(:open).with(edi_path.to_s, "r").and_yield io
        subject.each_segment(edi_path.to_s)
      end
    end
  end

  describe "document" do

    before :each do
      expect(subject).to receive(:parser).and_return REX12::Parser.new
    end

    context "with IO" do
      it "utilizes parser to parse each transaction from an IO object" do
        expect(subject.document(io).segments.size).to eq 10
      end
    end

    context "with Pathname" do
      it "reads data from Pathname" do
        expect(subject.document(edi_path).segments.size).to eq 10
      end

      it "correctly handles file open / close" do
        expect(File).to receive(:open).with(edi_path.to_s, "r").and_yield io
        subject.document(edi_path)
      end
    end

    context "with String path" do
      it "reads data from String path" do
        expect(subject.document(edi_path.to_s).segments.size).to eq 10
      end

      it "correctly handles file open / close" do
        expect(File).to receive(:open).with(edi_path.to_s, "r").and_yield io
        subject.document(edi_path.to_s)
      end
    end
  end
end
