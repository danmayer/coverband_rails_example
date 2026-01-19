desc "build docker file"
task build_docker: :environment do
  sh "docker build -t coverband_rails_example ."
end

desc "run docker container"
task run_docker: :environment do
  sh "docker run -p 3000:3000 coverband_rails_example"
end
