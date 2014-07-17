class Gon
  module JsonDumper
    def self.dump(object)
      MultiJson.dump object,
        mode: :compat, escape_mode: :xss_safe, time_format: :ruby
    end
  end
end
