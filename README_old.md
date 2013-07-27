# Gon gem — get your Rails variables in your js

![Gon. You should try this. If you look closer - you will see an elephant.](https://github.com/gazay/gon/raw/master/doc/logo_small.png)


### Build Status ![http://travis-ci.org/gazay/gon](https://secure.travis-ci.org/gazay/gon.png)

If you need to send some data to your js files and you don't want to do this with long way through views and parsing - use this force!

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

To camelize your variables in js you can use:

``` erb
<head>
  <title>some title</title>
  <%= include_gon(:camel_case => true) %>
  <!-- include your action js code with camelized variables -->
  ...
```

You can change the namespace of the variables:

``` erb
<head>
  <title>some title</title>
  <%= include_gon(:namespace => 'serverExports') %>
  <!-- include your action js code with 'serverExports' namespace -->
  ...
```

You can initialize window.gon = {}; on each request

``` erb
<head>
  <title>some title</title>
  <%= include_gon(:init => true) %>
  <!-- include your action js code with 'serverExports' namespace -->
  ...
```

You can initialize script tag with type="text/javascript"

``` erb
<head>
  <title>some title</title>
  <%= include_gon(:need_type => true) %>
  <!-- include your action js code with 'serverExports' namespace -->
  ...
```

You can get json without script tag (kudos to @afa):

``` erb
<head>
  <title>some title</title>
  <script><%= include_gon(:need_tag => false) %></script>
  <!-- include your action js code with 'serverExports' namespace -->
  ...
```

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

You can write your variables assign logic to templates with [Rabl](https://github.com/nesquena/rabl).
The way of writing Rabl templates is very clearly described in their repo.

Add Rabl to your Gemfile before requiring gon - because gon checks Rabl constant

  `Gemfile`

  ``` ruby
  gem 'rabl'
  ...
  gem 'gon'
  ```

Profit of using Rabl with gon:

  1. You can clean your controllers now!
  2. Work with database objects and collections clearly and easyly
  3. All power of Rabl
  4. You can still be lazy and don't use common way to transfer data in js
  5. And so on

For using gon with Rabl you need to create new Rabl template and map gon
to it.
For example you have model Post with attributes :title and :body.
You want to get all your posts in your js as an Array.
That's what you need to do:

  1. Create Rabl template. You can choose spepicific directory but better
     use default directory for action.

    `app/views/posts/index.json.rabl`

    ``` rabl
    collection @posts => 'posts'
    attributes :id, :title, :body
    ```

  2. If you create template in default directory for action, you just write in this action:

    `app/controllers/posts_controller.rb#index`

    ``` ruby
    def index
      # some controller logic
      @posts = Post.all # Rabl works with instance variables of controller

      gon.rabl
      # some controller logic
    end
    ```

     But if you choose some specific category - you need to map this template to gon.

    `app/controllers/posts_controller.rb#index`

    ``` ruby
    def index
      # some controller logic
      @posts = Post.all # Rabl works with instance variables of controller

      gon.rabl :template => 'app/goners/posts/index.rabl'
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

gon.rabl :as => 'alias'
```

## Usage with Jbuilder

Use gon with [Jbuilder](https://github.com/rails/jbuilder) as with [Rabl](https://guthub.com/nesquena/rabl):

  0. Add jbuilder to your Gemfile (because of it depends on
     ActiveSuppurt '~> 3.0.0')

    `Gemfile`

    ``` ruby
    gem 'jbuilder'
    ```

  1. Create Jbuilder template.

    `app/views/posts/index.json.jbuilder`

    ``` jbuilder
    json.posts @posts, :id, :title, :body
    ```

  2. In your controller you should just call 'gon.jbuilder' - if your template in
     default directory for action. In the other case - you still can use :template option.

    ``` ruby
    def index
      # some controller logic
      @posts = Post.all

      gon.jbuilder
      # some controller logic
    end
    ```

In javascript file for view of this action write call to your variable:

Now you can use partials in jbuilder:

`app/views/posts/index.json.jbuilder`

``` jbuilder
json.partial! 'app/views/posts/_part.json.jbuilder', :comments => @posts[0].comments
```

`app/views/posts/_part.json.jbuilder`

``` jbuilder
json.comments comments.map { |it| 'comment#' + it.id }
```

``` js
alert(gon.posts)
alert(gon.posts[0])
alert(gon.posts[0].post.body)
alert(gon.comments)
alert(gon.comments[0])
```

P.s. If you didn't put include_gon tag in your html head area - it
wouldn't work. You can read about this in common usage above.

## gon.global

Now you can use gon for sending your data to js from anywhere!

It works just as simple `gon` but you need to write `Gon.global` instead of `gon` in your ruby code,
`gon.global` in javascript and it will not clear self after each request. All other things remain the same.

For example I want to set start data into gon, which will be there before I clear it.

Maybe some configuration data or url address which should be present on each page with `include_gon` helper in head.

Now with Gon.global it's easy!

`config/initializers/some_initializer.rb or any file where you can reach Gon constant`

```ruby
Gon.global.variable = 'Some data'
```

`in some js which can reach window.gon variable`

```javascript
alert(gon.global.variable)
```

Thats it!

## Installation

Puts this line into `Gemfile` then run `$ bundle`:

``` ruby
gem 'gon', '3.0.5'
```

Or if you are old-school Rails 2 developer put this into `config/environment.rb` and run `$ rake gems:install`:

``` ruby
config.gem 'gon', :version => '3.0.5'
```

Or manually install gon gem: `$ gem install gon`

## Contributors

* @gazay

Special thanks to @brainopia, @kossnocorp and @ai.

## License

The MIT License

Copyright (c) 2011-2012 gazay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
