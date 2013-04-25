spec_location = 'spec/javascripts/%s-spec.%s'
guard 'jasmine-headless-webkit' do
  watch(%r{^lib/(.*)\.(js|coffee|em)$}) do |m|
    spec_location % [m[1], m[2]]
  end
  watch(%r{^spec/javascripts/(.*)-spec\.(js|coffee|em)$}) do |m|
    spec_location % [m[1], m[2]]
  end
  watch(%r{^spec/javascripts/(examples|helpers)/.*$}) { 'spec/javascripts' }
end
