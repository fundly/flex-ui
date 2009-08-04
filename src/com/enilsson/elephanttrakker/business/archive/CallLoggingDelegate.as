package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class CallLoggingDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function CallLoggingDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getContact( contactID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree( 'contacts', contactID );
			token.addResponder(responder);
		}
		
		public function getPledge( pledgeID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree( 'pledges(transactions<ALL>,checks<ALL>)', pledgeID );
			token.addResponder(responder);
		}
		
		public function autoCompleteSearch( table:String, searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSearch');
			
			var token:AsyncToken = service.table(table, searchTerm + '*', null, iFrom, iCount);
			token.addResponder(responder);
		}
		
		public function getEvent( table:String, eventID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree( table, eventID );
			token.addResponder(responder);
		}
	}
}