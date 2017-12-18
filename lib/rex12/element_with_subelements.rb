module REX12; class ElementWithSubElements < REX12::Element

  attr_reader :sub_element_separator

  def initialize sub_elements, position, separator
    super(nil, position)
    @sub_elements = sub_elements.freeze
    @sub_element_separator = separator
  end

  # @return [true, false] does the element have sub elements
  def sub_elements?
    true
  end

  # Get all sub elements as an array or yield them to a block
  # @return [Array<SubElement>, nil]
  def sub_elements
    if block_given?
      @sub_elements.each {|se| yield se }
      return nil
    end

    return @sub_elements.to_enum { @sub_elements.length }
  end

  def to_s
    @sub_elements.map(&:to_s).join(@sub_element_separator)
  end

  def [](index)
    @sub_elements[index]
  end

end; end