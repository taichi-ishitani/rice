file_list 'tue/compile.rb', from: :current
file_list 'tvip-common/compile.rb', from: :current

include_directory '.'
source_file 'tb_rice_bus_if.sv'
source_file 'tb_rice_bus_pkg.sv'
source_file 'tb_rice_riscv_pkg.sv'
source_file 'tb_rice_env_base_pkg.sv'
source_file 'tb_rice_bus_slave_bfm.sv'
