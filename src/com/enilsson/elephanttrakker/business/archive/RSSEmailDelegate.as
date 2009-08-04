package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class RSSEmailDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function RSSEmailDelegate(responder:IResponder)
		{
			this.responder = responder;
		}

		public function sendEmails(params:Object):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_email( params.emails, params.subject, params.message, null );			
			token.addResponder(responder);
		}



	}
}