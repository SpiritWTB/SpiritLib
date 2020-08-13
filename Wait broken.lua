local threads = {}

function Update()
	local now = os.time()
	local resumes = {}

	for thread, finish in pairs(threads) do
		local diff = finish - now

		if diff < 0.005 then
			table.insert(resumes, thread)
		end
	end

	if #resumes > 0 then
		for i, thread in pairs(resumes) do
			threads[thread] = nil
			coroutine.resume(thread, now)
		end
	end

	--[[ if InputPressed("q") then
		print("1")
		wait(1)
		print("2")
		wait(1)
		print("3")
		wait(1)
		print("4")
	end ]]
end

function wait(delay)
	local time = tonumber(delay) or 1 / 30
	local start = os.time()

	local thread = coroutine.running()
	threads[thread] = start + time

	local now = coroutine.yield()
	return now - start, os.clock()
end