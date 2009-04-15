desc 'Package the application'
task :pkg => 'pkg:mac'

namespace :pkg do
  desc "Package the application for OS X"
  task :mac do
    `rm -rf tmp/`
    `rm -rf pkg/`

    `mkdir -p tmp`
    `mkdir -p pkg`

    `cd tmp; wget http://gosu.googlecode.com/files/gosu-mac-0.7.12.tar.gz`
    `cd tmp; tar zxf gosu-mac-0.7.12.tar.gz`
  
    `mv "tmp/RubyGosu Deployment Template.app" pkg/Port.app`

    `cp -R bin images lib sounds README* "pkg/Port.app/Contents/Resources/"`
    `cd "pkg/Port.app/Contents/Resources/"; mv bin/port bin/port.rb`
    `echo "require File.dirname(__FILE__) + '/bin/port'" > "pkg/Port.app/Contents/Resources/Main.rb"`
    
    `rm -rf tmp/`
    `cd pkg; tar zcf Port.app.tgz Port.app`

    puts "Applicaiton is now packaged: pkg/Port.app and pkg/Port.app.tgz"
  end
  
  task :mac_test => :mac do
    `open pkg/Port.app`
  end
end