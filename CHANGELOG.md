# CHANGELOG

## 6.0.1

  * Free dependencies

## 6.0.0

  * Refactoring
  * nonce option. Thanks to @joeljackson
  * Included rails url_helpers into jbuilder. Thanks to @razum2um
  * Welcome @takiy33 as contributor!

## 5.2.3

  * Coffescript implementation of watch.js. Thanks to @willcosgrove
  * unwatchAll function in watch.js. Thanks to @willcosgrove

## 5.2.2

  * add support for controller helper methods in jbuilder

## 5.2.1

  * fix for jbuilder module. Thanks to @jankovy
  * merge variable feature (for merge hash-like variables instead of overriding them). Thanks to @jalkoby

## 5.2.0

  * fix issue where include_gon would raise exception if the controller did not assign any gon variables. Thanks to @asalme
  * namespace_check option. Thanks to @tommyh
  * Only inject gon into ActionController::Base-like object in spec_helper. Thanks to @kevinoconnor7
  * AMD compatible version of including gon. Thanks to @vijoc

## 5.1.2

  * Clarifying helpers, dump gon#watch content to safe json before render. Thanks to @Strech

## 5.1.1

  * global_root option. Thanks to @rafaelliu
  * MultiJson support. Thanks to @Strech

## 5.1.0

  * Many fixes https://github.com/gazay/gon/compare/91845f3f0debd0cb8fa569aad65f5dc40a7e28e5...8dc7400fbb83ba5a086bd36c76342a393690d53f
  * Thanks to @Silex, @kilefritz, @irobayna, @kyrylo, @randoum, @jackquack, @tuvistavie, @Strech for awesome commits and help!

## 5.0.4

  * Fix check for get and assign variables for Gon.global

## 5.0.3

  * Revert changes in gemspec

## 5.0.2

  * Fix issue when there is no gon object for current thread and
    rendering include_gon (#108 part) (wasn't fixed) (@gregmolnar)

## 5.0.1

  * Fix issue when there is no gon object for current thread and
    rendering include_gon (#108 part)

## 5.0.0

  * Gon is threadsafe now! (@razum2um)
  * Camelcasing with depth (@MaxSchmeling)
  * Optional CDATA and style refactoring (@torbjon)
  * jBuilder supports not only String and Hash types of locals
    (@steakchaser)
  * Using ActionDispatch::Request#uuid instead of
    ActionDispatch::Request#id (@sharshenov)

## 4.1.1

  * Fixed critical XSS vulnerability https://github.com/gazay/gon/issues/84 (@vadimr & @Hebo)

## 4.1.0

  * Refactored script tag generation (@toothrot)
  * Stop support for MRI 1.8.7
  * Added rabl-rails support (@jtherrell)
  * Accepting locals in jbuilder templates

## 4.0.3

  * Added new method `Gon#push` for assign variables through Hash-like
    objects (@topdev)
  * Fixes for 1.8.7 compatibility.
  * !!!IMPORTANT!!! Last version with compatibility for MRI 1.8.7

## 4.0.2

  * Fixed gon.watch in JS without callback and options

## 4.0.1

  * Removed BlankSlate requirement *Peter Schröder*
  * Gon#set_variable and Gon#get_variable moved to public scope
  * Added option :locals to gon.rabl functionality

## 4.0.0

  * Added gon.watch functionality (thanks to @brainopia and @kossnocorp)
  * Compatibility with jbuilder paths for partial! method
  * Fixed some bugs
  * Little bit refactoring - Gon now is a class

## 3.0.3

  * Include ActionView::Helpers into Gon::JBuilder
  * Added init option (@torbjon)

## 3.0.2

  * Added need_tag option (@afa)

## 3.0.0

  * Almost all code refactored
  * Added Gon.global for using gon everywhere
  * Included ActionView::Helpers into Rabl::Engine

## 2.3.0

  * Don't really remember what was before this version
