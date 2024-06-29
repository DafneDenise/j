 state_machine_cache: process (curr_st_cache, reg_valid_line, reg_dirty_line, RdStb, WrStb, Addr,
                               regs_label(0), regs_label(1), regs_label(2), regs_label(3),
                               end_wr_block, end_rd_block)
    variable addr_line:integer;
    begin
    	addr_line:=conv_integer(Addr(6 downto 5));       
        rd_mem_proc <= '0';
        wr_mem_proc <= '0';
        send_block <= '0';
        write_block <= '0';
        next_valid_line <= reg_valid_line;
        next_dirty_line <= reg_dirty_line;
        for i in 0 to 3 loop
             next_label(i) <= regs_label(i);
        end loop;
        next_st_cache <= curr_st_cache;
        D_Rdy <= '1';
		case (curr_st_cache) is
			when init_st_cache => 
            	if(rdstb='1'or wrstb='1')then
                	D_Rdy <='0';
                    if(reg_valid_line(addr_line)='1')then
                    	if(conv_integer(regs_label(addr_line))=conv_integer(addr(31 downto 7)))then
                        	if(Rdstb='1')then
                                rd_mem_proc<='1';
                                D_Rdy <= '1';
                                next_st_cache<= init_st_cache;
                        	end if;
                            if(wrstb='1') then
                            	wr_mem_proc<='1';
                                D_Rdy <= '1';
                                reg_dirty_line(addr_line)<='1';
                                next_st_cache<= init_st_cache;
                        	end if;
                        else 
                            if(reg_dirty_line(addr_line)='1')then
                              	next_st_cache <= send_st_block;
                            else
                                next_st_cache <= write_st_block;
                            end if;
                        end if;
                    else 
                    	reg_valid_line(addr_line)<='1';
                       	next_st_cache<=write_st_block;
                    end if;
                end if; 
			when send_st_block => 
            	d_rdy<='0';
                send_block<='1';
                	if(end_rd_block = '1')then
        	            send_block<='0';
                        reg_dirty_line(addr_line)<='0';
                        next_st_cache<= write_st_block;
                    end if; 
            when write_st_block =>
            	d_rdy <='0';
                write_block<='1';
                if(end_wr_block ='1')then
                	write_block<='0';
                    if(reg_valid_line(addr_line)='0')then
                    	reg_valid_line(addr_line) <='1';
                    end if;
                    if(wrstb='1')then
                    	wr_mem_proc<='1';
                        D_Rdy <= '1';
                        reg_dirty_line(addr_line)<='1';
                        next_st_cache<= init_st_cache;
                    end if;
                    if(rdstb='1')then
                    	rd_mem_proc<='1';
                        D_Rdy <= '1';
                        next_st_cache<= init_st_cache;
                    end if;    
                end if;
		end case;         
	end process;
