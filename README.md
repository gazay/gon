# Gon gem — get your Rails variables in your js

![Gon. You should try this. If you look closer - you will see an elephant.](https://github.com/gazay/gon/raw/master/doc/logo_small.png)

### Build Status [![Build Status](https://secure.travis-ci.org/gazay/gon.png)](http://travis-ci.org/gazay/gon)

If you need to send some data to your js files and you don't want to do this with long way through views and parsing - use this force!

Now you can easily renew data in your variables through ajax with [gon.watch](https://github.com/gazay/gon/wiki/Usage-gon-watch)!

With [Jbuilder](https://github.com/rails/jbuilder) and [Rabl](https://github.com/nesquena/rabl) support!

For Sinatra available [gon-sinatra](https://github.com/gazay/gon-sinatra).

For .Net MVC available port [NGon](https://github.com/brooklynDev/NGon).

## An example of typical use

### Very good and detailed example and reasons to use is considered in [railscast](http://railscasts.com/episodes/324-passing-data-to-javascript) by Ryan Bates

When you need to send some start data from your controller to your js
you might be doing something like this:

  1. Write this data in controller(presenter/model) to some variable
  2. In view for this action you put this variable to some objects by data
     attributes, or write js right in view
  3. Then there can be two ways in js:
    + if you previously wrote data in data
     attributes - you should parse this attributes and write data to some
  js variable.
    + if you wrote js right in view (many frontenders would shame you for
  that) - you just use data from this js - OK.
  4. You can use your data in your js

And everytime when you need to send some data from action to js you do this.

With gon you configure it firstly - just put in layout one tag, and add
gem line to your Gemfile and do the following:

  1. Write variables by

    ``` ruby
    gon.variable_name = variable_value

    # or new syntax
    gon.push({
      :user_id => 1,
      :user_role => "admin"
    })

    gon.push(any_object) # any_object with respond_to? :each_pair
    ```

  2. In your js you get this by

    ``` js
    gon.variable_name
    ```

  3. profit?

With `gon.watch` feature you can easily renew data in gon variables!
Just pass option `:watch => true` to `include_gon` method and call
`gon.watch` from your js file. It's super useful in modern web
applications!

## Usage

### More details about configuration and usage you can find in [gon wiki](https://github.com/gazay/gon/wiki)

Old readme available in [./README_old.md](https://github.com/gazay/gon/blob/master/README_old.md)


`app/views/layouts/application.html.erb`

``` erb
<head>
  <title>some title</title>
  <%= include_gon %>
  <!-- include your action js code -->
  ...
```

You can pass some [options](https://github.com/gazay/gon/wiki/Options)
to `include_gon` method.

You put something like this in the action of your controller:

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

Access the varaibles from your JavaScript file:

``` js
alert(gon.your_int)
alert(gon.your_other_int)
alert(gon.your_array)
alert(gon.your_hash)
```

## gon.watch - renew your data easily!

You can use gon for renewing your data without reloading pages and
writing long js functions! It's really
great for some live values.

Supports `gon.watch.rabl` and `gon.watch.jbuilder` usage.

[Instruction](https://github.com/gazay/gon/wiki/Usage-gon-watch) for
usage gon.watch.

## Usage with Rabl

You can write your variables assign logic to templates with [Rabl](https://github.com/nesquena/rabl).
The way of writing Rabl templates is very clearly described in their repo.

Profit of using Rabl with gon:

  1. You can clean your controllers now!
  2. Work with database objects and collections clearly and easyly
  3. All power of Rabl
  4. You can still be lazy and don't use common way to transfer data in js
  5. And so on

[Instruction](https://github.com/gazay/gon/wiki/Usage-with-rabl) for
usage gon with Rabl.

## Usage with Jbuilder

Use gon with [Jbuilder](https://github.com/rails/jbuilder) as with [Rabl](https://guthub.com/nesquena/rabl):

[Instruction](https://github.com/gazay/gon/wiki/Usage-with-jbuilder) for
usage gon with Jbuilder.

## gon.global

You can use gon for sending your data to js from anywhere! It's really
great for some init data.

[Instruction](https://github.com/gazay/gon/wiki/Usage-gon-global) for
usage gon.global.

## Contributors

* @gazay

Special thanks to @brainopia, @kossnocorp and @ai.

## License

The MIT License

Copyright (c) 2011-2012 gazay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
