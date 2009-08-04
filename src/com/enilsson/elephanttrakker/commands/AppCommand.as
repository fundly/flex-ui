package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.events.URLChangeEvent;
	import com.enilsson.elephanttrakker.events.session.SessionCheckEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.utils.ByteArray;
	
	import mx.core.Application;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class AppCommand extends SequenceCommand implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
	
		override public function execute(event:CairngormEvent):void
		{
			if( redirect() || readGatewayUrl() )
			{	
				navigateToFirstModule();	
								
				this.nextEvent = new SessionCheckEvent();
				this.executeNextCommand();
				this.nextEvent = null;
			}
			else
				_model.screenState = ETModelLocator.LOGIN_SCREEN;

			// show the main container once it has been decided what to show
			_model.screenVStack = true;							
/* 
			
			var gURL:String;

			// if there is no fragment or it points to the login page, redirect the view state to LOGIN
			if(_model.browserManager.fragment == '' || _model.browserManager.fragment == 'login')
				_model.screenState = ETModelLocator.LOGIN_SCREEN;
						
			// if the fragment points to redirect then check the session
			else if(_model.browserManager.fragment.indexOf('redirect') == 0)
			{
				// decode the gateway url from the fragment
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(_model.browserManager.fragment.replace('redirect/',''));
				var urlByteArray:ByteArray = base64Dec.toByteArray();
				gURL = urlByteArray.toString();
				if(_model.debug) Logger.info('Redirect gURL', gURL);
				
				// use the gateway url to apply to the model and redirect to the first module
				saveGatewayURL(gURL);	
				
				// set the screen state to the main page and show the container
				_model.screenState = ETModelLocator.MAIN_SCREEN;
				
				// run the main initialisation command
				this.nextEvent = new SessionCheckEvent();
				this.executeNextCommand();
				this.nextEvent = null;
			}			
			// if the fragment points elsewhere redirect to the main viewstate and load the appropriate page
			else
			{
				// get the gatewayURL from the cookie if need be
				gURL = eNilssonUtils.readCookie('gatewayURL');
				// if there is no gatewayURL go to the login page
				if(gURL == '')
					_model.screenState = ETModelLocator.LOGIN_SCREEN;
				else
				{	
					// set the screen state to the main page and show the container
					_model.screenState = ETModelLocator.MAIN_SCREEN;
					
					// save the gateway information to the LSO and to the model
					saveGatewayURL(gURL);	
					
					// look to see if they attempted to go to another module
					var redirectModule:String = eNilssonUtils.flashCookie('module_fwd');
					
					// list the redirect module as the goto destination					
					if(redirectModule != null)
						_model.firstModule = _model.viewStateList.indexOf(redirectModule);
					
					// if no redirect then goto whatever is in the browser fragment (or the first module if nothing matches)
					else
					{
						_model.firstModule = _model.viewStateList.indexOf(_model.browserManager.fragment) < 0 ? 
							0 : 
							_model.viewStateList.indexOf(_model.browserManager.fragment);
					}
					
					if(_model.debug) Logger.info('Skip Login go to module', redirectModule, _model.browserManager.fragment, _model.firstModule);					
					
					// run the main initialisation command
					this.nextEvent = new SessionCheckEvent();
					this.executeNextCommand();
					this.nextEvent = null;
				}
			}
			
			// show the main container once it has been decided what to show
			_model.screenVStack = true;							
 */		}
		
		/**
		 * Checks if a redirect is necessary and redirects the user to the 
		 * related part of the application
		 * 
		 * @return	A Boolean indicating if a redirect happened or not
		 */
		private function redirect() : Boolean
		{
			if(_model.debug) Logger.info('Redirect Check', _model.browserManager.fragment);
			
			if(_model.browserManager.fragment == '' || _model.browserManager.fragment == 'login')
				return false;
			
			// if the fragment points to redirect then check the session
			else if(_model.browserManager.fragment.indexOf('redirect') == 0)
			{
				// decode the gateway url from the fragment
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(_model.browserManager.fragment.replace('redirect/',''));
				
				var urlByteArray:ByteArray = base64Dec.toByteArray();
				var gUrl : String = urlByteArray.toString();
				
				if(_model.debug) Logger.info('Redirect gURL', gUrl);
				
				// use the gateway url to apply to the model and show the container
				saveGatewayURL(gUrl);
				
				return true;				
			}
			
			return false;
		}
	
		/**
		 * Reads the gatewayURL from the LSO
		 */
		private function readGatewayUrl() : Boolean
		{
			// only allow this feature on production if the requested fragment is something other than login
			if( Application.application.parameters.siteURL ) 
				if(_model.browserManager.fragment == '' || _model.browserManager.fragment == 'login')
					return false;
			
			// get the gURL from the cookie
			var gURL : String  = eNilssonUtils.readCookie('gatewayURL');
			
			// if it is blank do nothing
			if( gURL == null ) gURL = '';
			
			// if there is one save the gateway information to the LSO and to the model
			if( gURL != '' )
			{					
				saveGatewayURL(gURL);
				return true;	
			}
			
			return false;
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

		/**
		 * Navigates to the first available module or another module if listed
		 */
		private function navigateToFirstModule() : void
		{
			// set the screen state to the main page and show the container
			_model.screenState = ETModelLocator.MAIN_SCREEN;
			
			// look to see if they attempted to go to another module
			var redirectModule:String = eNilssonUtils.flashCookie('module_fwd');
			
			// list the redirect module as the goto destination					
			if(redirectModule != null)
				_model.firstModule = _model.viewStateList.indexOf(redirectModule);
			
			// if no redirect then goto whatever is in the browser fragment (or the first module if nothing matches)
			else
			{
				_model.firstModule = _model.viewStateList.indexOf(_model.browserManager.fragment) < 0 ? 
					0 : 
					_model.viewStateList.indexOf(_model.browserManager.fragment);
			}
			
			if(_model.debug) Logger.info('Skip Login go to module', redirectModule, _model.browserManager.fragment, _model.firstModule);					
		}


	}
}