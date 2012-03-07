if RUBY_VERSION > '1.9' && defined?(Jbuilder)
  gem 'blankslate'
end
require 'action_view'
require 'action_controller'
require 'gon/helpers'
require 'gon/escaper'
if defined?(Rabl)
  require 'gon/rabl'
end
if RUBY_VERSION > '1.9' && defined?(Jbuilder)
  require 'gon/jbuilder'
end

module Gon
  class << self

    def all_variables
      @request_env['gon']
    end

    def clear
      @request_env['gon'] = {}
    end

    def request_env=(environment)
      @request_env = environment
      @request_env['gon'] ||= {}
    end

    def request_env
      if defined?(@request_env)
        return @request_env
      end
    end

    def request
      @request_id if defined? @request_id
    end

    def request=(request_id)
      @request_id = request_id
    end

    def method_missing(m, *args, &block)
      if ( m.to_s =~ /=$/ )
        if public_methods.include?(RUBY_VERSION > '1.9' ? m.to_s[0..-2].to_sym : m.to_s[0..-2])
          raise "You can't use Gon public methods for storing data"
        end
        set_variable(m.to_s.delete('='), args[0])
      else
        get_variable(m.to_s)
      end
    end

    def get_variable(name)
      @request_env['gon'][name]
    end

    def set_variable(name, value)
      @request_env['gon'][name] = value
    end

    %w(rabl jbuilder).each do |builder_name|
      define_method builder_name do |*options|
        if options.first.is_a? String
          warn "[DEPRECATION] view_path argument is now optional. If you need to specify it please use #{builder}(:template => 'path')"
          options = options.extract_options!.merge(:template => options[0])
        else
          options = (options && options.first.is_a?(Hash)) ? options.first : { }
        end

        builder_module = get_builder(builder_name)

        data = builder_module.send("parse_#{builder_name}", get_template_path(options, builder_name), get_controller(options))

        if options[:as]
          set_variable(options[:as].to_s, data)
        elsif data.is_a? Hash
          data.each do |key, value|
            set_variable(key, value)
          end
        else
          set_variable(builder_name, data)
        end
      end
    end
    alias_method :orig_jbuilder, :jbuilder

    def jbuilder(*options)
      raise NoMethodError.new('You can use Jbuilder support only in 1.9+') if RUBY_VERSION < '1.9'
      orig_jbuilder(*options)
    end

    private

    def get_builder(builder_name)
      begin
        "Gon::#{builder_name.classify}".constantize
      rescue
        raise NoMethodError.new("You should define #{builder_name.classify} in your Gemfile")
      end
    end

    def get_controller(options)
      options[:controller] ||
        @request_env['action_controller.instance'] ||
        @request_env['action_controller.rescue.response'].
        instance_variable_get('@template').
        instance_variable_get('@controller')
    end

    def get_template_path(options, extension)
      if options[:template]
        File.extname(options[:template]) == ".#{extension}" ? options[:template] : "#{options[:template]}.#{extension}"
      else
        "app/views/#{get_controller(options).controller_path}/#{get_controller(options).action_name}.json.#{extension}"
      end
    end

  end
end
