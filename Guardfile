spec_location = 'spec/javascripts/%s-spec'
guard 'jasmine-headless-webkit' do
  watch(%r{^lib/(.*)\.(js|coffee|em)$}) do |m|
    spec_location % m[1]
  end
  watch(%r{^spec/javascripts/(.*)-spec\.(js|coffee|em)$}) do |m|
    spec_location % m[1]
  end
end
