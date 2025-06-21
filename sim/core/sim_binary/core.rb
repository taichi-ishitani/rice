define_macro :TB_RICE_CORE_ENV_DUT, 'rice___rice_core__rice___rice_core_pkg__32'
define_macro :TB_RICE_CORE_ENV_PIPELINE_IF, 'rice___tb_rice_core_env_pipeline_if__rice___rice_core_pkg__32'
define_macro :TB_RICE_CORE_ENV_PIPELINE_IF_WRAPPER, 'rice___tb_rice_core_env_pipeline_if_wrapper__rice___rice_core_pkg__32'
define_macro :TB_RICE_CORE_ENV_INST_CHECKER, 'rice___tb_rice_core_env_inst_checker__rice___rice_core_pkg__32'
define_macro :TB_RICE_CORE_ENV_BUS_IF, 'rice_rice_bus_if'

['tb', 'test'].each do |dir|
  file_list File.join(dir, 'core', 'core.rb')
end
file_list 'sim_rice.list.rb', from: :current

source_file 'tb/core/tb.sv', from: :root
