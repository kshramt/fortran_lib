ERB_COMPILER = 'erb'
ERB_OPTIONS = "-T '-' -P"
ERBED_F90_FILES = FileList['src/*.f90.erb'].ext('')

desc "Compile erb files."
task erb: ERBED_F90_FILES

rule '.f90' => '.f90.erb' do |t|
  sh "#{ERB_COMPILER} #{ERB_OPTIONS} #{t.source} > #{t.name}"
end
