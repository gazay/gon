gon._timers = {};

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
    return performAjax();
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
};
