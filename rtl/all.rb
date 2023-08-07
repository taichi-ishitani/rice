base = __dir__
Dir.glob('*/*.rb', base: base) do |file|
  file_list file, from: base
end
