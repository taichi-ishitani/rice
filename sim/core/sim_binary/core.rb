file_list 'rtl/core/core.rb'
file_list 'tb/core/core.rb'

['rtl', 'tb', 'test'].each do |dir|
  file_list File.join(dir, 'core', 'core.rb')
end

source_file 'tb/core/tb.sv', from: :root
