`timescale 1ns / 1ps

module tb_smart_door_lock;

  // Parameters
  reg clk;
  reg rst;
  reg [3:0] in;
  reg enter;
  reg user_sel;

  // Outputs
  wire unlock_a;
  wire unlock_b;
  wire locked;

  // Instantiate the Unit Under Test (UUT)
  smart_door_lock_with_security_system #(
    .pass_a(4'b1011), // 11
    .pass_b(4'b1101), // 13
    .max_wrong(3)
  ) uut (
    .clk(clk),
    .rst(rst),
    .in(in),
    .enter(enter),
    .user_sel(user_sel),
    .unlock_a(unlock_a),
    .unlock_b(unlock_b),
    .locked(locked)
  );

  // Clock generation (100MHz)
  always #5 clk = ~clk;

  initial begin
    // Initialize Inputs
    clk = 0;
    rst = 1;
    in = 0;
    enter = 0;
    user_sel = 0;

    // Wait 20 ns for global reset
    #20 rst = 0;
    
    // --- SCENARIO 1: Successful Unlock User A ---
    #10;
    user_sel = 0;      // Select User A
    in = 4'b1011;      // Correct Password
    enter = 1;         // Press Enter
    #10 enter = 0;     // Release Enter
    #20;

    // --- SCENARIO 2: Successful Unlock User B ---
    user_sel = 1;      // Select User B
    in = 4'b1101;      // Correct Password
    enter = 1;
    #10 enter = 0;
    #20;

    // --- SCENARIO 3: Trigger Security Lockout (3 Fails) ---
    // Fail 1
    user_sel = 0;
    in = 4'b0000;      // Wrong Password
    enter = 1;
    #10 enter = 0;
    #20;

    // Fail 2
    in = 4'b1111;      // Wrong Password
    enter = 1;
    #10 enter = 0;
    #20;

    // Fail 3 (Should trigger 'locked' output)
    in = 4'b0101;      // Wrong Password
    enter = 1;
    #10 enter = 0;
    #20;

    // --- SCENARIO 4: Attempt Correct Password while Locked ---
    in = 4'b1011;      // Correct Password
    enter = 1;         // Should NOT unlock because locked == 1
    #10 enter = 0;
    
    #50;
    $display("Simulation Finished");
    $finish;
  end
      
endmodule