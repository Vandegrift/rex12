# Represents an ANSI X.12 Element
module REX12; class Element
  # @return [String] base text value of the element (does not break up sub elements)
  attr_reader :value

  # @return [Integer] zero based location of this element in its parent segment
  attr_reader :position

  # @param value [String] base text value of the element
  # @param sub_element_separator [String] character that should be used to split sub elements
  # @param position [Integer] zero based position of this element in its parent segment
  def initialize value, sub_element_separator, position
    @value = value
    @sub_element_separator = sub_element_separator
    @position = position
  end

  # @return [true, false] does the element have sub elements
  def sub_elements?
    @value.index(@sub_element_separator) ? true : false
  end

  # Get all sub elements as an array or yield them to a block
  # @return [Array<String>, nil]
  def sub_elements
    r = @value.split(@sub_element_separator)
    if block_given?
      r.each {|se| yield se}
      return nil
    end
    return r
  end
end; end
