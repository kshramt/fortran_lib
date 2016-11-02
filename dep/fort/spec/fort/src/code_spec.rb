require 'spec_helper'

describe ::Fort::Src::Code do
  describe "#contents" do
    context 'normal case' do
      context 'program' do
        it do
          ::Fort::Src::Code.new(File.read(File.join(__DIR__, 'test.f90')))\
            .contents\
            .should == [
                        ::Fort::Src::Code::ProgramUnit.new(:test, :program, [
                                                                             ::Fort::Src::Code::DependedModule.new(:mod1, :non_intrinsic),
                                                                             ::Fort::Src::Code::DependedModule.new(:mod2, :non_intrinsic),
                                                                             ::Fort::Src::Code::DependedModule.new(:iso_fortran_env, :both)])]
        end
      end

      context 'module' do
        it do
          ::Fort::Src::Code.new(File.read(File.join(__DIR__, 'lib_test.f90')))
            .contents\
            .should == [
                        ::Fort::Src::Code::ProgramUnit.new(:lib_test, :module, [
                                                                             ::Fort::Src::Code::DependedModule.new(:mod1, :non_intrinsic),
                                                                             ::Fort::Src::Code::DependedModule.new(:mod2, :non_intrinsic),
                                                                             ::Fort::Src::Code::DependedModule.new(:iso_fortran_env, :non_intrinsic)])]
        end
      end
    end

    context 'wrong case' do
      context 'too many start (program or module)' do
        it do
          lambda{::Fort::Src::Code.new(File.read(File.join(__DIR__, 'test.f90')))\
              .sub(/none/, "none\nmodule ab").contents}.should raise_error
        end
      end

      context 'too many end (end program or end module)' do
        it do
          lambda{::Fort::Src::Code.new(File.read(File.join(__DIR__, 'test.f90')))\
              .sub(/write/, "end program ab\nwrite").contents}.should raise_error
        end
      end
    end
  end
  
  describe '#clean_code' do
    it do
      raw = File.read(File.join(__DIR__, 'test.f90'))
      expected = File.read(File.join(__DIR__, 'test_clean_code.f90')).split("\n")
      ::Fort::Src::Code.new(raw).clean_code.should == expected
    end
  end

  describe '#without_continuation_ampersand' do
    context 'simplest case' do
      raw= <<-EOS
abc&
&def
      EOS

      expected = <<-EOS
abcdef
      EOS

      it do
        ::Fort::Src::Code.new(raw).without_continuation_ampersand.should == expected
      end
    end

    context 'no ampersand on the top of the continuation lines' do
      raw= <<-EOS
abc&
def
      EOS

      expected = <<-EOS
abcdef
      EOS

      it do
        ::Fort::Src::Code.new(raw).without_continuation_ampersand.should == expected
      end
    end

    context "don't join lines if no ampersand exist at the end of the first line" do
      raw= <<-EOS
abc
&def
      EOS

      expected = <<-EOS
abc
&def
      EOS

      it do
        ::Fort::Src::Code.new(raw).without_continuation_ampersand.should == expected
      end
    end

    context 'complex case' do
      raw= <<-EOS
A = (/ &
     & 1, 2, 3, &
     & 4, 5, 6, &
     & 7, 8, 9 &
      /)
      EOS

      expected = <<-EOS
A = (/  1, 2, 3,  4, 5, 6,  7, 8, 9 /)
      EOS

      it do
        ::Fort::Src::Code.new(raw).without_continuation_ampersand.should == expected
      end
    end
  end

  describe '#without_one_line_semicolon' do
    context 'simplest case' do
      raw= <<-EOS
abc; def
      EOS

      expected = <<-EOS
abc
 def
      EOS

      it do
        ::Fort::Src::Code.new(raw).without_one_line_semicolon.should == expected
      end
    end
  end

  describe '#without_comments_and_strings' do
    context 'simplest case' do
      it do
        ::Fort::Src::Code.new("abc!def").without_comments_and_strings.should == 'abc'
      end
    end

    context 'complex case' do
      it do
        raw= <<-EOS
'd'
abc 'def&
  &ghij'
ddd ! ! ddd
ab"df'
asd"dd
          EOS

        expected = <<-EOS
''
abc ''
ddd 
ab""dd
        EOS
        ::Fort::Src::Code.new(raw).without_comments_and_strings.should == expected
      end
    end
  end
end
