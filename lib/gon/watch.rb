class Gon
  class Watch < Gon
    class << self

      JS_FUNCTION = \
        "gon._timers = {};

         gon.watch = function(name, possibleOptions, possibleCallback) {
           var callback, key, options, performAjax, timer, value, _base, _ref, _ref1;
           if (typeof $ === 'undefined' || $ === null) {
             return;
           }
           if (typeof possibleOptions === 'object') {
             options = {};
             _ref = gon.watchedVariables[name];
             for (key in _ref) {
               value = _ref[key];
               options[key] = value;
             }
             for (key in possibleOptions) {
               value = possibleOptions[key];
               options[key] = value;
             }
             callback = possibleCallback;
           } else {
             options = gon.watchedVariables[name];
             callback = possibleOptions;
           }
           performAjax = function() {
             var xhr;
             xhr = $.ajax({
               type: options.type || 'GET',
               url: options.url,
               data: {
                 _method: options.method,
                 gon_return_variable: true,
                 gon_watched_variable: name
               }
             });
             return xhr.done(callback);
           };
           if (options.interval) {
             timer = setInterval(performAjax, options.interval);
             if ((_ref1 = (_base = gon._timers)[name]) == null) {
               _base[name] = [];
             }
             return gon._timers[name].push({
               timer: timer,
               fn: callback
             });
           } else {
             return performAjax;
           }
         };

         gon.unwatch = function(name, fn) {
           var index, timer, _i, _len, _ref;
           _ref = gon._timers[name];
           for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
             timer = _ref[index];
             if (timer.fn === fn) {
               clearInterval(timer.timer);
               gon._timers[name].splice(index, 1);
               return;
             }
           }
         };"

      def render
        JS_FUNCTION + "window.gon.watchedVariables=#{all_variables.to_json};"
      end

      def all_variables
        @watch_variables || {}
      end

      def clear
        @watch_variables = {}
      end

      private

      def set_variable(name, value)
        if return_variable?(name)
          return_variable value
        else
          variable = {}
          @watch_variables ||= {}
          env = Gon::Request.env
          variable['url'] = env['ORIGINAL_FULLPATH']
          variable['method'] = env['REQUEST_METHOD']
          variable['name'] = name

          @watch_variables[name] = variable
          super
        end
      end

      def return_variable?(variable)
        controller = Gon::Base.get_controller
        params = controller.params
        variable = variable.to_s.gsub('=', '')

        controller.request.xhr? &&
          params[:gon_return_variable] &&
          params[:gon_watched_variable] == variable
      end

      def return_variable(value)
        controller = Gon::Base.get_controller

        controller.render :text => value.to_json
      end

    end
  end
end
