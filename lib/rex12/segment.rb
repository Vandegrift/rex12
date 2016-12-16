module REX12; class Segment
  # @return [String] raw text of segment
  attr_reader :value

  # @return [Integer] zero based position in file
  attr_reader :position

  def initialize value, element_separator, sub_element_separator, position
    @value = value
    @position = position
    make_elements(value,element_separator,sub_element_separator)
  end

  # @return [Array<REX12::Element>, nil] get all elements as array or yield to block
  def elements
    if block_given?
      @elements.each {|el| yield el}
      return nil
    end
    # making a fresh array so nobody can screw with the internals of the class
    @elements.clone
  end

  # @return [String] text representation of first element (like: ISA or REF)
  def segment_type
    @elements.first.value
  end

  def make_elements value, element_separator, sub_element_separator
    @elements = []
    value.split(element_separator).each_with_index do |str,pos|
      @elements << REX12::Element.new(str,sub_element_separator,pos)
    end
  end
  private :make_elements
end; end
