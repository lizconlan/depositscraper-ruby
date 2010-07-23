require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--colour', '--format=progress']
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
  t.spec_files = FileList['./lib/*.rb']
  t.rcov = true
  # t.rcov_opts = ['--exclude', 'examples']
end