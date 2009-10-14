package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
	import com.enilsson.elephanttrakker.business.SessionDelegate;
	import com.enilsson.elephanttrakker.events.modules.message_center.MessageCenterEvent;
	import com.enilsson.elephanttrakker.events.session.*;
	import com.enilsson.elephanttrakker.models.*;
	import com.enilsson.elephanttrakker.models.viewclasses.*;
	import com.enilsson.elephanttrakker.vo.SessionVO;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.utils.Base64Encoder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class SessionCommand extends SequenceCommand implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		

		/**
		  * Execute() method required by the ICommand interface.
		  * Allows events to be delegated to a command instance for processing
		  */
		override public function execute(event:CairngormEvent):void
		{
			switch(event.type)
			{
				case UpdateSessionEvent.EVENT_UPDATE_SESSION :
					updateSession(event as UpdateSessionEvent);
				break;
				case PingEvent.EVENT_PING :
					ping(event as PingEvent);
				break;
				case EndSessionEvent.EVENT_END_SESSION :
					endSession(event as EndSessionEvent);
				break;
				case EndSessionEvent.EVENT_END_PROXYSESSION :
					endProxySession(event as EndSessionEvent);
				break;
				case SessionEvent.GET_SESSION_INFO :
					getSessionInfo(event as SessionEvent);
				break;
				case SessionFailEvent.EVENT_SESSION_FAIL :
					sessionFail(event as SessionFailEvent);
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
		private function updateSession(event:UpdateSessionEvent):void
		{	
			var handlers : IResponder = new mx.rpc.Responder(onResults_sessionCheck, onFault_sessionCheck);
			
			getDelegate(handlers).getSessionInfo();
		}
		
		private function onResults_sessionCheck(data:Object):void 
		{
			if(_model.debug) Logger.info('Session Success', ObjectUtil.toString(data));

			// apply the session data to the VO
			_model.session = new SessionVO( data.result );	
			// set the items per page
			_model.itemsPerPage = Number(_model.session.data._itemsperpage);
			// save the PHP sess id
			_model.sess_id = data.result.php_session_id;			
			// intialise the first view module
			_model.runInit = true;
			
			if(_model.debug) Logger.info('SessionVO', ObjectUtil.toString(_model.session));
		}
			
		private function onFault_sessionCheck(data:Object):void
		{
			if(_model.debug) Logger.info('Session Fault');
		}	
		
		
		/**
		 * Ping the server to check the user is still logged in
		 */
		private function ping(event:PingEvent):void
		{
			// dont do anything if there is no session information (ie it has not been initialised )
			if(!_model.session)
				return;
			
			var handlers:IResponder = new mx.rpc.Responder(onResult_ping, onFault_ping);
			getDelegate(handlers).ping();
		}	
		
		private function onResult_ping(data:Object):void
		{
			if(_model.debug) Logger.info('Ping Success', ObjectUtil.toString(data.result));

			if(parseInt(data.result) == 0 && _model.session)
			{	
				_model.reset();
				
				Alert.show(	
					'Your ' + _model.appName + ' session has expired, please login to continue!',
					'Session timeout', 
					0, 
					null,
					null,
					_model.icons.alert
				);
				
				return;
			}
			
			this.nextEvent = new MessageCenterEvent( MessageCenterEvent.MESSAGES_GET_UNREAD );
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		private function onFault_ping(data:Object):void
		{
			if(_model.debug) Logger.info('Ping Fail', ObjectUtil.toString(data));
			
			_model
			
			if(_model.session)
			{
				_model.reset();
			
				Alert.show(	
					'Your ' + _model.appName + ' session has expired, please login to continue!',
					'Session timeout', 
					0, 
					null,
					null,
					_model.icons.alert
				);
			}			
		}
		
		
		/**
		 * Log the user out
		 */
		private function endSession(event:EndSessionEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_endSession, onFault_endSession);
			getDelegate(handlers).logout();
		}	
			
		private function onResult_endSession(data:Object):void
		{
			if(_model.debug) Logger.info('End Session Success', ObjectUtil.toString(data.result));
	
			// reset model data
			_model.reset();
		}
		
		private function onFault_endSession(data:Object):void
		{
			if(_model.debug) Logger.info('End Session Fail', ObjectUtil.toString(data.fault));
					
			// reset model data
			_model.reset();
		}	
		
		
		/**
		 * Log the user out of proxy session
		 */
		private function endProxySession(event:EndSessionEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_endProxySession, onFault_endProxySession);
			getDelegate(handlers).logout();
		}	
			
		private function onResult_endProxySession(data:Object):void
		{
			if(_model.debug) Logger.info('endProxySession Success', ObjectUtil.toString(data.result));
			
			// encode the gateway url
			var base64encode:Base64Encoder = new Base64Encoder();
			base64encode.encode(_model.gatewayURL);
			// build the admin link from the model reference and the encoded url and redirect
			SWFAddress.href( _model.adminUI + "/#/redirect/" + base64encode.toString() );
		}
		
		private function onFault_endProxySession(data:Object):void
		{
			if(_model.debug) Logger.info('endProxySession Fail', ObjectUtil.toString(data.fault));
				
			var base64encode:Base64Encoder = new Base64Encoder();
			base64encode.encode(_model.gatewayURL);
			SWFAddress.href( _model.adminUI + "/#/redirect/" + base64encode.toString() );
		}	
		
		/**
		 * Get Session Info
		 */
		private function getSessionInfo(event:SessionEvent):void
		{	
			var handlers : IResponder = new mx.rpc.Responder(onResults_getSessionInfo, onFault_getSessionInfo);
			getDelegate(handlers).getSessionInfo();
		}

		private function onResults_getSessionInfo(data:Object):void 
		{
			if(_model.debug) Logger.info('get Session Success', ObjectUtil.toString(data.result));
			
			// apply the session data to the VO
			_model.session = new SessionVO( data.result );	
			// set the items per page
			_model.itemsPerPage = Number(_model.session.data._itemsperpage);
			// save the PHP sess id
			_model.sess_id = data.result.php_session_id;			
		}	

		private function onFault_getSessionInfo(data:Object):void
		{
			if(_model.debug) Logger.info('getSessionInfo Failed');
		}	



		/**
		 * Handler for the session fail event
		 */
		private function sessionFail(event:SessionFailEvent):void
		{
			//sessionFailHandler( event.faultCode );
		}

	}
}