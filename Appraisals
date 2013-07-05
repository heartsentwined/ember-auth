# we now require features at rc6
EMBER_VERSIONS = %w(
1.0.0.rc6.2
)

EMBER_DATA_VERSIONS = %w(
0.13 0.0.5
)

EMBER_VERSIONS.each do |ember|
  EMBER_DATA_VERSIONS.each do |emberData|
    appraise "ember-#{ember}-ember-data-#{emberData}" do
      gem 'ember-source', ember
      gem 'ember-data-source', emberData
      gem 'handlebars-source', '>= 1.0.0.rc4'
    end
  end
end
