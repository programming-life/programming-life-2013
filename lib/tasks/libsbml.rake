require 'rubygems'
require 'hoe'

Hoe.spec 'libsbml' do
  developer('Vincent Robbemond', 'vincentrobbemond@live.nl')
  self.readme_file   = '../../README.rdoc'
  self.history_file  = '../../CHANGELOG.rdoc'
  self.extra_rdoc_files  = FileList['*.rdoc']
  self.extra_dev_deps << ['rake-compiler', '>= 0']
  self.spec_extras = { :extensions => ["../../ext/libsbml/extconf.rb"] }

  Rake::ExtensionTask.new('libsbml', spec) do |ext|
    ext.lib_dir = File.join('lib', 'libsbml')
  end
end

Rake::Task[:test].prerequisites << :compile