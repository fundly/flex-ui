package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.AuthentikatorDelegate;
	import com.enilsson.elephantadmin.events.session.SessionEvent;
	import com.enilsson.elephantadmin.events.login.RegisterGatewayEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.utils.eNilssonUtils;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class RegisterGatewayCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function RegisterGatewayCommand()
		{
		}
		
		override public function execute(event:CairngormEvent):void
		{
			var e:RegisterGatewayEvent = event as RegisterGatewayEvent;
			
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(this);
			delegate.randomGateway( e.instanceID );			
		}
		
		public function result(event:Object):void
		{
			if(_model.debug) Logger.info('Success Random Gateway Event', ObjectUtil.toString(event.result));
			
			// save the gatewayURL to a cookie for use if the app is refreshed
			saveGatewayURL(event.result.gateway);
			
			_model.isLoggingIn = true;	
			
			this.nextEvent = new SessionEvent( SessionEvent.INIT_SESSION_CHECK );
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		public function fault(event:Object):void
		{
			if(_model.debug) Logger.info('Fault Random Gateway Event', ObjectUtil.toString(event));

			_model.login.loginErrorMessage = 'Internet connection error, please check before trying again!';
			_model.login.loginErrorVisible = true;			
			_model.login.loginErrorStyle = "errorBox";	
		}

		/**
		 * Set the gatewayURL and save a copy to the cookie
		 */
		private function saveGatewayURL(gURL:String):void
		{
		 	// some debugging info
		 	if(_model.debug) Logger.info('gURL', gURL);		
		 	// save the url to the as an application variable in the model 	
		 	_model.gatewayURL = gURL; 	
		 	// save the url to a cookie so if the user refreshes the app their session can be recovered
		 	eNilssonUtils.clearCookie('gatewayURL');
		 	eNilssonUtils.writeCookie('gatewayURL',gURL);
		 	// resolve the gatewayURL to its base for use with some functions (like Excel downloads)
			if(gURL != null)
			{
				var gSegs:Array = _model.gatewayURL.split('/');
				_model.gatewayBaseURL = gSegs[0] + '//' + gSegs[2] + '/';
			}
		}
	}
}