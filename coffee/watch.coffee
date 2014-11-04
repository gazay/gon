gon._timers = {}

gon.watch = (name, possibleOptions, possibleCallback) ->
  return unless $?

  if typeof possibleOptions == 'object'
    options = {}
    for key, value of gon.watchedVariables[name]
      options[key] = value
    for key, value of possibleOptions
      options[key] = value
    callback = possibleCallback
  else
    options = gon.watchedVariables[name]
    callback = possibleOptions
  performAjax = ->
    xhr = $.ajax
      type: options.type || 'GET'
      url: options.url
      data:
        _method: options.method
        gon_return_variable: true
        gon_watched_variable: name
    xhr.done(callback)

  if options.interval
    timer = setInterval(performAjax, options.interval)
    gon._timers[name] ?= []
    return gon._timers[name].push
      timer: timer
      fn: callback
  else
    return performAjax()

gon.unwatch = (name, fn) ->
  for timer, index in gon._timers[name] when timer.fn == fn
    clearInterval(timer.timer)
    gon._timers[name].splice(index, 1)
    return

gon.unwatchAll = ->
  for variable, timers of gon._timers
    for timer in timers
      clearInterval(timer.timer)
  gon._timers = {}
