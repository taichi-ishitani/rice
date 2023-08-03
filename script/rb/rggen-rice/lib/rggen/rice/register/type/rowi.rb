# frozen_string_literal: true

RgGen.define_list_item_feature(:register, :type, :rowi) do
  register_map do
    support_array_register

    writable? { true }
    readable? { true }

    verify(:component) do
      error_condition do
        register.bit_fields.any?(&:writable?)
      end
      message do
        'not allow to assign any writable bit fields'
      end
    end
  end

  sv_rtl do
    main_code :register, from_template: true
  end
end
