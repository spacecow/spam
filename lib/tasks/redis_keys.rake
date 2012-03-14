task :redis_keys => :environment do
  Translation.print_keys
end
