# we now require features at rc6
EMBER_VERSIONS = %w(
1.0.0.rc6
)

EMBER_VERSIONS.each do |version|
  appraise "ember-#{version}" do
    gem 'ember-source', version
    gem 'handlebars-source', '>= 1.0.0.rc4'
  end
end
