class Gon::Partial
  def initialize()
    @data = {}
  end

  def clear
    @data = {}
  end

  def method_missing(m, *args, &block)
    @data ||= {}

    if ( m.to_s =~ /=$/ )
      if public_methods.include? m.to_s[0..-2].to_sym
        raise "You can't use Gon public methods for storing data"
      end
      set_variable(m.to_s.delete('='), args[0])
    else
      get_variable(m.to_s)
    end
  end
  
  def set_variable(name, value)
    @data[name] = value
  end
  
  def get_variable(name)
    @data[name]
  end

  def all_variables
    @data
  end
end
