/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */

(function (factory) {
	if (typeof define === 'function' && define.amd && define.amd.jQuery) {
		// AMD. Register as anonymous module.
		define(['jquery'], factory);
	} else {
		// Browser globals.
		factory(jQuery);
	}
}(function ($) {

	var pluses = /\+/g;

	function raw(s) {
		return s;
	}

	function decoded(s) {
		return decodeURIComponent(s.replace(pluses, ' '));
	}

	function converted(s) {
		if (s.indexOf('"') === 0) {
			// This is a quoted cookie as according to RFC2068, unescape
			s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
		}
		try {
			return config.json ? JSON.parse(s) : s;
		} catch(er) {}
	}

	var config = $.cookie = function (key, value, options) {

		// write
		if (value !== undefined) {
			options = $.extend({}, config.defaults, options);

			if (typeof options.expires === 'number') {
				var days = options.expires, t = options.expires = new Date();
				t.setDate(t.getDate() + days);
			}

			value = config.json ? JSON.stringify(value) : String(value);

			return (document.cookie = [
				encodeURIComponent(key), '=', config.raw ? value : encodeURIComponent(value),
				options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
				options.path    ? '; path=' + options.path : '',
				options.domain  ? '; domain=' + options.domain : '',
				options.secure  ? '; secure' : ''
			].join(''));
		}

		// read
		var decode = config.raw ? raw : decoded;
		var cookies = document.cookie.split('; ');
		var result = key ? undefined : {};
		for (var i = 0, l = cookies.length; i < l; i++) {
			var parts = cookies[i].split('=');
			var name = decode(parts.shift());
			var cookie = decode(parts.join('='));

			if (key && key === name) {
				result = converted(cookie);
				break;
			}

			if (!key) {
				result[name] = converted(cookie);
			}
		}

		return result;
	};

	config.defaults = {};

	$.removeCookie = function (key, options) {
		if ($.cookie(key) !== undefined) {
			$.cookie(key, '', $.extend(options, { expires: -1 }));
			return true;
		}
		return false;
	};

}));
(function() {
  var evented;

  evented = Em.Object.extend(Em.Evented);

  window.Auth = evented.create({
    authToken: null,
    currentUserId: null,
    currentUser: null,
    jqxhr: null,
    prevRoute: null,
    json: null,
    signIn: function(data) {
      var async,
        _this = this;

      if (data == null) {
        data = {};
      }
      async = data.async != null ? data.async : true;
      if (data.async != null) {
        delete data['async'];
      }
      return this.ajax({
        url: this.resolveUrl(Auth.Config.get('tokenCreateUrl')),
        type: 'POST',
        data: data,
        async: async
      }).done(function(json, status, jqxhr) {
        var model;

        _this.set('authToken', json[Auth.Config.get('tokenKey')]);
        _this.set('currentUserId', json[Auth.Config.get('idKey')]);
        if (model = Auth.Config.get('userModel')) {
          _this.set('currentUser', model.find(_this.get('currentUserId')));
        }
        _this.set('json', json);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signInSuccess');
      }).fail(function(jqxhr) {
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signInError');
      }).always(function(jqxhr) {
        _this.set('prevRoute', null);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signInComplete');
      });
    },
    signOut: function(data) {
      var async,
        _this = this;

      if (data == null) {
        data = {};
      }
      data[Auth.Config.get('tokenKey')] = this.get('authToken');
      async = data.async != null ? data.async : true;
      if (data.async != null) {
        delete data['async'];
      }
      return this.ajax({
        url: this.resolveUrl(Auth.Config.get('tokenDestroyUrl')),
        type: 'DELETE',
        data: data,
        async: async
      }).done(function(json, status, jqxhr) {
        _this.set('authToken', null);
        _this.set('currentUserId', null);
        _this.set('currentUser', null);
        _this.set('jqxhr', jqxhr);
        _this.set('json', json);
        return _this.trigger('signOutSuccess');
      }).fail(function(jqxhr) {
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signOutError');
      }).always(function(jqxhr) {
        _this.set('prevRoute', null);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signOutComplete');
      });
    },
    resolveUrl: function(path) {
      var base;

      base = Auth.Config.get('baseUrl');
      if (base && base[base.length - 1] === '/') {
        base = base.substr(0, base.length - 1);
      }
      if ((path != null ? path[0] : void 0) === '/') {
        path = path.substr(1, path.length);
      }
      return [base, path].join('/');
    },
    resolveRedirectRoute: function(type) {
      var fallback, isSmart, sameRoute, typeClassCase;

      if (type !== 'signIn' && type !== 'signOut') {
        return null;
      }
      typeClassCase = "" + (type[0].toUpperCase()) + (type.slice(1));
      isSmart = Auth.Config.get("smart" + typeClassCase + "Redirect");
      fallback = Auth.Config.get("" + type + "RedirectFallbackRoute");
      sameRoute = Auth.Config.get("" + type + "Route");
      if (!isSmart) {
        return fallback;
      }
      if ((this.prevRoute == null) || this.prevRoute === sameRoute) {
        return fallback;
      } else {
        return this.prevRoute;
      }
    },
    ajax: function(settings) {
      var data, def, e, token, _base, _base1, _base2, _name, _name1, _name2;

      if (settings == null) {
        settings = {};
      }
      def = {};
      def.dataType = 'json';
      if (settings.data && (settings.contentType == null) && settings.type !== 'GET') {
        def.contentType = 'application/json; charset=utf-8';
        settings.data = JSON.stringify(settings.data);
      }
      settings = jQuery.extend(def, settings);
      if (token = this.get('authToken')) {
        switch (Auth.Config.get('requestTokenLocation')) {
          case 'param':
            settings.data || (settings.data = {});
            switch (typeof settings.data) {
              case 'object':
                (_base = settings.data)[_name = Auth.Config.get('tokenKey')] || (_base[_name] = this.get('authToken'));
                break;
              case 'string':
                try {
                  data = JSON.parse(settings.data);
                  data[_name1 = Auth.Config.get('tokenKey')] || (data[_name1] = this.get('authToken'));
                  settings.data = JSON.stringify(data);
                } catch (_error) {
                  e = _error;
                }
            }
            break;
          case 'authHeader':
            settings.headers || (settings.headers = {});
            (_base1 = settings.headers)['Authorization'] || (_base1['Authorization'] = "" + (Auth.Config.get('requestHeaderKey')) + " " + (this.get('authToken')));
            break;
          case 'customHeader':
            settings.headers || (settings.headers = {});
            (_base2 = settings.headers)[_name2 = Auth.Config.get('requestHeaderKey')] || (_base2[_name2] = this.get('authToken'));
        }
      }
      return jQuery.ajax(settings);
    }
  });

}).call(this);
(function() {
  Auth.Config = Em.Object.create({
    tokenCreateUrl: null,
    tokenDestroyUrl: null,
    tokenKey: null,
    idKey: null,
    userModel: null,
    baseUrl: null,
    requestTokenLocation: 'param',
    requestHeaderKey: null,
    signInRoute: null,
    signOutRoute: null,
    authRedirect: false,
    smartSignInRedirect: false,
    smartSignOutRedirect: false,
    signInRedirectFallbackRoute: 'index',
    signOutRedirectFallbackRoute: 'index',
    rememberMe: false,
    rememberTokenKey: null,
    rememberPeriod: 14,
    rememberAutoRecall: true,
    rememberStorage: 'cookie',
    urlAuthentication: false
  });

}).call(this);
(function() {
  Auth.Route = Em.Route.extend(Em.Evented, {
    redirect: function() {
      console.log('redirect');
      if (Auth.get('authToken')) {
        return;
      }
      if (Auth.Config.get('urlAuthentication')) {
        Auth.Module.UrlAuthentication.authenticate({
          async: false
        });
        if (Auth.get('authToken')) {
          return;
        }
      }
      if (Auth.Config.get('rememberMe') && Auth.Config.get('rememberAutoRecall')) {
        Auth.Module.RememberMe.recall({
          async: false
        });
        if (Auth.get('authToken')) {
          return;
        }
      }
      this.trigger('authAccess');
      if (Auth.Config.get('authRedirect')) {
        Auth.set('prevRoute', this.routeName);
        return this.transitionTo(Auth.Config.get('signInRoute'));
      }
    }
  });

}).call(this);
(function() {
  Auth.SignInController = Em.Mixin.create({
    registerRedirect: function() {
      return Auth.addObserver('authToken', this, 'smartSignInRedirect');
    },
    smartSignInRedirect: function() {
      if (Auth.get('authToken')) {
        this.transitionToRoute(Auth.resolveRedirectRoute('signIn'));
        return Auth.removeObserver('authToken', this, 'smartSignInRedirect');
      }
    }
  });

}).call(this);
(function() {
  Auth.SignOutController = Em.Mixin.create({
    registerRedirect: function() {
      return Auth.addObserver('authToken', this, 'smartSignOutRedirect');
    },
    smartSignOutRedirect: function() {
      if (!Auth.get('authToken')) {
        this.transitionToRoute(Auth.resolveRedirectRoute('signOut'));
        return Auth.removeObserver('authToken', this, 'smartSignOutRedirect');
      }
    }
  });

}).call(this);
(function() {
  Auth.RESTAdapter = DS.RESTAdapter.extend({
    ajax: function(url, type, settings) {
      settings.url = url;
      settings.type = type;
      settings.context = this;
      return Auth.ajax(settings);
    }
  });

}).call(this);
(function() {
  Auth.Module = Em.Object.create();

}).call(this);
(function() {
  Auth.Module.RememberMe = Em.Object.create({
    init: function() {
      var _this = this;

      Auth.on('signInSuccess', function() {
        return _this.remember();
      });
      Auth.on('signInError', function() {
        return _this.forget();
      });
      return Auth.on('signOutSuccess', function() {
        return _this.forget();
      });
    },
    recall: function(opts) {
      var data, token;

      if (opts == null) {
        opts = {};
      }
      if (!Auth.Config.get('rememberMe')) {
        return;
      }
      if (!Auth.get('authToken') && (token = this.retrieveToken())) {
        data = {};
        if (opts.async != null) {
          data['async'] = opts.async;
        }
        data[Auth.Config.get('rememberTokenKey')] = token;
        return Auth.signIn(data);
      }
    },
    remember: function() {
      var token;

      if (!Auth.Config.get('rememberMe')) {
        return;
      }
      token = Auth.get('json')[Auth.Config.get('rememberTokenKey')];
      if (token && token !== this.retrieveToken()) {
        return this.storeToken(token);
      }
    },
    forget: function() {
      if (!Auth.Config.get('rememberMe')) {
        return;
      }
      return this.removeToken();
    },
    retrieveToken: function() {
      switch (Auth.Config.get('rememberStorage')) {
        case 'localStorage':
          return localStorage.getItem('ember-auth-remember-me');
        case 'cookie':
          return jQuery.cookie('ember-auth-remember-me');
      }
    },
    storeToken: function(token) {
      switch (Auth.Config.get('rememberStorage')) {
        case 'localStorage':
          return localStorage.setItem('ember-auth-remember-me', token);
        case 'cookie':
          return jQuery.cookie('ember-auth-remember-me', token, {
            expires: Auth.Config.get('rememberPeriod')
          });
      }
    },
    removeToken: function() {
      switch (Auth.Config.get('rememberStorage')) {
        case 'localStorage':
          return localStorage.removeItem('ember-auth-remember-me');
        case 'cookie':
          return jQuery.removeCookie('ember-auth-remember-me');
      }
    }
  });

}).call(this);
(function() {
  Auth.Module.UrlAuthentication = Em.Object.create({
    authenticate: function(opts) {
      var data, token;

      if (opts == null) {
        opts = {};
      }
      if (!Auth.Config.get('urlAuthentication')) {
        return;
      }
      if (!Auth.get('authToken') && (token = this.retrieveToken())) {
        data = {};
        if (opts.async != null) {
          data['async'] = opts.async;
        }
        data[Auth.Config.get('tokenKey')] = token;
        return Auth.signIn(data);
      }
    },
    retrieveToken: function() {
      var token;

      token = $.url().param(Auth.Config.get('tokenKey'));
      if (token && token.charAt(token.length - 1) === '/') {
        token = token.slice(0, -1);
      }
      return token;
    }
  });

}).call(this);
(function() {


}).call(this);
