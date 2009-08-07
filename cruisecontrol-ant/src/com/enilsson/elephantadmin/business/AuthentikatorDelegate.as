package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.LoginVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	
	public class AuthentikatorDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function AuthentikatorDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function login( loginVO:LoginVO ):void
		{
			if(_model.debug){ Logger.info('LoginVO', ObjectUtil.toString(loginVO)); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('authentikator');

			var token:AsyncToken = service.list_instances(loginVO.email, loginVO.pwd, loginVO.captcha);
			token.addResponder(this.responder);			
		}

		public function forgot( loginVO:LoginVO , instanceID:int):void
		{
			if(_model.debug){ Logger.info('LoginVO', ObjectUtil.toString(loginVO)); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikator');
			
			var token:AsyncToken = service.forgot_password( loginVO.email, instanceID );
			token.addResponder(this.responder);			
		}
		
		public function randomGateway( instanceID:uint ):void
		{
			if(_model.debug){ Logger.info('Random Gateway', ObjectUtil.toString(instanceID)); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikator');
			
			var token:AsyncToken = service.random_gateway( instanceID );
			token.addResponder(this.responder);
		}
		
		public function wheel( userID:Number ):void
		{
			if(_model.debug){ Logger.info('Authentikator Wheel', ObjectUtil.toString(userID)); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorPassword');
			
			var token:AsyncToken = service.wheel( userID );
			token.addResponder(this.responder);
		}		

		public function changePassword( oldPwd:String, newPwd:String ):void
		{
			if(_model.debug){ Logger.info('Authentikator change password', oldPwd, newPwd); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorPassword');
			
			var token:AsyncToken = service.change_password( oldPwd, newPwd );
			token.addResponder(this.responder);
		}

		public function enableUser( userID:Number ):void
		{
			if(_model.debug){ Logger.info('Authentikator enable User', ObjectUtil.toString(userID)); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.enable_user( userID );
			token.addResponder(this.responder);
		}

		public function disableUser( userID:Number ):void
		{
			if(_model.debug){ Logger.info('Authentikator disable User', ObjectUtil.toString(userID)); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.disable_user( userID );
			token.addResponder(this.responder);
		}

		public function getActiveUsers():void
		{
			if(_model.debug){ Logger.info('Authentikator get Active Users'); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.get_online_users();
			token.addResponder(this.responder);
		}


		public function getUserEmail( userID:int ):void
		{
			if(_model.debug){ Logger.info('Authentikator get User Email'); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.get_user_email( userID );
			token.addResponder(this.responder);
		}
	}
}