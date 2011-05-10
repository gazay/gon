# Gon gem — get your Rails variables in your js

If you need to send some data to your js files and you don't want to do this with long way trough views and parsing - use this force!

## Usage

`app/views/layouts/application.html.erb`

``` erb
<head>
  <title>some title</title>
  <%= include_gon %>
  <!-- include your action js code -->
  ...
```

In action of your controller you put something like this:

``` ruby
@your_int = 123
@your_array = [1,2]
@your_hash = {'a' => 1, 'b' => 2}
Gon.your_int = @your_int
Gon.your_other_int = 345 + @your_int
Gon.your_array = @your_array
Gon.your_hash = @your_hash
```

In javascript file for view of this action write call to your variable:

``` js
alert(Gon.your_int)
alert(Gon.your_other_int)
alert(Gon.your_array)
alert(Gon.your_hash)
```

## Installation

Puts this line into `Gemfile` then run `$ bundle`:

``` ruby
gem 'gon', '0.2.2'
```

Or if you are old-school Rails 2 developer put this into `config/environment.rb` and run `$ rake gems:install`:

``` ruby
config.gem 'gon', :version => '0.2.2'
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
