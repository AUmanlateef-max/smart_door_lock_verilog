// Smart multi-user door lock with security system.
module smart_door_lock_with_security_system #(
  parameter pass_a = 4'b1011,
  parameter pass_b = 4'b1101,
  parameter max_wrong = 3
)(
  input clk,
  input rst,
  input [3:0] in,    // password input
  input enter,       // assumes debounced input
  input user_sel,    // 0 = a, 1 = b
  
  output reg unlock_a,
  output reg unlock_b,
  output reg locked
);
          
  reg [1:0] wrong_count;
  reg enter_z; // To detect the rising edge of the enter button

  // Edge detection logic: only trigger once per press
  wire enter_pulse = enter && !enter_z;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wrong_count <= 0;
      locked      <= 0;
      unlock_a    <= 0;
      unlock_b    <= 0;
      enter_z     <= 0;
    end else begin
      enter_z <= enter; // Delay register for edge detection
      
      // Default outputs to 0 (pulsed output)
      unlock_a <= 0;
      unlock_b <= 0;

      if (enter_pulse && !locked) begin 
        if (user_sel == 1'b0) begin
          if (in == pass_a) begin
            unlock_a    <= 1;
            wrong_count <= 0;
          end else begin
            wrong_count <= wrong_count + 1'b1;
          end
        end else begin 
          if (in == pass_b) begin
            unlock_b    <= 1;
            wrong_count <= 0;
          end else begin
            wrong_count <= wrong_count + 1'b1;
          end
        end

        // Corrected Lock Logic:
        // We check if it's currently at 2, and about to become 3.
        if (wrong_count >= (max_wrong - 1)) begin
           // Only lock if the current attempt is also a failure
           if ((user_sel == 0 && in != pass_a) || (user_sel == 1 && in != pass_b)) begin
              locked <= 1;
           end
        end
      end
    end
  end
endmodule