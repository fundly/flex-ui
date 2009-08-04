package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class MyDownlineDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyDownlineDelegate(responder:IResponder)
		{
			this.responder = responder;	
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsDownline');
		}
		
		public function getDownline( userID:Number, nodeLevels:int=4 ):void
		{			
			var token:AsyncToken = service.get_downline( userID, nodeLevels );			
			token.addResponder(responder);
		}
		
		public function getParents( userID:Number ):void
		{
			var token:AsyncToken = service.get_parents( userID );			
			token.addResponder(responder);
		}

	}
}