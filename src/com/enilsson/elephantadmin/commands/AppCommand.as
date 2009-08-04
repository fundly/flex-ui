package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.events.URLChangeEvent;
	import com.enilsson.elephantadmin.events.session.SessionEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.utils.ByteArray;
	
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.utils.Base64Decoder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class AppCommand extends SequenceCommand implements ICommand
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
	
		override public function execute(event:CairngormEvent):void
		{
			var gURL:String;
			
			// if there is a fragment redirect the app
			if(_model.browserManager.fragment == '' || _model.browserManager.fragment == 'login')
				_model.screenState = EAModelLocator.LOGIN_SCREEN;
			
			// if the fragment points to redirect then check the session
			else if(_model.browserManager.fragment.indexOf('redirect') == 0)
			{
				// decode the gateway url from the fragment
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(_model.browserManager.fragment.replace('redirect/',''));
				var urlByteArray:ByteArray = base64Dec.toByteArray();
				gURL = urlByteArray.toString();
				if(_model.debug) Logger.info('Redirect gURL', gURL);
				
				// use the gateway url to apply to the model and show the container
				saveGatewayURL(gURL);	
				_model.screenState = EAModelLocator.MAIN_SCREEN;				
				
				// run the main initialisation command
				this.nextEvent = new SessionEvent( SessionEvent.INIT_SESSION_CHECK );
				this.executeNextCommand();
				this.nextEvent = null;
			}			
			else
			{
				// get the gatewayURL from the cookie if need be
				gURL = eNilssonUtils.readCookie('gatewayURL');
				
				// if there is no gatewayURL go to the login page
				if(gURL == '')
					_model.screenState = EAModelLocator.LOGIN_SCREEN;
				else
				{				
					// set the screen state to the main page and show the container
					_model.screenState = EAModelLocator.MAIN_SCREEN;
					
					// save the gateway information to the LSO and to the model
					saveGatewayURL(gURL);	
					
					// look to see if they attempted to go to another module
					var redirectModule:String = eNilssonUtils.flashCookie('module_fwd');
					
					// list the redirect module as the go to destination					
					if(redirectModule != null)
						_model.firstModule = _model.viewStateList.indexOf(redirectModule);
					
					// if no redirect then go to whatever is in the browser fragment (or the first module if nothing matches)
					else
					{
						_model.browserFragments = _model.browserManager.fragment.split('/');
						var fragment:String = _model.browserFragments[0];
						
						_model.firstModule = _model.viewStateList.indexOf(fragment) < 0 ? 
							0 : 
							_model.viewStateList.indexOf(fragment);
					}
					
					if(_model.debug) Logger.info('Skip Login go to module', redirectModule, fragment, _model.firstModule);					
					
					// run the main initialisation command
					this.nextEvent = new SessionEvent( SessionEvent.INIT_SESSION_CHECK );
					this.executeNextCommand();
					this.nextEvent = null;
				}
			}
			
			// show the first view stack once it has been decided what to show
			_model.screenVStack = true;
		}
		
		
		/**
		 * Set the gatewayURL and save a copy to the cookie
		 */
		private function saveGatewayURL(gURL:String):void
		{
		 	// some debugging info
		 	if(_model.debug) Logger.info('gURL', gURL);	
		 		
		 	// save the url to the an application variable		 	
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