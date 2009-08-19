package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.events.GetVersionEvent;
	import com.enilsson.elephantadmin.events.session.SessionEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.utils.URLParser;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.utils.Base64Decoder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class InitAppCommand extends SequenceCommand implements ICommand
	{
		private static var _executed : Boolean;
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		override public function execute(event:CairngormEvent):void
		{
			// make sure the InitAppCommand is only executed once
			if( !_executed )
			{
				var sessionEvent : SessionEvent;
				var versionEvent : GetVersionEvent = new GetVersionEvent();
				
				// set the site parameters from the flash vars if there are any
				setSiteURL();
				
				// initialise the browser manager
				initBrowserManager();
				
				if( redirect() || readGatewayUrl() )
				{	
					navigateToFirstModule();					
					sessionEvent = new SessionEvent( SessionEvent.INIT_SESSION_CHECK );
					versionEvent.nextEvent = sessionEvent;
				}
				else
				{
					_model.screenState = EAModelLocator.LOGIN_SCREEN;
					_model.mainScreenVisible = true;
				}
				
				
				// attach a listener to the browser manager
				addBrowserManagerListener();
				
				// register and execute the next command in sequence
				nextEvent = versionEvent;				
				executeNextCommand();
				nextEvent = null;
				
				_executed = true;
			}
		}


		/**
		 * Set the application parameters
		 */		
		private function setSiteURL():void
		{
			// get the parameters from the flash vars if in production
			if(Application.application.parameters.siteURL)
			{
				_model.authURL 			= Application.application.parameters.authURL;
				_model.siteURL 			= Application.application.parameters.siteURL;
				_model.baseURL 			= Application.application.parameters.baseURL;
				_model.clientUI 		= Application.application.parameters.clientUI;
				_model.appName 			= Application.application.parameters.siteTitle;
				_model.appLogo			= Application.application.parameters.appLogo;
				_model.appInstanceID 	= Application.application.parameters.instanceID;
				_model.s3URL			= Application.application.parameters.s3URL;
				_model.orgLogo			= Application.application.parameters.orgLogo;
				_model.orgName			= Application.application.parameters.orgName;
				_model.orgURL			= Application.application.parameters.orgURL;
				_model.versionXmlUrl	= Application.application.parameters.versionXmlURL;
				
				_model.debug			= true;
			} 
			else
			{
				var req:URLRequest = new URLRequest("sandbox_config.xml");
				var loader:URLLoader = new URLLoader(req);
				loader.addEventListener(Event.COMPLETE,readSandboxConfig);
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void
				{
					throw new IOError("please create a \"sandbox_config.xml\" for local sandbox testing!");
					Alert.show("please create a \"sandbox_config.xml\" for local sandbox testing!","File Error");
				});
			}
		}


		/**
		 * Read and set a config file for local testing. This is so we dont have to add these changes to SVN
		 */
		private function readSandboxConfig (event:Event):void
		{
			var xml:XML = new XML(event.currentTarget.data);

    		_model.authURL 			= xml.authURL;
    		_model.appInstanceID 	= xml.appInstanceID;
    		_model.appName 			= xml.appName;
    		_model.appLogo 			= xml.appLogo;
    		_model.orgName 			= xml.orgName;
    		_model.orgLogo 			= xml.orgLogo;
    		_model.orgURL 			= xml.orgURL;
    		
    		_model.debug			= xml.debug == 'true' ? true : false;
		}
		
		
		/**
		 * Initialises the BrowserManager
		 */
		private function initBrowserManager() : void
		{
			// Create our Browser Manager
			_model.browserManager = BrowserManager.getInstance();
			
			// Display the title of our current (default) page
			_model.browserManager.init("", _model.appName);
		}
		
		
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
				saveGatewayUrl(gUrl);
				
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
				saveGatewayUrl(gURL);
				return true;	
			}
			
			return false;
		}
		
		/**
		 * Set the gatewayURL and save a copy to the LSO
		 */
		private function saveGatewayUrl(gURL:String):void
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
		 * Adds a listener to the BrowserManager to listen for URL changes.
		 */
		private function addBrowserManagerListener() : void
		{
			_model.browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, URLParser.parse);			
		}
		
		
		/**
		 * Navigates to the first available module or another module if listed
		 */
		private function navigateToFirstModule() : void
		{
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
		}
	}
}