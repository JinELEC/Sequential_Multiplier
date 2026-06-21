module adder #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic             cout,
    output logic [WIDTH-1:0] sum
);

assign {cout, sum} = a + b + cin;

endmodule