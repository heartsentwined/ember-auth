module Ember
  module Auth
    module Source
      def self.bundled_path
        File.expand_path('../../../../dist/ember-auth.js', __FILE__)
      end
    end
  end
end
