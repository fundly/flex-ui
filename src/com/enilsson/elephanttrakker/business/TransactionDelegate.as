package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.TransactionVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class TransactionDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function TransactionDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPayment');
		}
		
		public function doTransaction(transaction:TransactionVO):void
		{
			if(_model.debug) Logger.info('Transaction Data', transaction);
			
			var token:AsyncToken = service.bill_card(
				transaction.card_type,
				transaction.card_num,
				transaction.exp_month,
				transaction.exp_year,
				transaction.ccv2,
				transaction.amount,
				transaction.first_name,
				transaction.last_name,
				transaction.address,
				transaction.city,
				transaction.state,
				transaction.zip,
				transaction.foreign_key
			);
			token.addResponder(responder);
		}
	}
}