package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.events.AppEvent;
	import com.enilsson.elephanttrakker.events.GetVersionEvent;
	import com.enilsson.elephanttrakker.events.URLChangeEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	
	public class InitAppCommand extends SequenceCommand implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();

	
		override public function execute(event:CairngormEvent):void
		{
			// set the site parameters from the flash vars if there are any
			setSiteURL();
			
			// Create our Browser Manager
			_model.browserManager = BrowserManager.getInstance();
			
			// Listen to the changes made to the URL
			_model.browserManager.addEventListener(BrowserChangeEvent.URL_CHANGE, parseURL);			
			
			// Display the title of our current (default) page
			_model.browserManager.init("", _model.appName);
			
			// check the version		
			var gve:GetVersionEvent = new GetVersionEvent();
			gve.nextEvent = new AppEvent();			
			this.nextEvent = gve;
			this.executeNextCommand();
			this.nextEvent = null;			
		}
		
		/**
		 * When the url is changed fire an event to handle any changes
		 */
		private function parseURL(e:BrowserChangeEvent):void
		{
			new URLChangeEvent().dispatch();
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
				_model.appName 			= Application.application.parameters.siteTitle;
				_model.appLogo 			= Application.application.parameters.appLogo;
				_model.adminUI 			= Application.application.parameters.adminUI;
				_model.appInstanceID 	= Application.application.parameters.instanceID;
				_model.rssFeed			= Application.application.parameters.rssFeed;
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
		
	}
}