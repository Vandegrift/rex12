module REX12; class Segment
  # @return [Integer] zero based position in file
  attr_reader :position

  def initialize elements, position
    @segment_elements = elements.freeze
    @position = position.freeze
  end

  # @return [Array<REX12::Element>, nil] get all elements as array or yield to block
  def elements
    if block_given?
      @segment_elements.each {|el| yield el}
      return nil
    else
      @segment_elements.to_enum { @segment_elements.length }
    end
  end

  def element index
    @segment_elements[index]
  end

  # @return [String] text representation of first element (like: ISA or REF)
  def segment_type
    self[0]
  end

  def [](index)
    el = element(index)
    el.nil? ? nil : el.value
  end

  def isa_segment?
    false
  end

end; end
