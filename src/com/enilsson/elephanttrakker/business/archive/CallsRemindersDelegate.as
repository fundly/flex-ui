package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class CallsRemindersDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function CallsRemindersDelegate(responder:IResponder)
		{
			this.responder = responder;
		}

		public function searchContacts( searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var whereObj:Object =  new Object();
			whereObj['statement'] = '(1)';
			whereObj[1] = { 
				'what' : "contacts.lname",
				'val' : searchTerm + '%',
				'op' : 'LIKE'
			};
			
			var token:AsyncToken = service.record_tree('contacts', whereObj, null, iFrom, iCount);
			token.addResponder(responder);
		}

	}
}