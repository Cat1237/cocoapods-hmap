# frozen_string_literal: true

module HMap
  # A generic HMap error in execution.
  class HMapError < RuntimeError
  end

  # Raised when a file is not a HMap.
  class NotAHMapOError < HMapError
  end

  # Raised when a file is too short to be a valid HMap file.
  class TruncatedFileError < NotAHMapOError
    def initialize
      super 'File is too short to be a valid HMap'
    end
  end

  # Raised when a file's magic bytes are not valid HMap magic.
  class MagicError < NotAHMapOError
    # @param num [Integer] the unknown number
    def initialize(magic)
      super format('Unrecognized HMap magic: 0x%02<magic>x', magic: magic)
    end
  end

  # Raised when a class is not the class of obj.
  class ClassIncludedError < HMapError
    def initialize(cls1, cls2)
      super format('%<cls1>s must be the %<cls2>s of obj', cls1: cls1, cls2: cls2)
    end
  end
end
