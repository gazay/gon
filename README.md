# Gon gem — get your Rails variables in your js

If you need to send some data to your js files and you don't want to do this with long way through views and parsing - use this force!

## Usage

`app/views/layouts/application.html.erb`

``` erb
<head>
  <title>some title</title>
  <%= include_gon %>
  <!-- include your action js code -->
  ...
```

For camelize your variables in js you can use:

``` erb
<head>
  <title>some title</title>
  <%= include_gon(:camel_case => true) %>
  <!-- include your action js code with camelized variables -->
  ...
```

For different namespace of your variables in js you can use:

``` erb
<head>
  <title>some title</title>
  <%= include_gon(:namespace => 'serverExports') %>
  <!-- include your action js code with 'serverExports' namespace -->
  ...
```

In action of your controller you put something like this:

``` ruby
@your_int = 123
@your_array = [1,2]
@your_hash = {'a' => 1, 'b' => 2}
gon.your_int = @your_int
gon.your_other_int = 345 + gon.your_int
gon.your_array = @your_array
gon.your_array << gon.your_int
gon.your_hash = @your_hash

gon.all_variables # > {:your_int => 123, :your_other_int => 468, :your_array => [1, 2, 123], :your_hash => {'a' => 1, 'b' => 2}}
gon.your_array # > [1, 2, 123]

gon.clear # gon.all_variables now is {}
```

In javascript file for view of this action write call to your variable:

``` js
alert(gon.your_int)
alert(gon.your_other_int)
alert(gon.your_array)
alert(gon.your_hash)
```

With camelize:

``` js
alert(gon.yourInt)
alert(gon.yourOtherInt)
alert(gon.yourArray)
alert(gon.yourHash)
```

With custom namespace and camelize:

``` js
alert(customNamespace.yourInt)
alert(customNamespace.yourOtherInt)
alert(customNamespace.yourArray)
alert(customNamespace.yourHash)
```

## Installation

Puts this line into `Gemfile` then run `$ bundle`:

``` ruby
gem 'gon', '1.1.2'
```

Or if you are old-school Rails 2 developer put this into `config/environment.rb` and run `$ rake gems:install`:

``` ruby
config.gem 'gon', :version => '1.1.2'
```

Or manually install gon gem: `$ gem install gon`

## Contributors

* @gazay

Special thanks to @brainopia, @kossnocorp and @ai.

## License

The MIT License

Copyright (c) 2011 gazay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
