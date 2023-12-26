library verilog;
use verilog.vl_types.all;
entity InterruptMaskRegister is
    port(
        OCW1            : in     vl_logic_vector(7 downto 0);
        readIMR         : in     vl_logic;
        IMR_reg         : out    vl_logic_vector(7 downto 0);
        dataBuffer      : out    vl_logic_vector(7 downto 0)
    );
end InterruptMaskRegister;
