# we now require features at rc6
EMBER_VERSIONS = %w(
1.0.0.rc8
1.0.0.rc7
1.0.0.rc6.4 1.0.0.rc6.2
)

PERSISTENT_LIBS = {
  'ember-data' => %w(
    0.13 0.0.5
  ),
  'epf' => %w(
    0.1.3 0.1.2 0.1.1 0.1.0
  )
}

EMBER_VERSIONS.each do |ember|
  PERSISTENT_LIBS.each do |lib, lib_vers|
    lib_vers.each do |lib_ver|
      appraise "ember-#{ember}-#{lib}-#{lib_ver}" do
        gem 'ember-source', ember
        gem 'handlebars-source', '>= 1.0.0.rc4'
        gem "#{lib}-source", lib_ver
      end
    end
  end
end
