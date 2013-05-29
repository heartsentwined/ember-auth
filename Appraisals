EMBER_VERSIONS = %w(
1.0.0.rc4
1.0.0.rc3.4 1.0.0.rc3.3 1.0.0.rc3.2 1.0.0.rc3.1 1.0.0.rc3
1.0.0.rc2.2 1.0.0.rc2.1 1.0.0.rc2.0
1.0.0.rc1.4 1.0.0.rc1.3
1.0.0.pre4.2 1.0.0.pre4.0
0.0.9 0.0.8 0.0.7 0.0.6 0.0.5 0.0.4 0.0.3 0.0.2
)

EMBER_VERSIONS.each do |version|
  appraise "ember-#{version}" do
    gem 'ember-source', version
    gem 'handlebars-source', '>= 1.0.0.rc2'
  end
end
