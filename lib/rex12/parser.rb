# This classes sole purpose is to read an IO object containing EDI text and turn
# it into the REX12 component classes.
#
module REX12; class Parser

  # Reads EDI data from the given IO object and returns a REX12::Document
  # model of the whole EDI file
  def document io
    REX12::Document.new(each_segment(io).to_a)
  end

  # Reads EDI data from the given IO object and returns an enumeration of the EDI segments as REX12::Segment objects.
  # If a block is given, segments will be yielded.

  # NOTE: The ISA line will be returned as a specialized REX12::IsaSegment class, which subclasses REX12::Segment
  def each_segment io
    metadata = parse_metadata io
    segments = []
    each_line(io, metadata) do |line_counter, segment|
      if block_given? 
        yield segment
      else
        segments << segment
      end
    end

    block_given? ? nil : segments.to_enum { segments.length }
  end

  # Reads EDI data from the received IO object.
  # If a block is given, yields all REX12::Transaction objects read from the EDI in sequence
  # If no block is given, an Enumerator of REX12::Transactions is returned
  def each_transaction io
    metadata = parse_metadata io

    # At this point we can read through the io "line" by "line" utilizing the segment_terminator as the linefeed character
    # I'm not exactly sure what to use as the max line length here, so I'm just going to basically negate it by using 
    # a value of 1 million
    isa_segment = nil
    gs_segment = nil
    segments = []
    transactions = []
    each_line(io, metadata) do |line_counter, segment|
      
      if metadata.segment_markers[:isa] == segment.segment_type
        isa_segment = segment
        next
      end

      case segment.segment_type
      when metadata.segment_markers[:gs]
        gs_segment = segment
      when metadata.segment_markers[:iea], metadata.segment_markers[:ge]
        # Do nothing, we don't care about the trailer segments if we're procssing the data transaction by 
        # transaction...they do nothing for us except act as potential checksums for segment counts..which 
        # we're not bothering with
      else
        next if segment.segment_type.nil?

        segments << segment

        if segment.segment_type == metadata.segment_markers[:se]
          transaction = REX12::Transaction.new(isa_segment, gs_segment, segments)

          if block_given?
            yield transaction
          else
            transactions << transaction
          end

          segments = []
        end
      end
    end
    
    block_given? ? nil : transactions.to_enum { transactions.length }
  end

  class DocumentMetadata

    attr_reader :encoding, :segment_markers, :segment_terminator, :element_delimiter, :sub_element_separator

    def initialize encoding, segment_markers, segment_terminator, element_delimiter, sub_element_separator
      @encoding = encoding
      @segment_markers = segment_markers.freeze
      @segment_terminator = segment_terminator.freeze
      @element_delimiter = element_delimiter.freeze
      @sub_element_separator = sub_element_separator.freeze
    end

  end

  def self.required_io_methods
    [:pos, :rewind, :readchar, :each_line]
  end

  private

    def each_line io, metadata
      line_counter = -1
      isa_seen = false
      io.each_line(metadata.segment_terminator, 1_000_000).each do |segment_line|
        next if segment_line.length == 0

        line_counter += 1

        # Strip the segment terminator off the line before we parse it
        segment_line = segment_line[0..-(1 + metadata.segment_terminator.length)]

        segment = (parse_edi_line(segment_line, line_counter, metadata))

        if metadata.segment_markers[:isa] == segment.segment_type
          raise "Invalid EDI.  Only 1 ISA segment is allow per EDI file." if isa_seen
          isa_seen = false
        end

        yield line_counter, segment
      end
      nil
    end

    def parse_edi_line segment_line, line_counter, metadata
      # Handle isa segments a little different
      if segment_line.start_with?(metadata.segment_markers[:isa])
        isa_segment = parse_isa(segment_line, line_counter, metadata)
      else    
        segment = parse_line(segment_line, line_counter, metadata)
      end
    end

    def parse_line line, line_counter, metadata
      elements = []
      # Ruby's split function by default compresses elements together if there are no trailing positions, we don't want this here
      # we want every position accounted for...hence the -1 argument as the limit value
      # .ie NOT 'SLN*1****'.split('*') -> ["SLN", "1"] ---- We want ["SLN", "1", "", "", "", ""]
      line.split(metadata.element_delimiter, -1).each_with_index do |element, index|  
        split_element = element.split(metadata.sub_element_separator, -1)
        if split_element.length > 1
          sub_elements = []
          split_element.each_with_index {|v, x| sub_elements << REX12::SubElement.new(v, x) }

          elements << REX12::ElementWithSubElements.new(sub_elements, index, metadata.sub_element_separator)
        else
          elements << REX12::Element.new(element, index)
        end
      end

      REX12::Segment.new elements, line_counter
    end

    def parse_isa line, line_counter, metadata
      elements = []
      split_segment = line.split(metadata.element_delimiter, -1)
      split_segment.each_with_index do |element, index| 
        # There's no subelements in the isa
        elements << REX12::Element.new(element, index)
      end

      REX12::IsaSegment.new elements, line_counter, metadata.segment_terminator, metadata.element_delimiter, metadata.sub_element_separator
    end

    def parse_metadata io
      # Record the initial position so we can rewind back to it
      initial_position = io.pos

      # Read out 107 chars from the io object to determine ISA data
      isa_chars = []

      # Use readchar instead of bytes so that we're letting the IO stream handle any character
      # encoding for us

      106.times { isa_chars << io.readchar }

      encoding = isa_chars[0].encoding
      segment_markers = encoded_segment_markers(encoding)
      # We should have a full isa segment now, interrogate it to determine the segment terminator, element separator and subelement separator
      raise REX12::ParseError, "Invalid EDI.  All EDI documents must start with an ISA segment." unless isa_chars[0..2].join == segment_markers[:isa]

      element_delimiter = isa_chars[3]
      segment_terminator = determine_segment_terminator(encoding, isa_chars, segment_markers, io)
      sub_element_separator = isa_chars[104]      

      io.pos = initial_position

      return REX12::Parser::DocumentMetadata.new(encoding, segment_markers, segment_terminator, element_delimiter, sub_element_separator)
    rescue EOFError
      raise REX12::ParseError, "Invalid EDI.  All EDI documents must start with an ISA segment that is exactly 107 characters long - including the segment terminator."
    end

    def encoded_segment_markers document_encoding
      {
        isa: "ISA".encode(document_encoding), 
        gs: "GS".encode(document_encoding), 
        iea: "IEA".encode(document_encoding), 
        ge: "GE".encode(document_encoding),
        st: "ST".encode(document_encoding),
        se: "SE".encode(document_encoding)
      }
    end

    def determine_segment_terminator encoding, isa_chars, markers, io
      # Technically, allowing multi-character terminators is not valid EDI, but you 
      # see it happen ALL the time with EDI that's been hand editted from a client where \r\n is utilized.
      # It's a valid enough use-case that we're accounting specifically for a terminator character and/or cr/lfs
      terminator = isa_chars[105]

      raise REX12::ParseError, "Invalid EDI.  All EDI documents have a segment terminator character at position 106 of the ISA segment." if terminator.nil?

      next_char = io.readchar

      # If there's a single character terminator and the next char is the start of the GS segment, then everything is copacetic
      # and no need to continue looking for more terminator characters
      return terminator if markers[:gs][0] == next_char

      cr = "\r".encode(encoding)
      lf = "\n".encode(encoding)

      if next_char == cr || next_char == lf
        terminator << next_char

        # The only valid char at this point we'll accept as part of the terminator is a linefeed
        next_char = io.readchar
        if next_char == lf
          terminator << next_char
        else 
          raise REX12::ParseError, "Invalid ISA segment.  Could not determine segment terminator." unless markers[:gs][0] == next_char
        end
      elsif markers[:gs][0] != next_char
        raise REX12::ParseError, "Invalid ISA segment.  Could not determine segment terminator."
      end

      terminator
    end

end; end;
