# coding: utf-8

JEKYLL = "jekyll"

task :default => "all"

task :all => [ :conf, :misc ] do
  puts 'done: gen all'
end

task :conf do
  chdir "conf"
  sh "cp -apr ~/conf/home ."
  sh "cp -apr ~/conf/root ."
  chdir ".."
end

task :misc do
  chdir "misc/conv"
  sh "for i in ~/work/conv/*.sh; do if [ -f $i ]; then cp $i .; fi; done"
  sh "for i in ~/work/conv/*.rb; do if [ -f $i ]; then cp $i .; fi; done"
  chdir "../.."
end



# up pages repository
task :commit do
  dt = sprintf( "%04d-%02d-%02d", Time.now.year, Time.now.month, Time.now.day )
  sh "git add --all"
  sh "git commit -m '#{dt}'"
end

task :co => [ "commit" ] do
end
task :up => [ "commit" ] do
  sh "git push origin master"
end


