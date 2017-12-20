# Represents an ANSI X.12 Element
module REX12; class Element
  # @return [String] base text value of the element (does not break up sub elements)
  attr_reader :value

  # @return [Integer] zero based location of this element in its parent segment
  attr_reader :position

  # @param value [String] base text value of the element
  # @param sub_element_separator [String] character that should be used to split sub elements
  # @param position [Integer] zero based position of this element in its parent segment
  def initialize value, position
    @value = value.freeze
    @position = position.freeze
  end

  # @return [true, false] does the element have sub elements
  def sub_elements?
    false
  end

  def to_s
    value
  end

  protected
    def value= v
      @value = v
    end

    def position= pos
      @position = pos
    end
end; end
