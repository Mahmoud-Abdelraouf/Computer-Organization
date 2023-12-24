library verilog;
use verilog.vl_types.all;
entity PriorityResolver is
    port(
        freezing        : in     vl_logic;
        IRR_reg         : in     vl_logic_vector(7 downto 0);
        ISR_reg         : in     vl_logic_vector(7 downto 0);
        resetedISR_index: in     vl_logic_vector(2 downto 0);
        OCW2            : in     vl_logic_vector(7 downto 0);
        INT_requestAck  : in     vl_logic;
        serviced_interrupt_index: out    vl_logic_vector(2 downto 0);
        zeroLevelPriorityBit: out    vl_logic_vector(2 downto 0);
        INT_request     : out    vl_logic
    );
end PriorityResolver;
