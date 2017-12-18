require "REX12/version"
require "rex12/parse_error"
require "rex12/element"
require "rex12/segment"
require "rex12/document"
require 'rex12/transaction'
require 'rex12/element_with_subelements'
require 'rex12/isa_segment'
require 'rex12/parser'
require 'rex12/subelement'

module REX12

  # Reads EDI data from the given IO object or file path and returns or yields an enumerator returning every "transaction" in the EDI data.
  #
  # @param [String, IO] - If a String, expected to be the path to a file that can be read. If IO, needs to be able to be read from AND be able to be rewound.
  #
  # @return [Enumerator<REX12::Transaction>] - If no block given, returns an Enumerator for iterating over the Transactions in the file
  # @yield [REX12::Transaction] - Progressively yields each transaction in the given EDI data.
  def self.each_transaction file_or_io
    val = nil
    with_io(file_or_io) do |io| 
      if block_given?
        val = parser.each_transaction io, &Proc.new
      else
        val = parser.each_transaction io
      end
    end
    val
  end

  # Reads EDI data from the given IO object or file path and returns or yields each EDI segement encountered in the data.
  # The ISA segment is returned/yielded as a specialized REX12::IsaSegment subclass of REX12::Segment.
  #
  # Example:
  # 
  # REX12.each_segment("path/to/file.edi") do |segment|
  #   if segment.isa_segment?
  #     # Do something w/ the ISA
  #   else 
  #     # Do something w/ some other segment type
  #   end
  # end
  #
  #
  #
  # @param [String, IO] - If a String, expected to be the path to a file that can be read.  If IO, needs to be able to be read from AND be able to be rewound.
  #
  # @return [Enumerator<REX12::Segment>] - If no block given, returns an Enumerator for iterating over the Segements in the file
  # @yield [REX12::Segment] - Progressively yields each segment in the given EDI data.
  def self.each_segment file_or_io
    val = nil
    with_io(file_or_io) do |io| 
      if block_given?
        val = parser.each_segment io, &Proc.new
      else
        val = parser.each_segment io
      end
    end
    val
  end

  # Reads EDI data from the given IO object or file path and returns a REX12::Document representing every segment from the given datasource.
  # 
  # @return [REX12::Document] - a REX12 object representing an ordered enumeration of all the segments in the given data source.
  def self.document file_or_io
    val = nil
    with_io(file_or_io) do |io| 
      val = parser.document io
    end
    val
  end

  def self.parser
    REX12::Parser.new
  end

  def self.with_io file_or_io
    # If we got an actual IO or Tempfile, then use them as given, else we'll assume the 
    # value is a path and
    if REX12::Parser.required_io_methods.map {|m| file_or_io.respond_to?(m) }.all?
      yield file_or_io
    else
      path = file_or_io.respond_to?(:path) ? file_or_io.path : file_or_io.to_s

      File.open(path, "r") {|f| yield f }
    end
  end
  

  private_class_method :parser, :with_io
end
