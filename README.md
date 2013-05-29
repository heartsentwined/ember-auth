ember-auth
==========

[![Build Status](https://secure.travis-ci.org/heartsentwined/ember-auth.png)](http://travis-ci.org/heartsentwined/ember-auth)
[![Gem Version](https://badge.fury.io/rb/ember-auth-source.png)](http://badge.fury.io/rb/ember-auth-source)
[![NPM version](https://badge.fury.io/js/ember-auth.png)](http://badge.fury.io/js/ember-auth)

`ember-auth` is an authentication framework for [ember.js](http://emberjs.com/).

**Important!** `ember-auth` is no replacement for secure server-side API code.
Read the [security page](https://github.com/heartsentwined/ember-auth/wiki/Security) for more information.

Documentation
=============

* Install:
  [Installation notes](https://github.com/heartsentwined/ember-auth/wiki/Install)
* Getting started:
  A [demo and tutorial](https://github.com/heartsentwined/ember-auth-rails-demo)
  for rails + devise + ember-auth is available.
* Full docs:
  at the [ember-auth site](http://ember-auth.herokuapp.com).
* Upgrade guide for users from previous Major Versions:
  at the [changelog](https://github.com/heartsentwined/ember-auth/blob/master/CHANGELOG.md)

Versioning
==========

`ember-auth` uses [Semantic Versioning](http://semver.org/) *strictly*.
Even the most minor BC-breaking change will trigger a major version bump.
That means you can safely use the
[pessimistic version constraint operator](http://docs.rubygems.org/read/chapter/16#page74)
(`~> 1.2`) for rubygems, or `>= 1.2 && < 2.0` for other dependency managers.

Contributing
============

[![Support ember-auth](http://www.pledgie.com/campaigns/19972.png?skin_name=chrome)](http://pledgie.com/campaigns/19972)

You are welcome! As usual:

1. Fork
2. Branch
3. Hack
4. **Test**
5. Commit
6. Pull request

Tests
-----

You can be lazy and just open a PR.
[Travis](https://travis-ci.org) will run the tests.

`ember-auth` tests are written in [jasmine](http://pivotal.github.com/jasmine/).

1. Grab a copy of ruby. [RVM](http://rvm.io/) recommended.
2. `bundle install` to install dependencies.
3. `jasmine-headless-webkit` or `(bundle exec) rake jasmine:headless`
   to run tests, or `guard` for continuous integration testing.

`ember-auth` has been setup with [guard](https://github.com/guard/guard),
which will continuously monitor lib and spec files for changes and re-run
the tests automatically.

Building distribution js files
------------------------------

`rake dist`. Or `bundle exec rake dist` if you are not using
[RVM](http://rvm.io/), or are not otherwise scoping the bundle.

License
=======

MIT
