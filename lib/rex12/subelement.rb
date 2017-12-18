module REX12; class SubElement

  attr_reader :value
  attr_reader :position

  def initialize value, position
    @value = value.freeze
    @position = position.freeze
  end

  def to_s
    value
  end
end; end;