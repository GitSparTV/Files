if jit.status() then
	LoadDir("libraries/modules/jit")
else
	LoadDir("libraries/modules/not-jit")
end