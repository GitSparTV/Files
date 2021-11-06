-- require("libraries.modules.wav")

-- -- Write audio file
-- local samples, freq = {n = 0}, math.pi * 2 * 500
-- for i = 0, 44100*3 do
-- 	for c = 1, 2 do
-- 		samples.n = samples.n + 1
-- 		samples[samples.n] = math.sin(i % 44100 / 44099 * freq) * 32767
-- 	end
-- end


-- -- Read audio file
-- local reader = wav.create_context("out.wav", "r")
-- print("Filename: " .. reader.get_filename())
-- print("Mode: " .. reader.get_mode())
-- print("File size: " .. reader.get_file_size())
-- print("Channels: " .. reader.get_channels_number())
-- print("Sample rate: " .. reader.get_sample_rate())
-- print("Byte rate: " .. reader.get_byte_rate())
-- print("Block align: " .. reader.get_block_align())
-- print("Bitdepth: " .. reader.get_bits_per_sample())
-- print("Samples per channel: " .. reader.get_samples_per_channel())
-- print("Sample at 500ms: " .. reader.get_sample_from_ms(500))
-- print("Milliseconds from 3rd sample: " .. reader.get_ms_from_sample(3))
-- print(string.format("Min- & maximal amplitude: %d <-> %d", reader.get_min_max_amplitude()))
-- reader.set_position(256)
-- print("Sample 256, channel 2: " .. reader.get_samples(1)[2][1])
