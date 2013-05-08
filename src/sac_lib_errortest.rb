require 'fileutils'

DIR = File.basename(File.expand_path(__FILE__), '.rb')
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
  $case_codes[title] = code
end

def teardown(code)
  $teardown_code = code
end

$dependencies << 'sac_lib.o'
$compiler = ENV['MY_FORTRAN']

setup <<-EOS
# include "../utils.h"
program runner
  USE_UTILS_H
  use, non_intrinsic:: sac_lib, only: get_iftype, Sac

  implicit none

  type(Sac):: w1, w2
  Character:: tmp
EOS

errortest 'iftype', <<-EOS
  tmp = get_iftype(w1)
EOS

teardown <<-EOS
  stop
end program runner
EOS

FileUtils.mkdir_p(DIR)
$case_codes.each{|title, code|
target = File.join(DIR, title) + '.F90'
  if !File.readable?(target) || File.mtime(target) <= File.mtime(__FILE__)
    File.write(target, $setup_code + code + $teardown_code)
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

system "make -f #{makefile}"
$case_codes.each{|title, _|
  exe = File.join(DIR, title) + '.exe'
  command = "#{exe}"
  if system(command)
    $stderr.put "FAIL: #{exe}"
  else
    puts 'PASS'
  end
}
