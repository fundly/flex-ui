package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SessionDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function SessionDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function sessionInfo():void
		{
			if(_model.debug){ Logger.info('Get Session Info'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorAuth');
			
			var offset:int = (new Date().getTimezoneOffset()) * 60;
			var token:AsyncToken = service.get_session_info(offset, true);
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

	}
}