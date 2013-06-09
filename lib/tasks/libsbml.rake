require 'rubygems'
require 'hoe'

Hoe.spec 'libsbml' do
  self.extra_dev_deps << ['rake-compiler', '>= 0']
  self.spec_extras = { :extensions => ["../../ext/libsbml/extconf.rb"] }

  Rake::ExtensionTask.new('libsbml', spec) do |ext|
    ext.lib_dir = File.join('lib', 'libsbml')
  end
end