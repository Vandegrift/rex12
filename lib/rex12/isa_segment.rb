module REX12; class IsaSegment < Segment
  attr_reader :segment_terminator
  attr_reader :element_delimiter
  attr_reader :sub_element_separator

  def initialize elements, position, segment_terminator, element_delimiter, sub_element_separator
    super(elements, position)
    @segment_terminator = segment_terminator.freeze
    @element_delimiter = element_delimiter.freeze
    @sub_element_separator = sub_element_separator.freeze
  end

  def isa_segment?
    true
  end

end; end;