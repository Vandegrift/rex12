# Represents a full (raw) EDI file.
#
# currently, the full text of the file is read into memory,
# but if you use the block form of the methods, then the subsequent ruby objects
# are created within the block loops so they can be garbage collected
module REX12; class Document

  def initialize segments
    @segments = segments.freeze
  end

  def segments
    if block_given?
      @segments.each {|segment| yield segment}
      return nil
    else
      @segments.to_enum { @segments.length }
    end
  end

  def [] x
    @segments[x]
  end

end; end
