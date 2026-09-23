library ieee;
use ieee.std_logic_1164.all;

entity hdmi_controler is
    generic (
        h_res  : positive := 720; -- Number of visible pixels in each line
        v_res  : positive := 480; -- Number of visible lines in each frame
        h_sync : positive := 61;  -- Length of the horizontal sync period
        h_fp   : positive := 58;  -- Empty space before the active line
        h_bp   : positive := 18;  -- Empty space after the active line
        v_sync : positive := 5;   -- Length of the vertical sync period
        v_fp   : positive := 30;  -- Empty space before the active frame
        v_bp   : positive := 9    -- Empty space after the active frame
    );
    port (
        -- System clock and active-low reset
        i_clk      : in std_logic;
        i_rst_n    : in std_logic;
        -- HDMI timing and data-enable signals
        o_hdmi_hs  : out std_logic; -- Marks the horizontal sync period
        o_hdmi_vs  : out std_logic; -- Marks the vertical sync period
        o_hdmi_de  : out std_logic; -- High while the image is being displayed
        -- Interface for the pixel-generation circuit
        o_pixel_en      : out std_logic; -- High when a new pixel is needed
        o_pixel_address : out natural range 0 to h_res * v_res - 1; -- Position of the pixel in memory
        o_x_counter     : out natural range 0 to h_res - 1; -- Current column on the screen
        o_y_counter     : out natural range 0 to v_res - 1  -- Current row on the screen
    );
end entity hdmi_controler;

architecture rtl of hdmi_controler is

    -- Horizontal timing limits for one complete line
    constant h_start : natural := h_sync + h_fp;        -- 119: active video begins
    constant h_end   : natural := h_start + h_res;      -- 839: active video ends
    constant h_total : natural := h_end + h_bp;         -- 857: end of the line

    -- Vertical timing limits for one complete frame
    constant v_start : natural := v_sync + v_fp;        -- 35: active video begins
    constant v_end   : natural := v_start + v_res;      -- 515: active video ends
    constant v_total : natural := v_end + v_bp;         -- 524: end of the frame

    signal r_h_count : natural range 0 to h_total := 0; -- Counts the horizontal timing
    signal r_h_active : std_logic := '0';               -- High while active pixels are being sent

    signal r_v_count : natural range 0 to v_total := 0; -- Counts the vertical timing
    signal r_v_active : std_logic := '0';               -- High while active lines are being sent

    signal s_x : natural range 0 to h_res - 1 := 0;     -- Pixel column inside the active image
    signal s_y : natural range 0 to v_res - 1 := 0;     -- Pixel row inside the active image

begin

    -- Count the horizontal timing and mark the active part of each line
    process(i_clk, i_rst_n)
    begin
        if i_rst_n = '0' then
            r_h_count <= 0;
            o_hdmi_hs <= '1';
            r_h_active <= '0';
        elsif rising_edge(i_clk) then
            if (r_h_count = h_total) then
                r_h_count <= 0;
            else
                r_h_count <= r_h_count + 1;
            end if;

            if (r_h_count >= h_sync) AND (r_h_count /= h_total) then
                o_hdmi_hs <= '1';
            else
                o_hdmi_hs <= '0';
            end if;

            if (r_h_count = h_start) then
                r_h_active <= '1';
            elsif (r_h_count = h_end) then
                r_h_active <= '0';
            end if;
        end if;
    end process;


    -- Move to the next frame line after each complete horizontal line
    process (i_clk, i_rst_n)
        variable v_count_next : natural range 0 to v_total;
    begin
        if i_rst_n = '0' then
            r_v_count <= 0;
            o_hdmi_vs <= '1';
            r_v_active <= '0';
        elsif rising_edge(i_clk) then
            v_count_next := r_v_count;

            if (r_h_count = h_total) then
                if (r_v_count = v_total) then
                    v_count_next := 0;
                else
                    v_count_next := r_v_count + 1;
                end if;
            end if;

            r_v_count <= v_count_next;

            if (v_count_next > v_sync) AND (v_count_next <= v_total) then
                o_hdmi_vs <= '1';
            else
                o_hdmi_vs <= '0';
            end if;

            if (v_count_next > v_start) AND (v_count_next <= v_end) then
                r_v_active <= '1';
            else
                r_v_active <= '0';
            end if;

        end if;
    end process;

    -- Register the signal that says when visible image data is valid
    process (i_clk, i_rst_n)
    begin
        if i_rst_n = '0' then
            o_hdmi_de <= '0';
        elsif rising_edge(i_clk) then
            o_hdmi_de <= r_v_active and r_h_active;
        end if;

    end process;

    -- Ask for pixels only when both counters are inside the active image
    o_pixel_en <= r_v_active and r_h_active;

    s_x <= r_h_count - h_start - 1 when (r_h_active = '1') else 0;
    s_y <= r_v_count - v_start - 1 when (r_v_active = '1') else 0;

    o_x_counter <= s_x;
    o_y_counter <= s_y;

    -- Turn the row and column into one address for the frame buffer
    o_pixel_address <= s_y * h_res + s_x when (r_h_active = '1' and r_v_active = '1') else 0;
end architecture rtl;
