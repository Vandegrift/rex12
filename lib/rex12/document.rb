# methods for reading a full EDI file
#
# currently, the full text of the file is read into memory,
# but if you use the block form of the methods, then the subsequent ruby objects
# are created within the block loops so they can be garbage collected
module REX12; class Document

  # Parse the EDI document from file
  #
  # @return (see #parse)
  def self.read path_or_io
    if block_given?
      parse(file_text(path_or_io)) {|s| yield s}
      return nil
    else
      return parse(file_text(path_or_io))
    end
  end

  # Parse the EDI document from text or IO object
  #
  # @return [Array<REX12::Segment>,nil] all segments or nil for block form
  def self.parse text
    validate_isa(text)
    element_separator = text[3]
    segment_terminator = determine_segment_terminator(text)
    sub_element_separator = text[104]
    r = []

    text.split(segment_terminator).each_with_index do |seg_text,pos|
      next if seg_text.length == 0
      seg = REX12::Segment.new(seg_text,element_separator,sub_element_separator,pos)
      if block_given?
        yield seg
      else
        r << seg
      end
    end

    if block_given?
      return nil
    else
      return r
    end
  end

  # Parses the EDI document from text or IO object, returning or yielding every transaction from the 
  # document.
  #
  # @return [Array<REX12::Transaction>,nil] all transactions or nil for block form
  def self.each_transaction text
    isa = nil
    current_gs = nil
    current_segments = []
    transactions = []

    parse(text) do |segment|
      segment_type = segment.segment_type
      case segment_type
      when "ISA"
        isa = segment
      when "GS"
        current_gs = segment
      when "IEA", "GE"
        # Do nothing, we don't care about the trailer segments
      else
        current_segments << segment

        # If we found the transaction trailer, it means we can take all the current segments we have and process them
        if segment_type == "SE"
          transaction = REX12::Transaction.new(isa, current_gs, current_segments)

          if block_given? 
            yield transaction
          else
            transactions << transaction
          end

          current_segments = []
        end
      end
    end

    block_given? ? nil : transactions
  end

  def self.determine_segment_terminator text
    # Technically, allowing multi-character terminators is not valid EDI, but you 
    # see it happen ALL the time with EDI that's been hand editted from a client (especially on Windows).
    # It's a valid enough use-case that we're accounting for it.

    # no segement terminator, just CRLF
    return "\r\n" if text[105..106]=="\r\n"
    # no segement terminator, just CR or LF
    return text[105] if ["\r","\n"].include?(text[105])
    # segment terminator without CR or LF
    return text[105] if text[106]=='G'
    # segment terminator with CRLF
    return text[105..107] if text[106..107]=="\r\n"
    return text[105..106] if ["\r","\n"].include?(text[106]) && text[107]=="G"
    raise REX12::ParseError, "Invalid ISA / GS segements. Could not determine segment terminator."
  end
  private_class_method :determine_segment_terminator

  def self.validate_isa text
    raise REX12::ParseError, "EDI file must be at least 191 characters to include a valid envelope." unless text.length > 191
    str = text[0..2]
    raise REX12::ParseError, "First 3 characters must be ISA. They were '#{str}'." unless str=='ISA'
    return
  end
  private_class_method :validate_isa

  # Allow reading from an object that responds to #read or assume the given param is a string file path and read with IO
  def self.file_text path_or_io
    path_or_io.respond_to?(:read) ? path_or_io.read : IO.read(path_or_io)
  end
  private_class_method :file_text
end; end
