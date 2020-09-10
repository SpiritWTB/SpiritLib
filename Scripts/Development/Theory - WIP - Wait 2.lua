function wait(x)
	local startTime = os.time()

	while os.time() - startTime < x do
		coroutine.yield()
	end

	return true
end