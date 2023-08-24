if (elf_file = Dir.glob('*.elf')[0])
  path_sim_binary = env(:PATH_SIM_BINARY)
  path_whisper = env(:PATH_WHISPER)

  [
    "-sv_lib #{path_sim_binary}/cosim/lib/libcosim",
    '+enable_cosim',
    "+whisper_json_path=#{path_sim_binary}/cosim/whisper_config.json",
    "+whisper_path=#{path_whisper}",
    "+testfile=#{elf_file}",
    '+dutmon_tracer',
    '+bridge_tracer',
  ].each { |arg| runtime_argument arg }
end
