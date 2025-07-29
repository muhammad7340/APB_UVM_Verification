

`include "uvm_macros.svh"//contain all uvm macros
class sequence_item extends uvm_sequence_item;
`uvm_object_utils(sequence_item) //object not component-factory registraction

    //Data and control signals in the transaction packet(sequence_item)
    //Data memebers (fields) that make up the transactions

    //*Inputs of DUT are randomized
    rand  bit [31:0] PADDR;
    rand  bit [31:0] PWDATA;

    //*Outputs of Dut arent Randomized
          bit [31:0] PRDATA;
          bit        PREADY;


          bit        PWRITE;
          bit        PENABLE;
          bit        PSEL;
          bit        PRESET;
          bit [0:3]  PSTRB;
          bit        PSLVERR;
          
    // Constraints
    constraint c1{soft PADDR[31:0]>=32'd0; PADDR[31:0] <32'd32;};//PADDR is randomized between 0 and 31 ,constraints to avoid illegal transactions
    //here soft keyword in a constraint means the constraint can be overridden by a stronger constraint elsewhere (like in a test or sequence).

    // Constructor
    function new(string name="sequence_item");//no parent as its not a component
        super.new(name);
        `uvm_info(get_type_name(), $sformatf("SEQ_ITEM created: %s at time %0t", name, $time), UVM_LOW)

    endfunction:new

    // Copy method
    // `virtual` lets you override the function in subclasses.
    virtual function void do_copy(uvm_object rhs);//generic argument object of type uvm_object
        sequence_item rhs_; //local variable of type sequence_item
        if(!$cast(rhs_,rhs))begin //Safely converts generic rhs object to specific type (sequence_item type object rhs_)
            `uvm_fatal(get_type_name(),"do_copy:rhs is not a sequence_item")
        end
        super.do_copy(rhs);// parent-call: copies parent fields ensuring deep copy
        this.PADDR = rhs_.PADDR;// copying sequence_item rhs_field to uvm_object rhs fileds
        this.PWDATA = rhs_.PWDATA;
        this.PRDATA = rhs_.PRDATA;
        this.PREADY = rhs_.PREADY;
        this.PWRITE = rhs_.PWRITE;
        this.PENABLE = rhs_.PENABLE;
        this.PSEL = rhs_.PSEL;
        this.PRESET = rhs_.PRESET;
        this.PSTRB = rhs_.PSTRB;
        this.PSLVERR = rhs_.PSLVERR;
    endfunction:do_copy

    // Compare method
    virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
        sequence_item rhs_;
        if(!$cast(rhs_,rhs))begin
            `uvm_fatal(get_type_name(),"do_compare:rhs is not a sequence_item")
        end
        return super.do_compare(rhs,comparer) && // parent-call: parent class comparison
               (this.PADDR == rhs_.PADDR) && // comparing rhs_ and rhs fields
               (this.PWDATA == rhs_.PWDATA) &&
               (this.PRDATA == rhs_.PRDATA) &&
               (this.PREADY == rhs_.PREADY) &&
               (this.PWRITE == rhs_.PWRITE) &&
               (this.PENABLE == rhs_.PENABLE) &&
               (this.PSEL == rhs_.PSEL) &&
               (this.PRESET == rhs_.PRESET) &&
               (this.PSTRB == rhs_.PSTRB) &&
               (this.PSLVERR == rhs_.PSLVERR);
    endfunction:do_compare

    // Convert2String method
    virtual function string convert2string();
        string s;
        s = super.convert2string();// parent-call: converts parent fields to string
        s = $sformatf("PADDR: 0x%0h, PWDATA: 0x%0h, PRDATA: 0x%0h, PREADY: 0x%0d, PWRITE: 0x%0d, PENABLE: 0x%0d, PSEL: 0x%0d, PRESET: 0x%0d, PSTRB: 0x%0b, PSLVERR: 0x%0d", 
                        PADDR, PWDATA, PRDATA, PREADY, PWRITE, PENABLE, PSEL, PRESET, PSTRB, PSLVERR);
        return s;
    endfunction:convert2string

   //print method
   virtual function void do_print(uvm_printer printer); 
	printer.m_string = convert2string(); 
	endfunction



    //pack, unpack and record methods
	virtual function void do_pack(uvm_packer packer); 
	// 
	endfunction 

	virtual function void do_unpack(uvm_packer packer); 
	// 
	endfunction 

	virtual function void do_record(uvm_recorder recorder); 
	//
	endfunction
 
endclass:sequence_item


