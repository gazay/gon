require 'oj'

class Gon
  module JsonDumper
    def self.dump(object)
      Oj.dump(object, mode: :compat, time_format: :ruby)
    end
  end

  # NOTE : If we are using Oj, gsub works only with \u, not \\u
  module Escaper
    def self.escape_line_separator(javascript)
      javascript.gsub(/\u2028/u, '&#x2028;')
    end
  end
end
