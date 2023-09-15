def parse_params
  params = find_file('cosim/params.h', from: :cwd)
  if params
    ['k_NumHarts', 'k_XLen', 'k_VLen'].map do |param|
      File.open(params) do |file|
        file
          .grep(/#{param}\s*=\s*(\d+)/) { $~[1] }
          .then(&:first)
          .to_i
      end
    end
  else
    [1, 32, 256]
  end
end

num_harts, xlen, vlen = parse_params
define_macro :TB_RICE_COSIM_HARTS, num_harts
define_macro :TB_RICE_COSIM_XLEN, xlen
define_macro :TB_RICE_COSIM_VLEN, vlen

source_file 'tb_rice_cosim_pkg.sv'
