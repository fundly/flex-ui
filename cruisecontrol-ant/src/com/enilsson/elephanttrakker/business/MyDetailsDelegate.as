package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class MyDetailsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyDetailsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}

		public function getDetails( ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree( 'tr_users' );
			token.addResponder(responder);
		}
		
		public function upsertDetails( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.upsert('tr_users', params);
			token.addResponder(responder);
		}
		
		public function changePWD(new_password:String, old_password:String):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorAuthentikator');
			
			var token:AsyncToken = service.change_password(old_password, new_password);
			token.addResponder(responder);
		}	
		
		public function changeEmail(email:String, password:String):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorAuthentikator');
			
			var token:AsyncToken = service.change_email(password,email);
			token.addResponder(responder);
		}		
	}
}