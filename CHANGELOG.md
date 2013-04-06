# 3.0.0 (6 Apr 2013)

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
* BC Break: `Auth.ajax` signature changed
* BC Break: `Auth.Config.rememberUsingLocalStorage` is now
    `Auth.Config.rememberStorage`, with possible values
    `cookie` (default) and `localStorage`
* BC Break: `Auth.Config.requestHeaderAuthorization` is now
    `Auth.Config.requestTokenLocation`, with possible values
    `param` (default), `authHeader` and `customHeader`

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

# 2.6.0 (4 Apr 2013)

* Feature: use `localStorage` instead of cookie for `RememberMe`
* Feature: pass authentication token in request header
* Bugfix: empty `responseText` on a successful JSONP request
* Bugfix: proper JSONP redirect support

# 2.5.0 (3 Apr 2013)

* Feature: Authenticated requests available for non `ember-data` requests

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
