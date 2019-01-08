// Automatically generated by PRGA SimProj generator

`timescale 1ns/1ps
module {{ target.name }}_tb_top;

`ifdef FPGA_TEST
    localparam  cfg_w   = {{ config.width }},
                bs_size = {{ config.bs_size }},
                bs_wordsize = {{ config.bs_wordsize }};
`endif

    // system control
    reg sys_clk, sys_rst;
    wire sys_success, sys_fail;

    // configuration (programming) control 
    localparam  INIT            = 3'd0,
                RESET           = 3'd1,
                PROGRAMMING     = 3'd2,
                PROG_DONE       = 3'd3,
                PROG_STABLIZING = 3'd4,
                TARGET_RUNNING  = 3'd5;

`ifdef FPGA_TEST
    reg [2:0] state, state_next;
    reg cfg_e;
    wire cfg_clk = cfg_e & sys_clk;
    reg [cfg_w - 1:0] cfg_i;
    reg [0:256*8-1] bs_file;
    reg [bs_wordsize - 1:0] cfg_m [0:(bs_size / bs_wordsize)];
    reg [63:0] cfg_progress;
    reg [7:0] cfg_percentage;
`else
    reg [2:0] state = TARGET_RUNNING;
`endif

    // logging 
    reg [0:256*8-1] dump_file;
    reg [31:0] cycle_count, max_cycle_count;

    // host wire
    wire host_rst = sys_rst || state != TARGET_RUNNING;

    // target wires
    {%- for name, width in target.ports.iteritems() %}
    wire [{{ width - 1 }}:0] guest_{{ name }};
    {%- endfor %}

    // test host
    {{ host.name }} host (
        .sys_clk(sys_clk)
        ,.sys_rst(host_rst)
        ,.sys_success(sys_success)
        ,.sys_fail(sys_fail)
        ,.cycle_count(cycle_count)
        {%- for name in target.ports %}
        ,.{{ host.portmap[name]|default(name) }}(guest_{{ name }})
        {%- endfor %}
        );

    // test guest
`ifdef FPGA_TEST
    {{ guest.name }} guest (
        .cfg_clk(cfg_clk)
        ,.cfg_i(cfg_i)
        ,.cfg_e(cfg_e)
        {%- for port, connection in guest.ports.iteritems() %}
        ,.{{ port }}({% if connection %}guest_{{ connection }}{% endif %})
        {%- endfor %}
        );
`else
    {{ target.name }} guest (
        {%- set comma3 = joiner(",") -%}
        {%- for name in target.ports %}
        {{ comma3() }}.{{ name }}(guest_{{ name }})
        {%- endfor %}
        );
`endif

    // test setup
    initial begin
        if ($value$plusargs("dump_file=%s", dump_file)) begin
            $display("[INFO] Dumping waveform: %s", dump_file);
            $dumpfile(dump_file);
            $dumpvars;
        end

        if (!$value$plusargs("max_cycle=%d", max_cycle_count)) begin
            max_cycle_count = 100_000;
        end
        $display("[INFO] Max cycle count: %d", max_cycle_count);

`ifdef FPGA_TEST
        if (!$value$plusargs("bitstream_memh=%s", bs_file)) begin
            $display("[INFO] Missing required argument: bitstream_memh");
            $finish;
        end

        $readmemh(bs_file, cfg_m);
`endif

        sys_clk = 1'b0;
        sys_rst = 1'b0;

        #{{ (clk_period|default(10)) * 0.75 }} sys_rst = 1'b1;

        #{{ clk_period|default(10) }} sys_rst = 1'b0;
    end

    // system clock generator
    always #{{ (clk_period|default(10)) / 2.0 }} sys_clk = ~sys_clk;

`ifdef FPGA_TEST
    // FSM
    always @(posedge sys_clk) begin
        if (sys_rst) begin
            state <= INIT;
        end else begin
            state <= state_next;
        end
    end

    // FSM next-stage logic
    always @* begin
        state_next = state;

        case (state)
            INIT: begin
                state_next = PROGRAMMING;
            end
            PROGRAMMING: begin
                if (cfg_progress + cfg_w >= bs_size) begin
                    state_next = PROG_DONE;
                end
            end
            PROG_DONE: begin
                state_next = PROG_STABLIZING;
            end
            PROG_STABLIZING: begin
                state_next = TARGET_RUNNING;
            end
        endcase
    end

    // FSM output
    always @* begin
        cfg_e = state == PROGRAMMING;
        cfg_i = cfg_m[cfg_progress / bs_wordsize][(cfg_progress % bs_wordsize) +: cfg_w];
    end

    // configuration (programming) progress tracking
    always @(posedge sys_clk) begin
        if (state == PROGRAMMING) begin
            cfg_progress <= cfg_progress + cfg_w;

            if (cfg_progress * 100 / bs_size >= cfg_percentage) begin
                $display("[INFO] [CONFIG] %3d%% config done (%d/%d)", cfg_percentage, cfg_progress, bs_size);
                cfg_percentage <= cfg_percentage + 1;
            end 
        end else begin
            cfg_progress <= 0;
            cfg_percentage <= 0;
        end
    end
`endif

    // cycle count tracking
    always @(posedge sys_clk) begin
        if (sys_rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end

        if (~sys_rst && (cycle_count % 1_000 == 0)) begin
            $display("[INFO] %3dK cycles passed", cycle_count / 1_000);
        end

        if (~sys_rst && (cycle_count >= max_cycle_count)) begin
            $display("[INFO] max cycle count reached, killing simulation");
            $finish;
        end
    end

    // test result reporting
    always @* begin
        if (~host_rst) begin
            if (sys_success) begin
                $display("[INFO] ********* all tests passed **********");
                $finish;
            end else if (sys_fail) begin
                $display("[INFO] ********* test failed **********");
                $finish;
            end
        end
    end

endmodule
