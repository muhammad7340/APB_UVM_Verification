//Write and Read Burst Transaction

class sequence_one extends uvm_sequence#(sequence_item); //type parameter passed `packet/transaction`
  `uvm_object_utils(sequence_one)//object instead of component
  
  int WRITE_BURST_LENGTH = 8;//number of write transactions
  int READ_BURST_LENGTH  = 8;//number of read transactions

  //Constructor
  function new(string name="sequence_one");//no parent
    super.new(name);
    `uvm_info(get_type_name(), $sformatf("SEQUENCE created: %s at time %0t", name, $time), UVM_LOW)           
  endfunction
  
               
  //create and send request to driver             
  virtual task body();//this task is called @ sequence_item.start(env.agent.seqr) in test.sv
  sequence_item w_trans;
  sequence_item r_trans;

      //generate the write transaction 
      w_trans=sequence_item::type_id::create("w_trans");//create request
      w_trans.PADDR = 0;

      for (int i=1; i<=WRITE_BURST_LENGTH; i++) begin
            w_trans.PSEL = 1;
            w_trans.PWRITE = 1;
            w_trans.PENABLE = 1;  
            w_trans.PWDATA = $urandom;
                
            start_item(w_trans);
                `uvm_info(get_full_name(), $sformatf("WRITE_SEQUENCE: %s", w_trans.convert2string()), UVM_DEBUG)
            finish_item(w_trans);

                
            w_trans.PADDR++; 
        end


      //generate the read transaction 
      r_trans=sequence_item::type_id::create("r_trans");//create request
      r_trans.PADDR = 0;

      for (int i=1; i<=READ_BURST_LENGTH; i++) begin
            r_trans.PSEL = 1;
            r_trans.PWRITE = 0;
            r_trans.PENABLE = 1;  
            r_trans.PWDATA = $urandom;
                
            start_item(r_trans);
                `uvm_info(get_full_name(), $sformatf("READ_SEQUENCE: %s", r_trans.convert2string()), UVM_DEBUG)
            finish_item(r_trans);

                
            r_trans.PADDR++; 
        end
  endtask
               
endclass:sequence_one
                 
               
         
               
               
               