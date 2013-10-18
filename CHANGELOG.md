# 9.0.7 (19 Oct 2013)

* Bugfix: `auth#destroySession` should allow no argument (#117)

# 9.0.6 (14 Oct 2013)

* Fixed a (serious) typo causing `auth#send` to never resolve or reject

# 9.0.5 (14 Oct 2013)

* Add an `_ensurePromise` helper

# 9.0.0 - 9.0.4 (13 Oct 2013)

* BC Break: (Major rewrite)
* rewrite: use injection pattern (#70)
* rewrite: `ember-auth` now fully modular:
  - this repo now only contains core
  - easier upgrades: use semver on individual adapters and modules
* rewrite: elevate glue code for core method to `auth` object:
  `signIn`, `signOut`, `send`, `createSession`, `destroySession`
* rewrite: move from `trigger`-based events to promise-pattern handlers (#99)
* rewrite: adapters and modules now have base classes and namespaces
  - `Em.Auth.AuthRequest`, `Em.Auth.*AuthRequest`
  - `Em.Auth.AuthResponse`, `Em.Auth.*AuthResponse`
  - `Em.Auth.AuthStrategy`, `Em.Auth.*AuthStrategy`
  - `Em.Auth.AuthSessiong`, `Em.Auth.*AuthRequest`
  - `Em.Auth.AuthModule`, `Em.Auth.*AuthModule`
* enforce `Em.RSVP.Promise` support throughout (#99)
* `createSession` and `destroySession` now accept `canonicalize`d object
* `(session adapter).clear()` renamed to `(session adapter).end()`
* persistence lib modules: individual auto-load current user support (#107)
* `authRedirectable`: remove mixin in favor of flag declared in route
* `urlAuthenticatable`: use ember's [query params support][query params PR]
  (#98, #102, #104, #105)
* config renaming: `*Adapter` > `*` (`-Adapter` suffix dropped)
* config change: `urlAuthenticatable.params` is now an array of params
* default change: the `emberData` module is no longer enabled by default
* `json` response adapter no longer accepts an object; input must be a JSON
  string (or empty string)
* `dummy` response adapter now expects a JSON input string, and will return
  a `JSON.parse`d object
* better doc the source code
* drop ember pre-`1.0` support
* misc: fix #92, due to `urlAuthenticatable` no longer bundling `$.url`

[query params PR]: https://github.com/emberjs/ember.js/pull/3182

Upgrade Guide
-------------

This is a major rewrite on the architectural level. Most changes will require
a change in approach, instead of a one-liner one-to-one corresponding change.
You are encouraged to use both the [docs] and this upgrade guide for reference.

### Modular adapters and modules

First, everything has been broken down into its own module. You now need to
require every single `adapter` and `module` explicitly. Example: you had been
using the `jquery` request adapter, and the `rememberable` module, in node.

```sh
$ npm install ember-auth-request-jquery
$ npm install ember-auth-module-rememberable
```

(And remember to require / include the individual files.)

Refer to the [docs] for names of each adapter and module.

This should help keep your code size small. Now you will only include what
you actually use in code base, not, e.g. the `dummy` adapters intended for
unit-testing, or those modules that you don't use.

This should also allow you to pull in the latest upgrades, e.g. a BC Break on
module A won't stop you from upgrade other parts - it would only trigger a
major version bump on module A.

[docs]: http://ember-auth.herokuapp.com/docs

### Versioning

You should use the [pessimistic version constraint operator][pessi ver op] -
(`~> 1.2`) for rubygems, or `>= 1.2 && < 2.0` for other dependency managers -
on each adapter, module, and `ember-auth` core itself. (The `1.2` and `2.0`
versions are just dummy examples.)

Each adapter, module, and the core, will adhere to semantic versioning
*individually*. You can safely upgrade their minor versions and patches.

The `ember-auth` core (this repo) will continue at `9.x`; but all other repos
(all adapters and modules) (re)start at version `1.x`.

[pessi ver op]: http://docs.rubygems.org/read/chapter/16#page74

### Upgrade ember libs

Ember pre-`1.0` support has been dropped. Upgrade ember to latest stable
version. But if you use `urlAuthenticatable`, then you'll need latest master
build - at least one that includes [#3182][query params PR] and
[#3383][query params order change PR].

[query params order change PR]: https://github.com/emberjs/ember.js/pull/3383

If you are using `ember-data`, upgrade also to latest. At the time of writing,
`1.0.x` is still in beta, so just grab the latest beta, or latest master.

If you are using `ember-model`, you'll need at least `0.0.10`.

### `extend` from `Em.Auth`

Before:

```coffeescript
App.Auth = Em.Auth.create()
```

After:

```coffeescript
App.Auth = Em.Auth.extend()
```

### All adapters required

Previous versions allow you to rely on `ember-auth`'s defaults to use the
default adapters:

* `request`: `jquery`
* `response`: `json`
* `strategy`: `token`
* `session`: `cookie`

These are still the default, but you will need to expliclitly include the
adapters. They are no longer bundled with `ember-auth`.

### Injected `auth` object

By default, you can access `this.auth` from routes, controllers, and views.
(Hence also from templates.)

Change `App.Auth.*` references to `this.auth.*`.

Before:

```coffeescript
# inside route, controller, or view
App.Auth.signIn()
App.Auth.get('signedIn')
```

```text
{{App.Auth.signedIn}}
```

After:

```coffeescript
# inside route, controller, or view
@auth.signIn()
@auth.get('signedIn')
```

```text
{{auth.signedIn}}
```

If you need to access them elsewhere, the `auth` object is registered in the
container as `auth:main`. Just inject it into wherever you want.

### Event handlers

Before:

```coffeescript
App.Auth.on 'signInSuccess', doSomething()
```

After:

You can now register `promise` handlers for each individual server request:

```coffeescript
@auth.signIn().then -> doSomething()
```

Or register a handler for all requests:

```coffeescript
@auth.addHandler 'signInSuccess', doSomething()
```

`doSomething()` can also return a promise - such that `ember-auth` won't
proceed until your promise resolves / rejects.

Refer to the [docs] for full details on this pattern.

The `*Complete` event has been removed; it has no equivalent in the new
architecture. You'll have to repeat it in both `.then()` and `.fail()`, or
register it on both `*Success` and `*Error`.

### Config renaming

Remove the `-Adapter` suffix.

Before:

```coffeescript
App.Auth = Em.Auth.create { requestAdapter: 'jquery' }
```

After:

```coffeescript
App.Auth = Em.Auth.extend { request: 'jquery' }
```

### `urlAuthenticatable`

**Pre-req**: `urlAuthenticatable` now uses ember's own query params support.
You'll need an ember build that includes at least [#3182][query params PR] and
[#3383][query params order change PR].
Also note [#3350][global query params issue].

[global query params issue]: https://github.com/emberjs/ember.js/issues/3550

Enable the query params feature.

```coffeescript
Em.FEATURES['query-params'] = true
```

Define your params.
[#3182][query params PR] and [#3350][global query params issue] for syntax.

Params are no longer required to be scoped inside another root level param.

Before:

```coffeescript
App.Auth = Em.Auth.create
  urlAuthenticatable:
    paramsKey: 'auth'

# capturing all `?auth[email]=xxx&auth[password]=xxx` params
```

After:

```coffeescript
App.Auth = Em.Auth.extend
  urlAuthenticatable:
    params: ['email', 'password']

# capturing all `?email=xxx&password=xxx` params
```

This might necessitate change on your server end point, or code that generate
the url itself.

`urlAuthenticatable` no longer needs `$.url` / `purl` , and the library is no
longer bundled with the module. Include the module yourself if you need to
use it. - Although you shouldn't have relied on `ember-auth` bundling a lib
in the first place anyway.

### `emberData` no longer included by default

Before:

```coffeescript
App.Auth = Em.Auth.create
  # rely on the default `modules: ['emberData']`
```

After:

```coffeescript
App.Auth = Em.Auth.extend
  modules: ['emberData'] # declare explicitly
```

### Auto-load current user

The `emberData`, `epf`, and `emberModel` modules now support auto-load
current user according to the api of each of the persistence libs. You can
remove userland code patches that provide this behavior.

`emberData`:

```coffeescript
App.Auth = Em.Auth.extend
  modules: ['emberData']
  emberData:
    userModel: 'member'

# will call store.find('member', id)
```

`epf`:

```coffeescript
App.Auth = Em.Auth.extend
  modules: ['epf']
  epf:
    userModel: 'member'

# will call session.load('member', id)
```

`emberModel`:

```coffeescript
App.Auth = Em.Auth.extend
  modules: ['emberModel']
  emberModel:
    userModel: 'App.Member'

# will call App.Member.fetch(id)
```

### `authRedirectable`

The `App.Auth.AuthRedirectable` mixin is gone. You can now simply declare an
`authRedirectable` property to be `true` on the route.

Before:

```coffeescript
App.ProtectedRoute = Em.Route.extend(App.Auth.Authredirectable, {})
```

After:

```coffeescript
App.ProtectedRoute = Em.Route.extend
  authRedirectable: true
```

### `createSession` and `destroySession`

They now accept an object, which should be the object that would have returned
from calling `(response adapter).canonicalize()` on the raw text response.

For most use cases, that just means you can rewrite the code more clearly by:

Before:

```coffeescript
App.Auth.createSession '{"foo":"bar"}'
```

After:

```coffeescript
@auth.createSession { foo: 'bar' }
```

The text form is still supported, but `(response adapter).canonicalize()` will
now be called whenever `typeof` the argument is `string`.

`auth.destroySession()` now has the same signature as `auth.createSession()`.
You can pass an empty object to it if you are just clearing the session, and
don't need any params on it.

```coffeescript
@auth.destroySession {}
```

### `json` response adapter

The `json` response adapter no longer accepts an object. The input must be a
JSON string. Or an empty string.

### `dummy` response adapter

The `dummy` response adapter now expects a JSON input string, and will return
a `JSON.parse`d object. The previous behavior was passing through the input
unaltered.

### Accessing custom response data

Previously, `(auth).get('response')` holds the response data from the last
request. This has been removed. (`auth.response` is now the config key for the
response adapter.) Instead, access the response data through the returned
promise.

```coffeescript
@auth.signIn().then( (response) ->
  # `response` is the object holding response data for this request
).fail (response) ->
  # `response` is the object holding response data for this request
```

### Using request, response, strategy, session adapter methods directly

If you had been using, e.g. `auth._response.canonicalize()`, directly,
note that all the public API for adapters has been standardized and declared
in both the [docs] and the source code (in the base class, e.g.
`lib/request.em` for the request adapter base class).

Make sure your calls conform to what `ember-auth` expects. Or better, try to
use only those declared public methods on the `auth` object.

`(session adapter).clear()` has been renamed to `(session adapter).end()`.

### Customized adapters and modules

If you had been writing customized adapters, there is now an official public
API that your adapter is supposed to implement. This is documented in both the
[docs] and the source code (in the base class, e.g. `lib/request.em` for the
request adapter base class).

Make sure your custom adapter conform to what `ember-auth` expects.

They should also extend from the base class. e.g.

```coffeescript
App.CustomAuthRequest = Em.Auth.AuthRequest.extend()
```

You should also

* either name your custom adapter like `App.FooAuthRequest`, for a
  corresponding usage of `App.Auth = Em.Auth.extend { request: 'foo' }`
* or register it in the container as `authRequest:foo`, for the same usage

Modules should extend from `Em.Auth.AuthModule`, and

* either named like `App.CustomLibAuthModule`, for
  `App.Auth = Em.Auth.extend { modules: ['customLib'] }`
* or registered as `authModule:customLib`, same usage

Make use of the `auth._config` setter and setter for configs. It handles
the recursive merging of namespaced configs like

```coffeescript
App.Auth = Em.Auth.extend { rememberable: { tokenKey: 'foo' } }
```

You are also encouraged to use `auth.addHandler` for most post-sign in (etc)
logic. Refer to the offcial modules for reference implementation.

# 8.0.1 (10 Sep 2013)

* fix a failing `actionRedirectable` spec
* `emberData` and `epf` will now delegate to their own `ajax` methods
  instead of going through `ember-auth`'s'

# 8.0.0 (30 Aug 2013)

* BC Break: top level namespace is now `Ember::Auth`, and require path is now
  `require 'ember/auth/source'` (#82)

Upgrade Guide
-------------

If you had been using the ruby source gem directly, just change all
`EmberAuth` (module name) to `Ember::Auth`. File locations have also moved
from `lib/ember-auth` to `lib/ember/auth`.

# 7.2.0 (30 Aug 2013)

* [`epf`][epf] support (#81)
* auto-load current user feature now works with `model.find()` returning
  a promise
* promise-related features now utilize `Ember.RSVP`
* url end points now overridable for `signIn` and `signOut` methods,
  along with an accompanying `endPoint` option for `rememberable` and
  `urlAuthenticatable` (#90)

[epf]: http://epf.io

# 7.1.3 (28 Aug 2013)

* Fixed [`ember-model`] support (#78, #94, #95) (@maoe, @flynfish)

# 7.1.2 (22 Aug 2013)

* Updated `$.url`/`purl` library version (#92)

# 7.1.1 (15 Aug 2013) (yanked)

* Added tests for ember `1.0.0.rc6.4` and `1.0.0.rc7`
* Fix typo in dummy request adapter (#86) (@zeppelin)
* Updated `emberModel` module to work with latest api (#84) (@maoe)

# 7.1.0 (10 Jul 2013)

* [`ember-model`][ember-model] support (#53)
* `auth.createSession()` and `auth.destroySession()`: manually injecting and
  clearing auth sessions without hitting the server (#67)
* `auth.startTime`: start time of the current session (cleared on sign out)
* `auth.endTime`: end time of the last session (cleared on sign in)
* `timeoutable` module (#62)
* Bugfix: resolve promises to allow chaining (#75)

[ember-model]: https://github.com/ebryn/ember-model

# 7.0.2 (5 Jul 2013)

* Drop `ember` `1.0.0.rc6` support
  * Critical bug at emberjs/ember.js#2946
  * First compatible release at `ember` `1.0.0.rc6.2`

# 7.0.1 (5 Jul 2013)

* Add `.DS_Store` to `.gitignore` (#73) (@kiwiupover)
* More robust `json` `responseAdapter` (#74) (@kiwiupover)
* `ember`, `ember-data`, `handlebars` version updates

# 7.0.0 (30 Jun 2013)

* Rewrite for [new router](https://gist.github.com/machty/5723945)
  * `request` methods
  * modules:
      * `actionRedirectable`
      * `authRedirectable`
      * `rememberable`
      * `urlAuthenticatable`
* Auto-recall from `rememberable` and auto-auth from `urlAuthenticatable`
  no longer request with `{ async: false }`
* BC Break: the following methods now return a promise:
  * `auth.signIn` (and its underlying `auth._request.signIn`)
  * `auth.signOut` (ditto, `auth._request.signOut`)
  * `auth.send` (ditto, `auth._request.send`)
  * `(rememberable).recall`
  * `(urlAuthenticatable).authenticate`
  * `(route).beforeModel`, if any of these modules are enabled:
      * `actionRedirectable`
      * `authRedirectable`
      * `rememberable`
      * `urlAuthenticatable`
* BC Break: the following modules now utilize the `beforeModel` hook:
  * `actionRedirectable` (no longer using the `activate` hook)
  * `authRedirectable` (ditto, `redirect`)
  * `rememberable` (ditto, `redirect`)
  * `urlAuthenticatable` (ditto, `redirect`)
  * They all return `promise`s from `beforeModel`
* Sidenote: the following methods in the `jquery` `requestAdapter` had already
  been returning `promise`s before, but now this fact is *relied upon*:
  * `signIn`
  * `signOut`
  * `send`
  * (in other words, the underlying `$.ajax` returns a `promise`)
* BC Break: `ember-auth` now requires at least ember `rc6`

Upgrade Guide
-------------

If you are using any of these modules:

* `actionRedirectable`
* `authRedirectable`
* `rememberable`
* `urlAuthenticatable`

and you need to use the `beforeModel` hook, then you must return a `promise`
from the hook too (and the usual `@_super()`):

```coffeescript
App.FooRoute = Em.Route.extend
  beforeModel: ->
    @_super.apply(this, arguments).then -> doSomething()

  # or

  beforeModel: ->
    doSomething()
    @_super.apply(this, arguments) # ember-auth will already return a promise
```

Also note the change in return values of some methods. (See BC Break above)
They now return promises, meaning you should write

```coffeescript
changedMethod().then (success) -> handleSuccess(), (error) -> handleError()
```

if you had been relying on the return values of these methods.
(In any case, the previous return values were undocumented side-effects of
coffeescript returning the last lines of method bodies.)

# 6.0.5 (29 May 2013)

* Bugfix: don't serialize into JSON string when `type` not given (#56)
* Bugfix: `FormData` not available in IE (#60)
* swap out GPL-3.0 for MIT license (#59)

# 6.0.4 (22 May 2013)

* Compatibility with [ember-inflector](https://github.com/stefanpenner/ember-inflector):
  use `capitalize(camelize())` instead of `classify()` to prevent class names
  from being singularized

# 6.0.3 (9 May 2013)

* Bugfix: allow empty string JSON response

# 6.0.2 (6 May 2013)

* Bugfix: events should fire after `ember-auth` has completed its own hooks
* Bugfix: restoring test suite passing
* Specs no longer depend on underscore.js

# 6.0.1 (3 May 2013)

* Bugfix: Modules should not override each other (#48)

# 6.0.0 (2 May 2013)

* Bugfix: User model not autoloading (#43)
* Bugfix: Sign in / out functions should include authentication info, if any
* BC Break: `userModel` now expects a string, not a class

Upgrade Guide
-------------

This is a reference Upgrade Guide. For `v4.x` to `v5.x` or `v6.x`, *all*
code has been BC-broken and needs upgrading. You are encouraged to use the
[official docs and code generator](http://ember-auth.herokuapp.com/docs) to
*generate* the new `ember-auth` code for your use case, and only refer to this
upgrade guide afterwards as a reference checklist.

### Top-level namespace + Auth.Config

`ember-auth` is now attached to the `Ember` namespace; userland code is also
now expected to initialize its own copy of `ember-auth` under the application
namespace.

Configuration is now done when `create()`ing an `Em.Auth` object.

Before:

```coffeescript
Auth.Config.reopen({ foo: 'bar' })
```

After:

```coffeescript
App = Em.Application.create()
# immediately after the above line
App.Auth = Em.Auth.create({ foo: 'bar' })
```

Note also that some configuration keys and/or their expected values have
changed.

### Adapters

`ember-auth` is now configurable with an array of "adapters".
This will setup an equivalent for the previous versions' default behavior:

```coffeescript
App.Auth = Em.Auth.create
  requestAdapter: 'jquery' # this is default
  responseAdapter: 'json'  # this is default
  strategyAdapter: 'token' # this is default
  sessionAdapter: 'cookie' # this is default
```

You can actually omit all of them, since they are defaults.

### Sign in / out API end points

Before:

```coffeescript
Auth.Config.reopen
  tokenCreateUrl: '/users/sign_in'
  tokenDestroyUrl: '/users/sign_out'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  signInEndPoint: '/users/sign_in'
  signOutEndPoint: '/users/sign_out'
```

### Token configuration

Before:

```coffeescript
Auth.Config.reopen
  tokenkey: 'auth_token'
  idKey: 'user_id'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  tokenkey: 'auth_token'
  tokenIdKey: 'user_id'
```

### Different token locations

Before:

```coffeescript
Auth.Config.reopen
  # case (1)
  requestTokenLocation: 'param'
  tokenKey: 'auth_token'

  # case (2)
  requestTokenLocation: 'authHeader'
  requestHeaderKey: 'TOKEN'

  # case (3)
  requestTokenLocation: 'customHeader'
  requestHeaderKey: 'X-API-TOKEN'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  # case (1)
  tokenLocation: 'param'
  tokenKey: 'auth_token'

  # case (2)
  tokenLocation: 'authHeader'
  tokenHeaderKey: 'TOKEN'

  # case (3)
  tokenLocation: 'customHeader'
  tokenHeaderKey: 'X-API-TOKEN'
```

### Auto-load current user object

Before:

```coffeescript
Auth.Config.reopen
  userModel: App.Member
```

After:

```coffeescript
App.Auth = Em.Auth.create
  userModel: 'App.Member' # pass the string, not a class App.Member

# access the current user object
App.Auth.get('user')
```

### Different API base URL

Before:

```coffeescript
Auth.Config.reopen
  baseUrl: 'https://api.example.com'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  baseUrl: 'https://api.example.com'
```

### ember-data DS.adapter patch

This has been moved to its own module called `emberData`.
`Auth.RESTAdapter` is gone - you can just use `DS.RESTAdapter`
after enabling the module.

Before:

```coffeescript
App.Store = DS.Store.extend
  adapter: Auth.RESTAdapter.create()
```

After:

```coffeescript
App.Auth = Em.Auth.create
  modules: ['emberData'] # this is also the default

App.Store = DS.Store.extend
  adapter: DS.RESTAdapter.create() # i.e. no special code needed
```

### Not using Auth.RESTAdapter

The `emberData` module is enabled by default. You need to remove it explicitly.

Before:

```coffeescript
App.Store = DS.Store.extend
  adapter: DS.RESTAdapter.create()
```

After:

```coffeescript
App.Auth = Em.Auth.create
  modules: [] # 'emberData' removed

App.Store = DS.Store.extend
  adapter: DS.RESTAdapter.create() # i.e. no special code needed
```

### Auth.authToken conditional logic

Branching by `Auth.authToken` would still work, but it is preferrable to
change it to `App.Auth.signedIn`.

Before:

```coffeescript
if Auth.get('authToken')
```

```handlebars
{{#if Auth.authToken}}
```

After:

```coffeescript
if App.Auth.get('signedIn')
```

```handlebars
{{#if App.Auth.signedIn}}
```

### Sign in / Sign out methods

Before:

```coffeescript
Auth.signIn { foo: 'bar' }
Auth.signOut { foo: 'bar' }
```

After:

```coffeescript
App.Auth.signIn { data: { foo: 'bar' } }
App.Auth.signOut { data: { foo: 'bar' } }
```

### Authenticated requests

Before:

```coffeescript
Auth.ajax { url: '/api/foo', type: 'POST', foo_key: 'bar_data' }
```

After:

```coffeescript
App.Auth.send { url: '/api/foo', type: 'POST', data: { foo_key: 'bar_data' } }
```

### Auth.Route

The previous `Auth.Route` had multiple responsibilities.

If you want to redirect unauthenticated users away from the `Auth.Route`,
enable the `authRedirectable` module and include the `App.Auth.Redirectable`
mixin (instead of extending from `Auth.Route`).

Before:

```coffeescript
Auth.Config.reopen
  signInRoute: 'sign_in'
  authRedirect: true

App.SecretRoute = Auth.Route.extend()
```

After:

```javascript
App.Auth = Em.Auth.create
  modules: ['authRedirectable']
  authRedirectable:
    route: 'sign_in'

App.SecretRoute = Em.Route.extend App.Auth.AuthRedirectable
```

If you are looking for the `authAccess` event, again you need to enable the `authRedirectable` module, and then listen to it via the *main auth object*,
instead of on the route.

The route's `routeName` property will let you know in which route the event
was fired.

Before:

```coffeescript
App.SecretRoute = Auth.Route.extend
  init: ->
    @on 'authAccess', -> doSomething()
```

After:

```coffeescript
App.Secret = Em.Route.extend App.Auth.AuthRedirectable,
  init: ->
    App.Auth.on 'authAccess', -> doSomething()
```

There had been a scoping option in the old `rememberMe` and `urlAuthentication`
modules, that could isolate the methods to an `Auth.Route`. This has been
removed; the new `rememberable` and `urlAuthenticatable` modules, when enabled,
will apply its features / logic on all `Em.Route`s.

Before:

```coffeescript
Auth.Config.reopen
  # case (1)
  rememberAutoRecallRouteScope: 'auth' # this was the default

  # case (2)
  rememberAutoRecallRouteScope: 'both'

  # case (3)
  urlAuthenticationRouteScope: 'auth' # this was the default

  # case (4)
  urlAuthenticationRouteScope: 'both'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  # case (1)
  # feature removed; converge into case (2)

  # case (2)
  modules: ['rememberable']
  # see section below for upgrade guide for the 'rememberable' module

  # case (3)
  # feature removed; converge into case (4)

  # case (4)
  modules: ['urlAuthenticatable']
  # see section below for upgrade guide for the 'urlAuthenticatable' module
```

If you have grouped custom logic within an `Auth.Route` (auth-related logic,
perhaps?), then you need to subclass `Ember.Route` in userland code,
and then proceed as usual.

Before:

```coffeescript
# case (1)
Auth.Config.reopen
  signInRoute: 'sign_in'
  authRedirect: true

Auth.Route.reopen
  # some custom logic

App.SecretRoute = Auth.Route.extend()

# case (2)
Auth.Config.reopen
  authRedirect: false # this was the default

Auth.Route.reopen
  # some custom logic

App.SecretRoute = Auth.Route.extend()
```

After:

```coffeescript
# case (1)
App.Auth = Em.Auth.create
  modules: ['authRedirectable']
  authRedirectable:
    route: 'sign_in'

App.MySubclassedRoute = Em.Route.extend App.Auth.AuthRedirectable,
  # custom logic here

App.SecretRoute = App.MySubclassedRoute.extend()

# case (2)
App.MySubclassedRoute = Em.Route.extend
  # custom logic here

App.SecretRoute = App.MySubclassedRoute.extend()
```

### Post-sign in / sign out redirects

This has been moved to its own module `actionRedirectable`.
`Auth.SignInController`, `Auth.SignOutController`, and the `registerRedirect()`
call are all gone (and unnecessary) in the new version.

Before:

```coffeescript
Auth.Config.reopen
  # case (1): post-sign in, static
  signInRedirectFallbackRoute: 'account'

  # case (2): post-sign out, static
  signOutRedirectFallbackRoute: 'home'

  # case (3): post-sign in, smart
  signInRoute: 'sign_in'
  smartSignInRedirect: true
  signInRedirectFallbackRoute: 'account'

  # case (4): post-sign out, smart
  signOutRoute: 'sign_out'
  smartSignOutRedirect: true
  signOutRedirectFallbackRoute: 'home'

# common controller modificiations:

App.SignInController = Ember.ObjectController.extend Auth.SignInController,
  signIn: ->
    @registerRedirect()
    # ...

App.SignOutController = Ember.ObjectController.extend Auth.SignOutController,
  signOut: ->
    @registerRedirect()
    # ...
```

After:

```coffeescript
App.Auth = Ember.Auth.create
  modules: ['actionRedirectable']
  actionRedirectable:
    # case (1): post-sign in, static
    signInRoute: 'account'

    # case (2): post-sign out, static
    signOutRoute: 'home'

    # case (3): post-sign in, smart
    signInRoute: 'account'
    signInSmart: true
    signInBlacklist: ['sign_in']

    # case (4): post-sign out, smart
    signOutRoute: 'home'
    signOutSmart: true
    signOutBlacklist: ['sign_out']

# no ember-auth code needed in controllers:

App.SignInController = Ember.ObjectController.extend
  signIn: ->
    # ...

App.SignOutController = Ember.ObjectController.extend
  signOut: ->
    # ...
```

### Remember me

The remembered session storage location now respects a `session` adapter
setting. The old remember me module defaults to `cookie` for storage,
and `localStorage` is available.

Before:

```coffeescript
Auth.Config.reopen
  rememberMe: true
  rememberTokenKey: 'remember_token'
  rememberPeriod: 14 # this is the default

  # case (1): auto recall turned off
  rememberAutoRecall: false # default true

  # case (2): use localStorage to store remembered sessions
  rememberStorage: 'localStorage' # default 'cookie'
```

After:

```coffeescript
App.Auth = Ember.Auth.create
  modules: ['rememberable']
  rememberable:
    tokenKey: 'remember_token'
    period: 14  # this is the default

    # case (1): auto recall turned off
    autoRecall: false # default true

  # case (2): use localStorage to store remembered sessions
  sessionAdapter: 'localStorage' # default 'cookie'
```

The `rememberAutoRecallRouteScope` setting is removed. Previously, the default
was to isolate auto recall to only happen on `Auth.Route`s.
The new `rememberable` module, when enabled, will auto recall the remembered
session on all `Em.Route`s.

Before:

```coffeescript
Auth.Config.reopen
  # case (1)
  rememberAutoRecallRouteScope: 'auth' # this was the default

  # case (2)
  rememberAutoRecallRouteScope: 'both'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  # case (1)
  # feature removed; converge into case (2)

  # case (2)
  modules: ['rememberable']
  # just enable the module, and follow settings as described above
```

Low-level manual management of remember sessions:

Before:

```coffeescript
Auth.Module.RememberMe.recall { async: false }
Auth.Module.RememberMe.remember()
Auth.Module.RememberMe.forget()
```

After:

```coffeescript
App.Auth.get('module.rememberable').recall { async: false }
App.Auth.get('module.rememberable').remember()
App.Auth.get('module.rememberable').forget()
```

### URL authentication

Before:

```coffeescript
Auth.Config.reopen
  urlAuthentication: true
  urlAuthenticationParamsKey: 'auth'
```

After:

```coffeescript
App.Auth = Ember.Auth.create
  modules: ['urlAuthenticatable']
  urlAuthenticatable:
    paramsKey: 'auth'
```

The `urlAuthenticationRouteScope` setting is removed. Previously, the default
was to isolate auto authenticate to only happen on `Auth.Route`s.
The new `urlAuthenticatable` module, when enabled, will auto authenicate
the user on all `Em.Route`s.

Before:

```coffeescript
Auth.Config.reopen
  # case (1)
  urlAuthenticationRouteScope: 'auth' # this was the default

  # case (2)
  urlAuthenticationRouteScope: 'both'
```

After:

```coffeescript
App.Auth = Em.Auth.create
  # case (1)
  # feature removed; converge into case (2)

  # case (2)
  modules: ['urlAuthenticatable']
  # just enable the module, and follow settings as described above
```

### Token authentication API events

Before:

```coffeescript
Auth.on 'signInSuccess',   -> doSomething()
Auth.on 'signInError',     -> doSomething()
Auth.on 'signInComplete',  -> doSomething()
Auth.on 'signOutSuccess',  -> doSomething()
Auth.on 'signOutError',    -> doSomething()
Auth.on 'signOutComplete', -> doSomething()
```

After:

```coffeescript
App.Auth.on 'signInSuccess',   -> doSomething()
App.Auth.on 'signInError',     -> doSomething()
App.Auth.on 'signInComplete',  -> doSomething()
App.Auth.on 'signOutSuccess',  -> doSomething()
App.Auth.on 'signOutError',    -> doSomething()
App.Auth.on 'signOutComplete', -> doSomething()
```

### authAccess event

If you are looking for the `authAccess` event, again you need to enable the `authRedirectable` module, and then listen to it via the *main auth object*,
instead of on the route.

The route's `routeName` property will let you know in which route the event
was fired.

Before:

```coffeescript
App.SecretRoute = Auth.Route.extend
  init: ->
    @on 'authAccess', -> doSomething()
```

After:

```coffeescript
App.Secret = Em.Route.extend App.Auth.AuthRedirectable,
  init: ->
    App.Auth.on 'authAccess', -> doSomething()

# or just listen for the event somewhere else
App.Auth.on 'authAccess', -> doSomething()
```

### Customized ajax calls

`jQuery.ajax` is no longer the only way to send requests in `ember-auth`.
Depending on your use case, you might want to customize the top level method
`send()`, or the one in the `jQuery` request adapter.

Before:

```coffeescript
Auth.reopen
  ajax: (settings) ->
    settings.contentType = 'foo'
    @_super settings
```

After:

```coffeescript
App.Auth.reopen
  send: (settings) ->
    settings.contentType = 'foo'
    @_super settings

# or

# first choose jquery as your requestAdapter
App.Auth = Ember.Auth.create
  requestAdapter: 'jquery' # default 'jquery'

# then customize it
App.Auth._request.adapter.reopen
  send: (settings) ->
    settings.contentType = 'foo'
    @_super settings
```

# 5.0.0 (2 May 2013)

* Major rewrite:
  * Remove global `Auth` namespace; use `Ember.Auth`
  * Break logic into `request`, `response`, `strategy`, `session` components
  * Proper module system
  * Factor most choices into adapters
  * Remove `Auth*` extensions of various ember classes,
    in favor of direct patching the underlying ember classes
  * Everything now written in ember-script
  * Remove mini rails app for dev environment
  * Use `jasmine-headless-webkit` for testing
* Feature: app-specific ember-auth instances
  \- allow for multiple apps (with separate ember-auth instances)
* Feature: `request`, `response`, `strategy`, `session` adapters
* Feature: customizable module precedences
* BC Break: (basically everything)
* Bugfix: `ember-data` override conditional on its presence (#35)
  (@mastropinguino)
* Bugfix: auth token injection for `FormData` objects (#38) (@mastropinguino)
* Bugfix: `DS.RESTAdapter.ajax()` fix for `null/undefined` settings (#44)
  (@seanrucker)
* Bugfix: smart redirect now works with routes with dynamic segments

Upgrade Guide
-------------

See `v6.x` Upgrade Guide.

# 4.1.4 (18 Apr 2013)

* Bugfix: Url Authentication namespacing params (#33)

# 4.1.3 (18 Apr 2013)

* Wrap `Auth` under an exports object (or global `this`)

# 4.1.2 (18 Apr 2013)

* Bugfix: Url Authentication behavior when params is not given (#36)

# 4.1.1 (18 Apr 2013)

* (Minor spec fix)

# 4.1.0 (18 Apr 2013)

* Bugfix: Remember cookies should always use root scope
* Bugfix: Proper recall/forget behavior for Remember Me (#36)
* Bugfix: `Auth.Route` now calls `_super()`
* Bugfix: Url Authentication not properly reading params from URL (#37)
* Feature: optional flags to enable Remember Me's auto-recall behavior,
  and Url Authentication's authenticate behavior, on regular `Em.Route`s
  in addition to `Auth.Route`s (#36)

# 4.0.1 (17 Apr 2013)

* Bugfix: `4.0.0` was shipped with old dist files

# 4.0.0 (17 Apr 2013)

* Feature: pass any params for URL authentication (#33)
* BC Break: URL Authentication params are now mandatorily scoped under a new
  config setting `urlAuthenticationParamsKey`.

Upgrade Guide
-------------

### URL Authentication

Before:

```cofreescript
Auth.Config.reopen
  urlAuthentication: true
```

and a URL

```text
http://www.example.com/?auth_token=fja8hfhf4/#/posts/5
```

After:

```coffeescript
Auth.Config.reopen
  urlAuthentication: true
  urlAuthenticationParamsKey: 'auth' # or pick another name
```

and the corresponding URL

```text
http://www.example.com/?auth[auth_token]=fja8hfhf4/#/posts/5
```

# 3.1.2 (15 Apr 2013)

* Add `ember` dependency to `package.json`

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
