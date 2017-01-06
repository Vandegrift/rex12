# Represents a collection of all EDI elements between the ST/SE segments of a single EDI document transaction.
# An EDI document may have multiple transactions in it.
module REX12; class Transaction

  # @return REX12::Segment - The ISA segment from the EDI document this transaction belongs to
  attr_reader :isa_segment

  # @return REX12::Segment - The GS segment from the EDI document this transaction belongs to
  attr_reader :gs_segment

  # @return Array<REX12::Segment> - All the segments that comprise this EDI Transaction
  attr_reader :segments

  def initialize(isa_segment, gs_segment, segments)
    @isa_segment = isa_segment
    @gs_segment = gs_segment
    @segments = segments
  end
  
end; end