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
