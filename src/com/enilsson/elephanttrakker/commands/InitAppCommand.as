package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.enilsson.elephanttrakker.events.GetVersionEvent;
	import com.enilsson.elephanttrakker.events.URLChangeEvent;
	import com.enilsson.elephanttrakker.events.session.SessionCheckEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.utils.DomainWhitelistChecker;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.utils.Base64Decoder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class InitAppCommand extends SequenceCommand implements ICommand
	{
		private static var _executed : Boolean;
		private var _model:ETModelLocator = ETModelLocator.getInstance();

	
		override public function execute(event:CairngormEvent):void
		{
			// make sure the InitAppCommand is only executed once
			if( !_executed )
			{
				// set security restrictions
				setSecurity();
				
				// set the site parameters from the flash vars if there are any
				setSiteURL();
				
				// initialise fragment reading
				initSwfAddress();
				
				_executed = true;
			}
		}
		
		/**
		 * Set security restrictions for BlueSwarm
		 */ 
		private function setSecurity():void
		{
			Security.allowDomain("*.blue-swarm.com");
		}

		/**
		 * Set the application parameters
		 */		
		private function setSiteURL():void
		{
			var dwc : DomainWhitelistChecker = new DomainWhitelistChecker( [ 'enilssonator.com', 'blue-swarm.com' ] );
			// set the application's URL			
			_model.applicationURL = Application.application.url.split(Application.application.className +".swf")[0];
			
			if( ! dwc.isUrlAllowed(_model.applicationURL) )
				return;
			
			// get the parameters from the flash vars if in production
			if(Application.application.parameters.siteURL)
			{
				var params 				: Object = Application.application.parameters;
								
				_model.authURL 			= dwc.isUrlAllowed(params.authURL) ? params.authURL : null;
				_model.siteURL 			= dwc.isUrlAllowed(params.siteURL) ? params.siteURL : null;
				_model.baseURL 			= dwc.isUrlAllowed(params.baseURL) ? params.baseURL : null;
				_model.adminUI 			= params.adminUI;
				_model.appName 			= params.siteTitle;
				_model.appLogo			= dwc.isUrlAllowed(params.appLogo) ? params.appLogo : null;
				_model.appInstanceID 	= params.instanceID;
				_model.orgLogo			= dwc.isUrlAllowed(params.orgLogo) ? params.orgLogo : null;
				_model.orgName			= params.orgName;
				_model.orgURL			= params.orgURL;
				
				_model.debug			= false;
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
		 * Initialises the SWFAddress
		 */
		private function initSwfAddress() : void
		{
			SWFAddress.addEventListener(SWFAddressEvent.INIT, handleSwfAddressInitialized );
		}
		
		private function handleSwfAddressInitialized( event : SWFAddressEvent ) : void 
		{
			SWFAddress.setTitle( _model.appName );
			
			var versionEvent : GetVersionEvent = new GetVersionEvent();
		
			if( redirect() || readGatewayUrl() )
			{
				navigateToFirstModule();
				versionEvent.nextEvent =  new SessionCheckEvent();
			}
			else
			{
				_model.screenState = ETModelLocator.LOGIN_SCREEN;
				_model.mainScreenVisible = true;
			}
			
			// attach a listener to the browser manager
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, parseURL);
			
			// register and execute the next command in sequence
			nextEvent = versionEvent;
			executeNextCommand();
			nextEvent = null;
		}
		
		private function parseURL( event : Event ) : void {
			new URLChangeEvent().dispatch();
		}
		
		
		/**
		 * Checks if a redirect is necessary and redirects the user to the 
		 * related part of the application
		 * 
		 * @return	A Boolean indicating if a redirect happened or not
		 */
		private function redirect() : Boolean
		{
			var f : String = SWFAddress.getValue();
			if(_model.debug) Logger.info('Redirect Check', f);
			
			// if the fragment points to redirect then check the session
			if(f.indexOf('/redirect/') != -1)
			{
				// decode the gateway url from the fragment
				var base64Dec:Base64Decoder = new Base64Decoder();
				base64Dec.decode(f.replace('/redirect/',''));
				
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
			if( _model.siteURL ) {
				var f : String = SWFAddress.getValue().split("/")[1];
				if(f == '' || f == 'login')
					return false;
			}
			
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
		 * Navigates to the first available module or another module if listed
		 */
		private function navigateToFirstModule() : void
		{
			// look to see if they attempted to go to another module
			var redirectModule:String = eNilssonUtils.flashCookie('module_fwd');
			
			// move from login screen to main screen
			_model.screenState = ETModelLocator.MAIN_SCREEN;
				
			// list the redirect module as the go to destination					
			if(redirectModule != null)
				_model.firstModule = _model.viewStateList.indexOf(redirectModule);

			// if no redirect then go to whatever is in the browser fragment (or the first module if nothing matches)
			else 
			{					
				var fragment:String = SWFAddress.getValue().split('/')[1];
				
				_model.firstModule = _model.viewStateList.indexOf(fragment) == -1 ? 0 : _model.viewStateList.indexOf(fragment);
			}
		}
	}
}