package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SessionDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function SessionDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function sessionInfo():void
		{
			if(_model.debug){ Logger.info('Get TrUser Session Info'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('tr_users', null, null, null, null, 'N');
			token.addResponder(responder);
		}

		public function getSessionInfo():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorAuth');

			var offset:int = (new Date().getTimezoneOffset()) * 60;
			var token:AsyncToken = service.get_session_info(offset);
			token.addResponder(responder);
		}
		
		public function ping():void
		{
			if(_model.debug){ Logger.info('Ping Session'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSys');
			
			var token:AsyncToken = service.ping();
			token.addResponder(responder);
		}
		
		public function logout():void
		{
			if(_model.debug){ Logger.info('End Session - Logout'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorAuth');
			
			var token:AsyncToken = service.end_session();
			token.addResponder(responder);
		}

		public function updateSession(userID:Number):void
		{
			if(_model.debug){ Logger.info('Update Session Info'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('tr_users', userID);
			token.addResponder(responder);
		}

	}
}