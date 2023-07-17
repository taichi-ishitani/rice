class tb_rice_bus_item_waiter extends tue_item_waiter #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .ITEM           (tb_rice_bus_item           )
);
  protected function int get_id(tb_rice_bus_item item);
    return 0;
  endfunction
  `tue_component_default_constructor(tb_rice_bus_item_waiter)
endclass
