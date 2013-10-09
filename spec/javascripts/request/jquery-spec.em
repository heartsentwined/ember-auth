describe 'Em.Auth.JqueryAuthRequest', ->
  auth   = null
  spy    = null
  jquery = null

  beforeEach ->
    auth = authTest.create { request: 'jquery' }
    jquery = auth._request
    $.mockjaxSettings.logging = false
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()
    $.mockjaxClear()

  it 'extends from AuthRequest', ->
    expect(auth._request instanceof Em.Auth.AuthRequest).toBe true

  follow 'property injection', 'jqxhr', ->
    beforeEach -> @from = jquery; @to = auth

  example 'content type', (value) ->
    if value
      it 'uses given contentType', ->
        expect(spy.args[0][0].contentType).toEqual value
    else
      it 'does not set contentType', ->
        expect(spy.args[0][0].contentType).not.toBeDefined()

  example 'data', (value, isSerialize) ->
    if value
      desc =
        if isSerialize
          'serializes data to json string'
        else
          'uses given data'
      it desc, ->
        expect(spy.args[0][0].data).toEqual value
    else
      it 'does not set data', ->
        expect(spy.args[0][0].data).not.toBeDefined()

  describe '#send', ->

    describe 'default content type and data', ->
      beforeEach -> spy = sinon.collection.spy jQuery, 'ajax'

      describe 'data not given', ->
        beforeEach ->
          Em.run -> jquery.send {}
        follow 'content type'
        follow 'data'

      describe 'data given', ->

        describe 'contentType given', ->
          beforeEach ->
            Em.run -> jquery.send { contentType: 'foo', data: 'bar' }
          follow 'content type', 'foo'
          follow 'data', 'bar'

        describe 'contentType not given', ->

          describe 'type not given', ->
            beforeEach ->
              Em.run -> jquery.send { data: { foo: 'bar' } }
            follow 'content type', 'application/json; charset=utf-8'
            follow 'data', { foo: 'bar' }

          describe 'type given', ->

            describe '= GET', ->
              beforeEach ->
                Em.run -> jquery.send { data: { foo: 'bar' }, type: 'get' }
              follow 'content type'
              follow 'data', { foo: 'bar' }

            describe '!= GET', ->
              beforeEach ->
                Em.run -> jquery.send { data: { foo: 'bar' }, type: 'FOO' }
              follow 'content type', 'application/json; charset=utf-8'
              follow 'data', '{"foo":"bar"}', true

    follow 'return promise', ->
      beforeEach -> @return = jquery.send {}

    it 'is customizable', ->
      spy = sinon.collection.spy jQuery, 'ajax'
      Em.run -> jquery.send { url: 'bar', type: 'GET', contentType: 'foo' }
      expect(spy.args[0][0].url).toEqual 'bar'
      expect(spy.args[0][0].type).toEqual 'GET'
      expect(spy.args[0][0].contentType).toEqual 'foo'

    example 'send integration', (status, response) ->
      beforeEach ->
        $.mockjax
          url: '/foo'
          type: 'POST'
          status: status
          responseText: response

      it 'sets jqxhr', ->
        Em.run -> jquery.send { url: '/foo', type: 'POST', async: false }
        expect(jquery.jqxhr).not.toBeNull()

    describe 'success', -> follow 'send integration', 201, { foo: 'bar' }
    describe 'failure', -> follow 'send integration', 401, { foo: 'bar' }

  example 'action', (env) ->
    describe "##{env}", ->
      it 'delegates to #send', ->
        spy = sinon.collection.spy jquery, 'send'
        Em.run -> jquery[env]('/foo', { bar: 'baz' })
        expect(spy).toHaveBeenCalledWithExactly
          url: '/foo'
          type: switch env
            when 'signIn'  then 'POST'
            when 'signOut' then 'DELETE'
          bar: 'baz'

      it 'allows overriding of defaults', ->
        spy = sinon.collection.spy jquery, 'send'
        Em.run -> jquery[env]('/foo', { type: 'bar' })
        expect(spy).toHaveBeenCalledWithExactly { url: '/foo', type: 'bar' }

  follow 'action', 'signIn'
  follow 'action', 'signOut'
