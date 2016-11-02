require 'rake/testtask'

::Rake::TestTask.new do |t|
  t.libs = ['lib', 'test'].map{|dir| File.join(Dir.pwd, dir)}
  t.pattern = "test/**/*_test.rb"
end
