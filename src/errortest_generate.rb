require 'fileutils'

raise if ARGV.empty?
FILE = ARGV.first
DIR = File.basename(File.expand_path(FILE), '.rb')
$dependencies = []
$compiler = ''
$setup_code = ''
$case_codes = {}
$teardown_code = ''

def compile(code)
  $compile_code = code
end

def setup(code)
  $setup_code = code
end

def errortest(title, code)
  $case_codes[snakize(title)] = code
end

def snakize(str)
  str.downcase.gsub(/[^a-zA-Z0-9]/, '_')
end

def teardown(code)
  $teardown_code = code
end

load FILE

FileUtils.mkdir_p(DIR)
$case_codes.each{|title, code|
  target = File.join(DIR, title) + '.F90'
  if !File.readable?(target) || File.mtime(target) <= File.mtime(FILE)
    File.write(target, <<-EOS)
#{$setup_code}
  #{code}
#{$teardown_code}
    EOS
  end
}

makefile = DIR + '.make'
open(makefile, 'w'){|io|
  io.puts "all: " + $case_codes.keys.map{|title| File.join(DIR, title) + '.exe'}.join(' ')
  $case_codes.each{|title, _|
    base =  File.join(DIR, title)
    io.puts "#{base}.exe: #{$dependencies.join(' ')} #{base}.F90"
    io.puts "\t#{$compiler} -o $@ $^"
  }
}

raise unless system "make -f #{makefile}"

$case_codes.each{|title, _|
  exe = File.join(DIR, title) + '.exe'
  command = "#{exe}"
  if system(command)
    $stderr.puts "FAIL: #{exe}"
  else
    puts 'PASS'
  end
}
