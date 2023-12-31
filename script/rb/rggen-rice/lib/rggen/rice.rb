# frozen_string_literal: true

require_relative 'rice/version'

RgGen.setup_plugin :'rggen-rice' do |plugin|
  plugin.version RgGen::RICE::VERSION
  plugin.files [
    'rice/bit_field/type/counter',
    'rice/register/type/variable_access',
    'rice/register_block/protocol/rice_bus_if'
  ]
end
