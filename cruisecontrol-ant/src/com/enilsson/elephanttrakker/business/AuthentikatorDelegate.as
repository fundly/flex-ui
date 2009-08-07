package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.LoginVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	
	public class AuthentikatorDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function AuthentikatorDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('authentikator');
		}
		
		public function login(loginVO:LoginVO):void
		{
			if(_model.debug){ Logger.info('LoginVO', ObjectUtil.toString(loginVO)); }
			
			var token:AsyncToken = service.list_instances(loginVO.email, loginVO.pwd, loginVO.captcha);
			token.addResponder(this.responder);			
		}

		public function forgot( loginVO:LoginVO, instanceID:int ):void
		{
			if(_model.debug) Logger.info('LoginVO', ObjectUtil.toString(loginVO));
			
			var token:AsyncToken = service.forgot_password( loginVO.email, instanceID );
			token.addResponder(this.responder);			
		}
		
		public function randomGateway(instanceID:uint):void
		{
			if(_model.debug){ Logger.info('Random Gateway', ObjectUtil.toString(instanceID)); }
			
			var token:AsyncToken = service.random_gateway(instanceID);
			token.addResponder(this.responder);
		}

	}
}