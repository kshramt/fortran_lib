RAKE = ENV['MY_RAKE']
watch(".*\.F90"){system "#{RAKE} test"}
watch(".*\.F90\.erb"){system "#{RAKE} test"}
