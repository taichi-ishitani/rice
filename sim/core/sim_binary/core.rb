['tb', 'test'].each do |dir|
  file_list File.join(dir, 'core', 'core.rb')
end
file_list 'sim_rice.list.rb', from: :current

source_file 'tb/core/tb.sv', from: :root
