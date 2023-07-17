['rtl', 'tb', 'test'].each do |dir|
  file_list File.join(dir, 'core', 'core.rb')
end

source_file 'tb/core/tb.sv', from: :root
