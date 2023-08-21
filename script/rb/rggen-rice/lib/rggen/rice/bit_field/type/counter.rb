# frozen_string_literal: true

RgGen.define_list_item_feature(:bit_field, :type, :counter) do
  register_map do
    read_write
    initial_value require: true
    reference use: true, width: 1
  end

  sv_rtl do
    build do
      unless bit_field.reference?
        input :disable, {
          name: "i_#{full_name}_disable", width: 1,
          array_size: array_size, array_format: array_port_format
        }
      end
      input :up, {
        name: "i_#{full_name}_up", width: 1,
        array_size: array_size, array_format: array_port_format
      }
      output :count, {
        name: "o_#{full_name}_count", width: width,
        array_size: array_size, array_format: array_port_format
      }
    end

    main_code :bit_field, from_template: true

    private

    def disable_signal
      reference_bit_field || disable[loop_variables]
    end
  end
end
