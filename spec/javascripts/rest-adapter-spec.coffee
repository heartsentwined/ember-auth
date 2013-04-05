describe 'Auth.RESTAdapter', ->
  describe '#ajax', ->
    beforeEach ->
      spyOn Auth, 'ajax'
      Auth.RESTAdapter.create().ajax('foo', 'bar', { key: 'baz' })

    it 'delegates to Auth.ajax', ->
      expect(Auth.ajax.calls[0].args[0]).toBe 'foo'
      expect(Auth.ajax.calls[0].args[1]).toBe 'bar'
      expect(Auth.ajax.calls[0].args[2].key).toBe 'baz'

    it 'sets context', ->
      expect(Auth.ajax.calls[0].args[2].context).toBeDefined()
