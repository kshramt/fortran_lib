ERB = ENV.fetch('MY_ERB') + ' -T - -P'
GFORTRAN = ENV.fetch('MY_GFORTRAN') + ' -DDEBUG -ffree-line-length-none -fmax-identifier-length=63 -ggdb -fbacktrace -fbounds-check -pipe -Wall -O0 -C -cpp'

ERBED_F90_FILES = FileList['*.F90.erb'].ext('')

desc "Alias of test."
task default: :test

desc "Compile erb files."
task erb: ERBED_F90_FILES

rule '.F90' => '.F90.erb' do |t|
  begin
    sh "#{ERB} #{t.source} > #{t.name}"
  rescue
    if File.exist?(t.name)
      if File.zero?(t.name)
        rm t.name
      else
        mv t.name, "#{t.name}.fail"
      end
    end
  end
end

%w[.o .mod].each{|ext|
  rule ext => '.F90' do |t|
    sh "#{GFORTRAN} -c #{t.source}"
  end
}

# `sh' is too verbose for automatic test.
def run_test(t, failed_tests)
  failed_tests << t.name unless system "#{GFORTRAN} -o #{t.name} #{t.prerequisites.join(' ')} && ./#{t.name}"
end

TEST_FILES = FileList['*_test.F90', '*_test.F90.erb'].sub(/\.F90(?:\.erb)?\z/, '.exe')
FAILED_TESTS = []
desc "Run tests."
task test: [:testing] do
  unless FAILED_TESTS.empty?
    puts "FAILED TESTS:"
    puts FAILED_TESTS
    exit 1
  end
end

task testing: TEST_FILES
{
  "lib_comparable_test.exe" => %w[lib_constant.o lib_comparable.o lib_comparable_test.F90],
  "lib_character_test.exe" => %w[lib_character.o lib_character_test.F90],
  "lib_constant_test.exe" => %w[lib_comparable.o lib_constant.o lib_constant_test.F90],
  "lib_sort_test.exe" => %w[lib_constant.o lib_stack.o lib_comparable.o lib_sort.o lib_sort_test.F90],
  "lib_list_test.exe" => %w[lib_comparable.o lib_list.o lib_list_test.F90],
  "lib_stack_test.exe" => %w[lib_stack.o lib_stack_test.F90],
  "lib_queue_test.exe" => %w[lib_queue.o lib_queue_test.F90],
  "lib_reflectable_test.exe" => %w[lib_reflectable.o lib_reflectable_test.F90],
  "lib_io_test.exe" => %w[lib_constant.o lib_character.o lib_io.o lib_io_test.F90],
}.each{|target, dependencies|
  file target => dependencies do |t|
    run_test(t, FAILED_TESTS)
  end
}
