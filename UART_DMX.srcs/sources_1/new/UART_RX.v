`timescale 1ns / 1ps
module UART_RX(
               input               rxd          ,
               input               clk          ,		
               input               rst        ,	
               output  reg[7:0]    data         ,		
               output  reg         IF     
               );

parameter         baud   = 9600;
parameter    	   BPS	  =	100000000 / baud;	//9600������
reg   [14:0]        cnt0         ;
wire                add_cnt0     ;
wire                end_cnt0     ;

reg   [ 3:0]        cnt1         ;
wire                add_cnt1     ;
wire                end_cnt1     ;

reg                 rx0          ;	
reg                 rx1          ;	
reg                 rx2          ;	
wire                rx_en        ;
wire                tst_n        ;

reg                 flag_add     ;

assign rst_n = ~rst;

//�����ݵĿ�ʱ�Ӵ�������ֹ��������̬
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rx0 <= 1'b1;
        rx1 <= 1'b1;
        rx2 <= 1'b1;
	end
	else begin
		rx0 <= rxd;
        rx1 <= rx0;
        rx2 <= rx1;
	end
end

assign rx_en = rx2 & ~rx1;	
//��⵽�½��أ�������λ��1��Ϊ0�����ݴ��俪ʼ

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
    else if(add_cnt0)begin
        if(end_cnt0)
            cnt0 <= 0;
        else
            cnt0 <= cnt0 + 1;
    end
end

assign add_cnt0 = flag_add;
assign end_cnt0 = add_cnt0 && cnt0==BPS-1 ;

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1==9-1 ; //�����ǽ��ճ��򣬴˴�Ҳ����У��λ������ֻ��Ҫ�������ݾͿ��ԣ�����ĵ�10λ��Ȼλֹͣλ�����Բ�������ʡ��Դ

always @ (posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		flag_add <= 1'b0;
	end
	else if(rx_en) begin		
		flag_add <= 1'b1;	
	end
    else if(end_cnt1) begin		
		flag_add <= 1'b0;	
	end
end

always @ (posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		data <= 8'd0;
	end
	else if(add_cnt0 && cnt0==BPS/2-1 && cnt1!=0) begin		//���м�ʱ�̲�������ʱ�����ݱȽ��ȶ����ӵ�λ����λ���β���
	    data[cnt1-1]<= rx2 ;
	end
end


//�����������ź�
always @ (posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		IF <= 1'b0;
	end
    else if(end_cnt1) begin		
		IF <= 1'b1;	
	end
	else begin	
        IF <= 1'b0;			
	end
end

endmodule