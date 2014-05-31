require 'beaneater'

# Connect to pool
@beanstalk = Beaneater::Pool.new(['xi.local:11300'])
# Enqueue jobs to tube
@tube = @beanstalk.tubes["my-tube"]

10.times do 
	@tube.put "hello"
end

# Process jobs from tube
while @tube.peek(:ready)
  job = @tube.reserve  
  puts job.body
  job.delete
end
# Disconnect the pool
@beanstalk.close