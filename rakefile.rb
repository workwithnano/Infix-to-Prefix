task :default => [:test]

task :test do
  ruby "tests_prefix.rb"
end