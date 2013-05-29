describe 'Em.Auth.Request.Jquery', ->
  auth    = null
  spy     = null
  adapter = null

  beforeEach ->
    auth = authTest.create { requestAdapter: 'jquery' }
    adapter = auth._request.adapter
    $.mockjaxSettings.logging = false
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()
    $.mockjaxClear()

  follow 'property injection', 'jqxhr', ->
    beforeEach -> @from = adapter; @to = auth

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
          Em.run -> adapter.send()
        follow 'content type'
        follow 'data'

      describe 'data given', ->

        describe 'contentType given', ->
          beforeEach ->
            Em.run -> adapter.send { contentType: 'foo', data: 'bar' }
          follow 'content type', 'foo'
          follow 'data', 'bar'

        describe 'contentType not given', ->

          describe 'type not given', ->
            beforeEach ->
              Em.run -> adapter.send { data: { foo: 'bar' } }
            follow 'content type', 'application/json; charset=utf-8'
            follow 'data', { foo: 'bar' }

          describe 'type given', ->

            describe '= GET', ->
              beforeEach ->
                Em.run -> adapter.send { data: { foo: 'bar' }, type: 'get' }
              follow 'content type'
              follow 'data', { foo: 'bar' }

            describe '!= GET', ->
              beforeEach ->
                Em.run -> adapter.send { data: { foo: 'bar' }, type: 'FOO' }
              follow 'content type', 'application/json; charset=utf-8'
              follow 'data', '{"foo":"bar"}', true

    it 'is customizable', ->
      spy = sinon.collection.spy jQuery, 'ajax'
      Em.run -> adapter.send { url: 'bar', type: 'GET', contentType: 'foo' }
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
        spy = sinon.collection.spy auth._response, 'canonicalize'
        Em.run -> adapter.send { url: '/foo', type: 'POST', async: false }

      it 'sets jqxhr', -> expect(adapter.jqxhr).not.toBeNull()
      it 'delegates to response.canonicalize', ->
        expect(spy).toHaveBeenCalledWithExactly response

    describe 'success', -> follow 'send integration', 201, { foo: 'bar' }
    describe 'failure', -> follow 'send integration', 401, '{"foo":"bar"}'

  example 'action', (env) ->
    describe "##{env}", ->
      it 'delegates to #send', ->
        spy = sinon.collection.spy adapter, 'send'
        Em.run -> adapter[env]('/foo', { bar: 'baz' })
        expect(spy).toHaveBeenCalledWithExactly
          url: '/foo'
          type: switch env
            when 'signIn'  then 'POST'
            when 'signOut' then 'DELETE'
          bar: 'baz'

      it 'allows overriding of defaults', ->
        spy = sinon.collection.spy adapter, 'send'
        Em.run -> adapter[env]('/foo', { type: 'bar' })
        expect(spy).toHaveBeenCalledWithExactly { url: '/foo', type: 'bar' }

      follow 'trigger events', env, 'success'
      follow 'trigger events', env, 'error'

  example 'trigger events', (env, status) ->
    it "triggers #{status} events", ->
      $.mockjax
        url: '/foo'
        type: switch env
          when 'signIn'  then 'POST'
          when 'signOut' then 'DELETE'
        status: switch status
          when 'success' then 201
          when 'error'   then 401
        responseText: null
      spy = sinon.collection.spy auth, 'trigger'
      Em.run -> adapter[env]('/foo', { async: false })
      event = Em.String.capitalize status
      expect(spy).toHaveBeenCalledWithExactly("#{env}#{event}")
      expect(spy).toHaveBeenCalledWithExactly("#{env}Complete")

  follow 'action', 'signIn'
  follow 'action', 'signOut'
