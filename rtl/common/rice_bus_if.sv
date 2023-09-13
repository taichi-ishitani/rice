interface rice_bus_if #(
  parameter int ADDRESS_WIDTH = 32,
  parameter int DATA_WIDTH    = 32,
  parameter int STROBE_WIDTH  = DATA_WIDTH / 8
);
  typedef logic [ADDRESS_WIDTH-1:0] rice_bus_address;
  typedef logic [STROBE_WIDTH-1:0]  rice_bus_strobe;
  typedef logic [DATA_WIDTH-1:0]    rice_bus_data;

  logic             request_ready;
  logic             request_valid;
  rice_bus_address  address;
  rice_bus_strobe   strobe;
  rice_bus_data     write_data;
  logic             response_ready;
  logic             response_valid;
  rice_bus_data     read_data;
  logic             error;

  function automatic logic request_ack();
    return request_ready && request_valid;
  endfunction

  function automatic logic read_request_valid();
    return request_valid && (strobe == '0);
  endfunction

  function automatic logic read_request_ack();
    return request_ack() && (strobe == '0);
  endfunction

  function automatic logic write_request_valid();
    return request_valid && (strobe != '0);
  endfunction

  function automatic logic write_request_ack();
    return request_ack() && (strobe != '0);
  endfunction

  function automatic logic response_ack();
    return response_ready && response_valid;
  endfunction

  modport master (
    input   request_ready,
    output  request_valid,
    output  address,
    output  strobe,
    output  write_data,
    output  response_ready,
    input   response_valid,
    input   read_data,
    input   error,
    import  request_ack,
    import  read_request_valid,
    import  read_request_ack,
    import  write_request_valid,
    import  write_request_ack,
    import  response_ack
  );

  modport slave (
    output  request_ready,
    input   request_valid,
    input   address,
    input   strobe,
    input   write_data,
    input   response_ready,
    output  response_valid,
    output  read_data,
    output  error,
    import  request_ack,
    import  read_request_valid,
    import  read_request_ack,
    import  write_request_valid,
    import  write_request_ack,
    import  response_ack
  );

  modport monitor (
    input   request_ready,
    input   request_valid,
    input   address,
    input   strobe,
    input   write_data,
    input   response_ready,
    input   response_valid,
    input   read_data,
    input   error,
    import  request_ack,
    import  read_request_valid,
    import  read_request_ack,
    import  write_request_valid,
    import  write_request_ack,
    import  response_ack
  );
endinterface
