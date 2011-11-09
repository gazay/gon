# Gon gem — get your Rails variables in your js


If you need to send some data to your js files and you don't want to do this with long way through views and parsing - use this force!

Now with [Rabl](https://github.com/nesquena/rabl) support!

## An example of typical use

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
    ```

  2. In your js you get this by

    ``` js
    gon.variable_name
    ```

  3. profit?

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

## Usage with Rabl

Now you can write your variables assign logic to templates with [Rabl](https://github.com/nesquena/rabl).
The way of writing Rabl templates is very clearly described in their repo.

Profit of using Rabl with gon:

  1. You can clean your controllers now!
  2. Clear and easy work with database objects and collections
  3. All power of Rabl
  4. You can still be lazy and don't use common way to transfer data in js
  5. And so on

For using gon with Rabl you need to create new Rabl template and map gon
to it. 
For example you have model Post with attributes :title and :body.
You want to get all your posts in your js as an Array.
That's what you need to do:

  1. Create Rabl template. I prefer creating special directory for
     templates which are not view templates.

    `app/goners/posts/index.rabl`

    ``` rabl
    collection @posts => 'posts'
    attributes :id, :title, :body
    ```

  2. All you need to do after that is only to map this template to gon.

    `app/controllers/post_controller.rb#index`

    ``` ruby
    def index
      # some controller logic
      @posts = Post.all # Rabl works with instance variables of controller

      gon.rabl 'app/goners/posts/index.rabl'
      # some controller logic
    end
    ```

    Thats it! Now you will get in your js gon.posts variable which is Array of
    post objects with attributes :id, :title and :body.

In javascript file for view of this action write call to your variable:

``` js
alert(gon.posts)
alert(gon.posts[0])
alert(gon.posts[0].post.body)
```

P.s. If you didn't put include_gon tag in your html head area - it
wouldn't work. You can read about this in common usage above.

### Some tips of usage Rabl with gon:

If you don't use alias in Rabl template:

``` rabl
collection @posts
....
```

instead of using that:

``` rabl
collection @posts => 'alias'
....
```

Rabl will return you an array and gon by default will put it to variable
gon.rabl

Two ways how you can change it - using aliases or you can add alias to
gon mapping method:

``` ruby
# your controller stuff here

gon.rabl 'path/to/rabl/file', :as => 'alias'
```

## Installation

Puts this line into `Gemfile` then run `$ bundle`:

``` ruby
gem 'gon', '2.0.3'
```

Or if you are old-school Rails 2 developer put this into `config/environment.rb` and run `$ rake gems:install`:

``` ruby
config.gem 'gon', :version => '2.0.3'
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
