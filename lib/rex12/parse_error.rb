# Raised when there is an error parsing the syntax of the document
module REX12; class ParseError < StandardError
  # REX12::Segment that was being parsed when error was generated (may be nil)
  attr_reader :segment
  # REX12::Element that was being parsed when error was generated (may be nil)
  attr_reader :element
  def initialize message, segment=nil, element=nil
    super(message)
    @segment = segment
    @element = element
  end
end; end
