unless target_tool? :svlint
  file_list 'rggen-sv-rtl/compile_core.rb', from: :current
  source_file 'rice_csr_u_level_xlen32.sv'
  source_file 'rice_csr_m_level_xlen32.sv'
end

source_file 'rggen_rice_bus_if_adapter.sv'
source_file 'rggen_rice_register_variable_access.sv'
source_file 'rggen_rice_bit_field_counter.sv'
