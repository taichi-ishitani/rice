# frozen_string_literal: true

RgGen.define_list_item_feature(:register, :type, :variable_access) do
  register_map do
    support_array_register

    writable? { true }
    readable? { true }
  end

  sv_rtl do
    build do
      input :write_enable, {
        name: "i_#{full_name}_write_enable", width: 1,
        array_size: array_size, array_format: array_port_format
      }
      input :read_enable, {
        name: "i_#{full_name}_read_enable", width: 1,
        array_size: array_size, array_format: array_port_format
      }
    end

    main_code :register, from_template: true

    private

    def full_name
      register.full_name
    end

    def array_size
      register.array_size
    end

    def array_port_format
      configuration.array_port_format
    end

    def loop_variables
      register.loop_variables
    end
  end
end
