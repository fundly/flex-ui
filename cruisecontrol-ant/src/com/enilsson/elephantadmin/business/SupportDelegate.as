package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class SupportDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function SupportDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function doSupport(params:Object):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorTicket');
			
			var token:AsyncToken = service.create( 
				params.username, 
				params.email, 
				params.phone, 
				params.contact, 
				params.description, 
				params.title, 
				params.priority
			);
			token.addResponder(responder);
		}
	}
}
