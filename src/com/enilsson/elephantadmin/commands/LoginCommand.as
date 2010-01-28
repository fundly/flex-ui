package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.AuthentikatorDelegate;
	import com.enilsson.elephantadmin.events.login.*;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import flash.utils.ByteArray;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.Base64Decoder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class LoginCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function LoginCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('Login Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case LoginEvent.EVENT_LOGIN :
					login(event as LoginEvent);
				break;
				case LoginEvent.EVENT_LOGIN_FORGOT :
					forgot(event as LoginEvent);
				break;
			}
		}


		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
	
		/**
		 * Login procedures
		 */			
		private function login(event:LoginEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_login, onFault_login);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);
			
			_model.login.loginProcessing = true;
				
			delegate.login( event.loginAttempt );			
		}	
			
		private function onResults_login(event:Object):void 
		{
			if(_model.debug){ Logger.info('Success Login Event', ObjectUtil.toString(event.result)); }
	
			// if there is an error
			var state:int = parseInt(event.result.state);
			if ((state < 0)) 
			{
				// act on the various error states
				switch(state)
				{
					case -2 :
						_model.login.loginErrorMessage = 'Invalid username or password';
						_model.login.captchaData = createCaptcha(event.result.captcha);
						_model.login.loginFormState = 'Captcha';						
					break;					
					case -3 :
						if(_model.login.loginFormState == 'Captcha')
							_model.login.loginErrorMessage = 'Captcha Incorrect';
						else
							_model.login.loginErrorMessage = 'Your account is locked. Please answer the captcha to proceed.';
							
						_model.login.captchaData = createCaptcha(event.result.captcha);
						_model.login.loginFormState = 'Captcha';						
					break
					case -4 :
						_model.login.loginErrorMessage = 'This service is not available in your country';
					break;
					case -5 :
						_model.login.loginErrorMessage = 'Your IP has been blacklisted, please contact support!';
						_model.login.loginFormState = 'Default';
						_model.login.loginPwd = "";
					break;
					case -6 :
						_model.login.loginErrorMessage = 'Your account has been disabled, please contact support!';
						_model.login.loginFormState = 'Default';
						_model.login.loginPwd = "";
					break;
					default :
						_model.login.loginErrorMessage = 'Invalid email or password';
						_model.login.loginPwd = "";
					break;							
				}
				
				_model.login.loginProcessing = false;
				_model.login.loginErrorVisible = true;
				
				if(_model.debug) Logger.info('Model Login', _model.login);
			}
			else // if there is no problem 
			{
				if(_model.debug){ Logger.info('User authenticated!'); }
				// clear the pwd
				_model.login.loginPwd = '';
				// check to see if the user is actually an ElephantTrakker user
				var flag:Boolean = false;
				for( var inst:int=0; inst<event.result.length; inst++)
				{
					if(event.result[inst].id == _model.appInstanceID)
						flag = true;
				}
				
				if(flag)
				{
					this.nextEvent = new RegisterGatewayEvent(_model.appInstanceID);
					this.executeNextCommand();
					this.nextEvent = null;
				} 
				else 
				{
					if(_model.debug) Logger.info('User not registered with this app!');
					
					_model.login.loginProcessing = false;
					_model.login.loginErrorMessage = 'You are not a registered ' + _model.appName + ' user!';
					_model.login.loginErrorVisible = true;							
				}
			}			
		}
		public function onFault_login(event:FaultEvent):void
		{
			// avoid event handling by the global fault handler
			event.preventDefault();
			event.stopImmediatePropagation();
			
			if(_model.debug) Logger.info('Fault Login Event', ObjectUtil.toString(event));
			
			_model.login.loginProcessing = false;
			_model.login.loginErrorMessage = 'Internet connection error, please check before trying again!';
			_model.login.loginErrorVisible = true;			
		}


		/**
		 * Login procedures
		 */			
		private function forgot(event:LoginEvent):void
		{

			var handlers:IResponder = new mx.rpc.Responder(onResults_forgot, onFault_forgot);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.forgot( event.loginAttempt, _model.appInstanceID );
		}
		private function onResults_forgot(event:Object):void 
		{
			if(_model.debug) Logger.info('Forget details Event Success', ObjectUtil.toString(event.result));
	
			if (event.result) 
			{
				_model.login.forgotErrorMessage = 'An email has been successfully sent to your account.';
				_model.login.forgotErrorVisible = true;		
				_model.login.forgotErrorStyle = "successBox";	
			} 
			else 
			{
				_model.login.forgotErrorMessage = 'Internet connection error, please check before trying again!';
				_model.login.forgotErrorVisible = true;			
				_model.login.forgotErrorStyle = "errorBox";	
			}	
		}
		public function onFault_forgot(event:Object):void
		{
			if(_model.debug) Logger.info('Forget details Event', ObjectUtil.toString(event));
			
			_model.login.forgotErrorMessage = 'Internet connection error, please check before trying again!';
			_model.login.forgotErrorVisible = true;			
		}



		/**
		 * Display and generate the captcha image from the base64 data
		 */			
		private function createCaptcha(code:String):ByteArray 
		{
		    if(_model.debug){ Logger.info('generating captcha'); }
		    
		    var base64Dec:Base64Decoder = new Base64Decoder();
		    base64Dec.decode(code);
		
		    return base64Dec.toByteArray();
		}


	}
}