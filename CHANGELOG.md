# 3.1.1 (15 Apr 2013)

* Bugfix: remove `ember-rails` dependency in favor of `ember-source` (#32)

# 3.1.0 (12 Apr 2013)

* Feature: url authentication (`example.com?auth_token=lJfajl79`) (#27)
    (@seanrucker)
* Bugfix: previous remember me cookies are now cleared on successful sign in

# 3.0.4 (9 Apr 2013)

* Bugfix: `Auth.ajax`: behavior when customized with `data = null` (#25)

# 3.0.3 (9 Apr 2013)

* Bugfix: `Auth.ajax`: auth token not set when customized with `data` without
    overriding the corresponding token key (#25)

# 3.0.2 (6 Apr 2013)

* Bugfix: `Auth.ajax`: `contentType` not in sync with actual `data` type (#23)

# 3.0.0/3.0.1 (6 Apr 2013)

\* `3.0.0` contained errors. This has been fixed in `3.0.1` already.

* Major rewrite:
    * Mini Rails app for dev environment
    * Distribution files now built with `sprockets`
    * `rake` tasks substituted `cake` tasks
    * Added test suites, using `jasmine`
    * Moved distribution files from `lib/` to `dist/`
    * Moved source files from `src/` to `lib/`
    * Removed `component.json` in favor of auto-generation with git tags
    * Versioning centralized in `package.json`
    * Packaged as source gem
* Feature: `Auth.ajax` now customizable
* Feature: Authorization header supported
* Feature: Userland sign-in and sign-out controllers now extensible from any
    base controller, instead of being restricted to `Ember.ObjectController`
* BC Break: `Auth.ajax` signature changed
* BC Break: `Auth.Config.rememberUsingLocalStorage` is now
    `Auth.Config.rememberStorage`, with possible values
    `cookie` (default) and `localStorage`
* BC Break: `Auth.Config.requestHeaderAuthorization` is now
    `Auth.Config.requestTokenLocation`, with possible values
    `param` (default), `authHeader` and `customHeader`
* BC Break: `Auth.SignInController` and `Auth.SignOutController` are now mixins

Upgrade Guide
-------------

### Auth.ajax

Before:

```cofreescript
Auth.ajax('/url', 'POST', { foo: 'bar' })
```

After:

```coffeescript
Auth.ajax({ url: '/url', type: 'POST', foo: 'bar' })
```

### Auth.Config.rememberUsingLocalStorage

Before:

```coffeescript
Auth.Config.reopen { rememberUsingLocalStorage: false }
Auth.Config.reopen { rememberUsingLocalStorage: true }
```

After:

```coffeescript
Auth.Config.reopen { rememberStorage: 'cookie' } # or omit - default value
Auth.Config.reopen { rememberStorage: 'localStorage' }
```

### Auth.Config.requestHeaderAuthorization

Before:

```coffeescript
Auth.Config.reopen { requestHeaderAuthorization: false }
Auth.Config.reopen { requestHeaderAuthorization: true }
```

After:

```coffeescript
Auth.Config.reopen { requestTokenLocation: 'param' } # or omit - default value
Auth.Config.reopen { requestTokenLocation: 'customHeader' }
```

### Auth.SignInController / Auth.SignOutController

Before:

```coffeescript
App.SignInController = Auth.SignInController.extend({})
App.SignOutController = Auth.SignOutController.extend({})
```

After:

```coffeescript
App.SignInController = Em.ObjectController.extend(Auth.SignInController, {})
App.SignOutController = Em.ObjectController.extend(Auth.SignOutController, {})

# or use another base controller, e.g. Em.ArrayController
```

# 2.6.0 (4 Apr 2013)

* Feature: use `localStorage` instead of cookie for `RememberMe` (#20) (@iHiD)
* Feature: pass authentication token in request header (#19) (@seanrucker)
* Bugfix: empty `responseText` on a successful JSONP request (#15) (@iHiD)
* Bugfix: proper JSONP redirect support (#16) (@iHiD)

# 2.5.0 (3 Apr 2013)

* Feature: Authenticated requests available for non `ember-data` requests (#18)
    (@seanrucker)

# 2.4.1 (2 Apr 2013)

* Bugfix: set `Auth.currentUser` to `null` on sign out

# 2.4.0 (30 Mar 2013)

* Feature: auto-load current user

# 2.3.0 (30 Mar 2013)

* Remember me now auto-recalls user session upon visiting an `Auth.Route`

# 2.2.2 (27 Feb 2013)

* Remember me should not attempt to sign in user if one is already signed in

# 2.2.1 (23 Feb 2013)

* Remember me should be opt-in only

# 2.2.0 (23 Feb 2013)

* `Auth.Route.authAccess` event should not depend on redirection feature

# 2.1.0 (23 Feb 2013)

* Added an `authAccess` event on `Auth.Route`

# 2.0.0 (20 Feb 2013)

* Remember me feature - requires [jquery.cookie](https://github.com/carhartl/jquery-cookie)
* Added events
* Storing token API response jqxhr object in `Auth.jqxhr`
* [BC Break] `Auth.error` is removed in favor of `Auth.jqxhr`

# 1.1.0 (18 Feb 2013)

* Added `Auth.Config.baseUrl` hook.
