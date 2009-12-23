package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
	import com.enilsson.elephantadmin.business.AuthentikatorDelegate;
	import com.enilsson.elephantadmin.business.SessionDelegate;
	import com.enilsson.elephantadmin.events.session.*;
	import com.enilsson.elephantadmin.models.*;
	import com.enilsson.elephantadmin.vo.SessionVO;
	import com.enilsson.utils.eNilssonUtils;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.Base64Encoder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class SessionCommand implements ICommand
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		/**
		  * Execute() method required by the ICommand interface.
		  * Allows events to be delegated to a command instance for processing
		  */
		public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('Session Event', event.type);
			
			switch(event.type)
			{
				case SessionEvent.GET_SESSION_INFO :
					sessionCheck(event as SessionEvent);
				break;
				case PingEvent.EVENT_PING :
					ping(event as PingEvent);
				break;
				case SessionEvent.END_SESSION :
					endSession(event as SessionEvent);
				break;
				case SessionEvent.CHECK_SUPERUSER :
					checkSuperUser(event as SessionEvent);
				break;
				case SessionFailEvent.EVENT_SESSION_FAIL :
					sessionFail(event as SessionFailEvent);
				break;
				case SessionEvent.SESSION_WHEEL :
					sessionWheel(event as SessionEvent);
				break;
			}
		}


		/**
		  * Convenience method to create instance of CatalogDelegate
		  * @param handler Handlers for CatalogDelegate asynchronous notifications
		  */
		private function getDelegate(handler:IResponder):SessionDelegate
		{
			return (new SessionDelegate(handler));
		}


		/**
		 * Session Check method
		 */
		private function sessionCheck(event:SessionEvent):void
		{	
			var handlers : IResponder = new mx.rpc.Responder(onResults_sessionCheck, onFault_sessionCheck);
			
			getDelegate(handlers).sessionInfo();
		}

		private function onResults_sessionCheck(data:Object):void 
		{
			if(_model.debug) Logger.info('Session Success', ObjectUtil.toString(data));

			_model.session = new SessionVO( data.result );			
			_model.itemsPerPage = Number(_model.session.data._itemsperpage);
			
			if(_model.debug) Logger.info('SessionVO', ObjectUtil.toString(_model.session));
		}	

		private function onFault_sessionCheck(data:Object):void
		{
			if(_model.debug) Logger.info('Session Fault', ObjectUtil.toString(data));
			
			sessionFailHandler( data.faultCode );
		}	
		
		
		/**
		 * Ping the server to check the user is still logged in
		 */
		private function ping(event:PingEvent):void
		{
			// dont do anything if there is no session information (ie it has not been initialised )
			if(!_model.session)
			{
				if(_model.debug) Logger.info("not calling ping, session is null");
				return;
			}
			
			if(_model.debug) Logger.info("calling ping on delegate");
			
			var handlers:IResponder = new mx.rpc.Responder(onResult_ping, onFault_ping);
			getDelegate(handlers).ping();
		}
		
		private function onResult_ping(event:ResultEvent):void
		{
			if(_model.debug) Logger.info('Ping Success', ObjectUtil.toString(event.result));
			
			if(parseInt(event.result.toString()) == 0 && _model.session)
			{	
				_model.reset();
				
				Alert.show(	
					'Your ' + _model.appName + ' session has expired, please login to continue!',
					'Session timeout',
					0, 
					null,
					null,
					Icons.ALERT
				);
			}			
		}

		private function onFault_ping(event:FaultEvent):void {
			event.preventDefault();
			event.stopImmediatePropagation();
			
			if(_model.debug) Logger.info('Ping Fail', ObjectUtil.toString(event));
		}
				
				
		/**
		 * Log the user out
		 */
		private function endSession(event:SessionEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_endSession, onFault_endSession);
			getDelegate(handlers).logout();
		}
		
		private function onResult_endSession(data:Object):void
		{
			if(_model.debug) Logger.info('End Session Success', ObjectUtil.toString(data.result));
			
			// clear all the session details
			_model.reset();
		}

		private function onFault_endSession(data:Object):void
		{
			if(_model.debug) Logger.info('End Session Fail', ObjectUtil.toString(data.fault));

			// clear all the session details
			_model.reset();
		}
		
		
		/**
		 * Check the user is a listed super user
		 */
		private function checkSuperUser(event:SessionEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_checkSuperUser, onFault_checkSuperUser);
			
			getDelegate(handlers).sessionInfo();
		}
		
		private function onResult_checkSuperUser(data:Object):void
		{
			if(_model.debug) Logger.info('checkSuperUser Success', ObjectUtil.toString(data.result));
			
			// grab the user session and save it to the model
			_model.session = new SessionVO( data.result );
			
			// set the users level
			if(data.result.acl.system_power == '1') _model.userLevel = 'power';
			if(data.result.acl.system_super == '1') _model.userLevel = 'super';
			
			// if the user is authenticated and of the appropriate level
			if(data.result.acl.system_power || data.result.acl.system_super)
			{			
				if(_model.debug) Logger.info('User has sufficient rights');
				
				// change the view screen to Main
				_model.screenState = EAModelLocator.MAIN_SCREEN;
				// update the browser fragments
				SWFAddress.setValue(_model.viewStateList[0]);
				SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[0]);			
				// save the gatewayURL to a cookie for use if the app is refreshed
				eNilssonUtils.clearCookie('gatewayURL');
			 	eNilssonUtils.writeCookie('gatewayURL', _model.gatewayURL);
			}
			else
			{
				if(_model.debug) Logger.info('User does NOT have sufficient rights');
				
				_model.login.loginErrorMessage = 'You do not have sufficient permission to proceed!';
				_model.login.loginFormState = 'ClearPassword';
				_model.login.loginErrorVisible = true;
				_model.login.loginErrorStyle = 'errorBox';
			}
		}
		
		private function onFault_checkSuperUser(data:Object):void
		{
			if(_model.debug){ Logger.info('checkSuperUser Fail', ObjectUtil.toString(data.fault)); }
				
			_model.login.loginErrorMessage = 'Internet connection error, please check before trying again!';
			_model.login.loginFormState = 'ClearPassword';
			_model.login.loginErrorVisible = true;
			_model.login.loginErrorStyle = 'errorBox';
			_model.login.loginPwd = "";
		}	


		/**
		 * Convert the users session to proxy for another so the user can login to the client app as that user
		 */
		private function sessionWheel(event:SessionEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_sessionWheel, onFault_sessionWheel);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);
			
			delegate.wheel( event.params.userID );
		}
		private function onResult_sessionWheel(data:Object):void
		{
			if(_model.debug) Logger.info('sessionWheel Success', ObjectUtil.toString(data.result));
			
			var base64encode:Base64Encoder = new Base64Encoder();
			base64encode.encode(_model.gatewayURL);
			
			SWFAddress.href( _model.clientUI + "/#/redirect/" + base64encode.toString() );
		}
		private function onFault_sessionWheel(data:Object):void
		{
			if(_model.debug) Logger.info('sessionWheel Fail', ObjectUtil.toString(data.fault));

			Alert.show('There was a problem launching this proxy login', 'Login error');
		}	

		
		
		/**
		 * Handler for the session fail event
		 */
		private function sessionFail(event:SessionFailEvent):void
		{
			sessionFailHandler( event.faultCode );
		}

		/**
		 * Event handler for when a session fails, so we dont have to repeat the code for every instance
		 */		
		private function sessionFailHandler( faultCode:String ):void
		{			
			if(_model.debug) Logger.info('SessionFailHandler', ObjectUtil.toString(faultCode));
			
			_model.reset();
			
			if( _model.session && faultCode == "AMFPHP_AUTHENTICATE_ERROR" )
			{
				Alert.show(	
					'Your ' + _model.appName + ' session has expired, please login to continue!',
					'Session timeout', 
					0, 
					null,
					null,
					Icons.ALERT
				);
			}
		}
	}
}