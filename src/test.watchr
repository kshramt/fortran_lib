RAKE = "rake1.9"
watch(".*\.f90"){system "#{RAKE} test"}
watch(".*\.f90\.erb"){system "#{RAKE} test"}
