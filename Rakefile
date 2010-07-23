require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--colour', '--format=progress']
end

desc "Run RCov on /lib"
Spec::Rake::SpecTask.new('rcov_lib') do |t|
  t.spec_files = FileList['./lib/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', '/Library/Ruby/Gems/1.8/']
end