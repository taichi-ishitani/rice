# frozen_string_literal: true

RgGen.define_list_item_feature(:register_block, :protocol, :rice_bus_if) do
  configuration do
    verify(:component) do
      error_condition { [32, 64].none?(configuration.bus_width) }
      message do
        'bus width should be either 32 bit or 64 bit width: ' \
        "#{configuration.bus_width}"
      end
    end
  end

  sv_rtl do
    build do
      interface_port :csr_if, {
        name: 'csr_if', interface_type: 'rice_bus_if', modport: 'slave'
      }
    end

    main_code :register_block, from_template: true
  end
end
