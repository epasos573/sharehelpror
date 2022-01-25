Sidekiq.configure_server do |config|
  config.redis = { 
    url: 'redis://redis-16718.c93.us-east-1-3.ec2.cloud.redislabs.com:16718/0',
    password: '5lEdIqBDoqA10rkrtEc5eyePFO4ovuTq'
   }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis-16718.c93.us-east-1-3.ec2.cloud.redislabs.com:16718/0',
    password: '5lEdIqBDoqA10rkrtEc5eyePFO4ovuTq'
   }
end