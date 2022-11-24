virtual class shape;
	protected real width;
	protected real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new 
	
	pure virtual function real get_area();
	pure virtual function void print();
	
endclass : shape

class rectangle extends shape;
	
	function new(real w, real h);
		super.new(w, h);
	endfunction : new

	function real get_area();
		return width * height;
	endfunction : get_area
	
	function void print();
		$display("Rectangle w=%g, h=%g, area=%g",
				 width,
				 height,
				 get_area());
	endfunction : print

endclass : rectangle

class square extends shape;
	
	function new(real w);
		super.new(w, w);
	endfunction : new

	function real get_area();
		return width * width;
	endfunction : get_area

	function void print();
		$display("Square w=%g, area=%g",
				 width,
				 get_area());
	endfunction : print

endclass : square

class triangle extends shape;
	
	function new(real w, real h);
		super.new(w, h);
	endfunction : new

	function real get_area();
		return 0.5 * width * height;
	endfunction : get_area

	function void print();
		$display("Triangle w=%g, h=%g, area=%g",
				 width,
				 height,
				 get_area());
	endfunction : print
	
endclass : triangle

class shape_factory;

	static function shape make_shape(string shape_type, real w, real h);
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		case(shape_type)
			"rectangle" : begin
				rectangle_h = new(w, h);
				return rectangle_h;
			end
			"square" : begin
				square_h = new(w);
				return square_h;
			end
			"triangle" : begin
				triangle_h = new(w, h);
				return triangle_h;
			end 
			default : $fatal(1, {"Not exist shape: "}, shape_type);
		endcase
	endfunction : make_shape

endclass : shape_factory

class shape_reporter #(type T = shape);

	protected static T shape_storage[$];

	static function void shape_to_queue(T shape);
		shape_storage.push_back(shape);
	endfunction : shape_to_queue

	static function void report_shapes();
		real all_area = 0;
		foreach(shape_storage[i]) begin
			shape_storage[i].print;
			all_area += shape_storage[i].get_area();
		end
		$display("Area of all objects: %g\n", all_area);
	endfunction : report_shapes

endclass : shape_reporter

module top;

	initial begin
		shape 		shape_h;
		rectangle 	rectangle_h;
		square		square_h;
		triangle	triangle_h;
		int file;
		string shape;
		real width;
		real height;
		
		file = $fopen("./lab04part1_shapes.txt", "r");
		
		while($fscanf(file, "%s %f %f", shape, width, height) == 3) begin
			shape_h = shape_factory::make_shape(shape, width, height);
			case(shape)
				"rectangle" : begin
				if($cast(rectangle_h, shape_h))
					shape_reporter#(rectangle)::shape_to_queue(rectangle_h);
				end
				"square" : begin
				if($cast(square_h, shape_h))
					shape_reporter#(square)::shape_to_queue(square_h);
				end
				"triangle" : begin
				if($cast(triangle_h, shape_h))
					shape_reporter#(triangle)::shape_to_queue(triangle_h);
				end
				default : $fatal(1, {"Not exist shape: "}, shape); 
			endcase
		end
		
		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(square)::report_shapes();
		shape_reporter#(triangle)::report_shapes();
		
		$fclose(file);
	end

endmodule : top
