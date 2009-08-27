package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.*;
	import com.enilsson.elephanttrakker.events.main.*;
	import com.enilsson.elephanttrakker.events.session.*;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.views.main.*;
	import com.enilsson.elephanttrakker.vo.AppOptionsVO;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	import com.enilsson.elephanttrakker.vo.RssVO;
	import com.enilsson.elephanttrakker.vo.SessionVO;
	import com.enilsson.elephanttrakker.vo.StruktorLayoutVO;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.IResponder;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ObjectProxy;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class InitMainCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function InitMainCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			switch(event.type)
			{
				case SessionCheckEvent.EVENT_SESSION_CHECK :
					sessionCheck( event as SessionCheckEvent );
				break;
				case GetSiteLayoutEvent.EVENT_GET_LAYOUT :
					getSiteLayout( event as GetSiteLayoutEvent );
				break;
				case GetSiteOptionsEvent.EVENT_GET_OPTIONS :
					getSiteOptions( event as GetSiteOptionsEvent );
				break;
				case GetStruktorLayoutEvent.GET_STRUKTOR_LAYOUT :
					getStruktorLayout( event as GetStruktorLayoutEvent );
				break;		
				case GetRSSEvent.EVENT_GET_RSS :
					getRSS( event as GetRSSEvent );
				break;
			}
		}

		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		

		/**
		 * Initial Session check event
		 */
		private function sessionCheck(event:SessionCheckEvent):void
		{	
			if(_model.debug){ Logger.info('Getting the Session for the first time'); }

			var handlers : IResponder = new mx.rpc.Responder(onResults_sessionCheck, onFault_sessionCheck);
			var delegate:SessionDelegate = new SessionDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.getSessionInfo();
		}

		private function onResults_sessionCheck(data:Object):void 
		{
			if(_model.debug) Logger.info('Session Success', ObjectUtil.toString(data.result));

			// apply the session data to the VO
			_model.session = new SessionVO( data.result );	
			// set the items per page
			_model.itemsPerPage = Number(_model.session.data._itemsperpage);
			// save the PHP sess id
			_model.sess_id = data.result.php_session_id;	
			
			this.nextEvent = new GetSiteLayoutEvent();
			this.executeNextCommand();
			this.nextEvent = null;
		}	

		private function onFault_sessionCheck(data:Object):void
		{
			if(_model.debug) Logger.info('InitMainCommand Session Fault');

			eNilssonUtils.clearCookie('module_fwd');
			eNilssonUtils.writeCookie('module_fwd', _model.browserManager.fragment);

/* 			
		 	if(data.fault.faultCode){
		 		switch(data.fault.faultCode)
		 		{
		 			case 'AMFPHP_AUTHENTICATE_ERROR' :
						Alert.show(	
							'Your ' + _model.appName + ' session has expired, please login to continue!',
							'Session timeout', 
							0, 
							null,
							handleClose,
							Icons.ALERT
						);
					break;
					case 'Client.Error.MessageSend' :
					case 'Client.Error.DeliveryInDoubt' :
						Alert.show(	
							'Your ' + _model.appName + ' session is not authenticated, please login to continue!',
							'Session authentication error', 
							0, 
							null,
							handleClose,
							Icons.ALERT
						);
					break;
		 		}
		 	}			
 */
 		}	
		
		private function handleClose(e:CloseEvent):void
		{
			_model.reset();
		}


		/**
		 * Get the site layout once the session is verified
		 */
		private function getSiteLayout( event:GetSiteLayoutEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getSiteLayout, onFault_getSiteLayout);			
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			if(_model.debug) Logger.info('Get Site Layout');

			delegate.getApplicationLayout();
		}
		
		private function onResults_getSiteLayout(event:Object):void
		{
			if(_model.debug) Logger.info('Success Layout', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			var xmlDoc:XMLDocument = new XMLDocument( event.result );
			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder( true );
            var xmlObj:Object = decoder.decodeXML( xmlDoc );
            
            // assign the various values to the model			
			_model.navLayout = xmlObj.layout.top_nav.link;
			_model.userInfoLayout = xmlObj.layout.user_info.link;
			_model.allowedModules = xmlObj.layout.allowed_modules.module;
			if(xmlObj.layout.hasOwnProperty( 'variables' ) )
				for each(var item:Object in xmlObj.layout.variables.variable)
					_model.serverVariables[item.key] = item.value;

			// run the command to get campaign configurable options list
			this.nextEvent = new GetSiteOptionsEvent();
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		private function onFault_getSiteLayout(event:Object):void
		{
			if(_model.debug) Logger.info('Fail Layout', ObjectUtil.toString(event));
		
			_model.dataLoading = false;
		}


		/**
		 * Get the site options
		 */
		private function getSiteOptions( event:GetSiteOptionsEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getSiteOptions, onFault_getSiteOptions);			
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			if(_model.debug) Logger.info('Get Site Options');

			var where:Object = {
				'statement':'(1)','1':{ 
					'what' : 'site_options.option_display',
					'val' : 1,
					'op' : '='
				}
			};

			delegate.getRecords( new RecordsVO( 'site_options', where ) );
		}
		
		private function onResults_getSiteOptions( event:Object ):void
		{
			if(_model.debug) Logger.info('Success Site Options', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			// build the options listing in the app model
			_model.options = new AppOptionsVO ( event.result.site_options );
			
			// tell the model that all the layout and options have been loaded
			_model.siteLayoutLoaded = true;
			
			//Logger.info('Options', ObjectUtil.toString( _model.options ) );
			
			// run the command to get the struktor layouts
			this.nextEvent = new GetStruktorLayoutEvent();
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		private function onFault_getSiteOptions( event:Object ):void
		{
			if(_model.debug) Logger.info('Fail Site Options', ObjectUtil.toString(event));
		
			_model.dataLoading = false;
		}


		/**
		 * Get the table layouts to build forms
		 */			
		private function getStruktorLayout(event:GetStruktorLayoutEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getStruktorLayout, onFault_getStruktorLayout);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getLayouts();			
		}
				
		private function onResult_getStruktorLayout(event:Object):void 
		{
			if(_model.debug) Logger.info('getStruktorLayout Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			// loop through the tables and add them to the struktorLayout view class
			for each ( var table:Object in event.result )
				if(_model.struktorLayout.hasOwnProperty(table.table))
					_model.struktorLayout[table.table] = new StruktorLayoutVO( table );
			
			// tell the model that the layouts are in place	
			_model.struktorLayout.loaded = true;	

			// set all the flags and browser elements once the session and layout have been returned
			handleSuccessfulLoad();
			
			// run the command to get the RSS info
			this.nextEvent = new GetRSSEvent('get_rss');
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		public function onFault_getStruktorLayout(event:Object):void
		{
			if(_model.debug) Logger.info('getStruktorLayout Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}		
	

		/**
		 * Get an RSS feed and populate the news ticker on the Main Screen
		 */
		private function getRSS(event:GetRSSEvent):void
		{
			var handlers : IResponder = new mx.rpc.Responder(onResults_getRSS, onFault_getRSS);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			delegate.getRSS();
		}

		private function onResults_getRSS(event:Object):void
		{
			if(_model.debug) Logger.info('Success RSS', ObjectUtil.toString(event.result));

			var rss:XML;
			var dp:ArrayCollection = new ArrayCollection();
			
			try {
				rss = new XML( event.result );
				
				for each ( var item:Object in rss.channel.item ) {
					var rssVO:RssVO = new RssVO ( item );
					dp.addItem( new ObjectProxy( rssVO ) );					
				}
			}
			catch( e : Error ) { 
				dp.addItem( getErrorRssVO() );
			}		
			
			_model.rssData = dp;
		}
		
		private function onFault_getRSS(event:Object):void
		{
			if(_model.debug) Logger.info('Fail RSS', ObjectUtil.toString(event));
			
			var dp:ArrayCollection = new ArrayCollection();
			dp.addItem( getErrorRssVO() );		
			_model.rssData = dp;
		}
		
		private function getErrorRssVO() : RssVO
		{
			var rssVO:RssVO = new RssVO ();
			rssVO.title = 'There is an error with the RSS feed, please inform your admin team!';
			rssVO.error = true;
			
			return rssVO;			
		}


		/**
		 * Handler to launch the required elements once the session and layout have been loaded
		 */
		private function handleSuccessfulLoad():void
		{			
			// test to see if the requested module is in the allowed list
			if(_model.allowedModules.getItemIndex(_model.viewStateList[_model.firstModule]) == -1)
				_model.firstModule = 0;
			
			// set the main container to the correct module	
			_model.screenState = ETModelLocator.MAIN_SCREEN;
			_model.mainViewState = _model.firstModule;

			// initialise the first view module
			_model.runInit = true;	
			
			// clear the login form processing
			_model.login.loginProcessing = false;			

			if(_model.debug) Logger.info('handleSuccessfulLoad', _model.firstModule, _model.viewStateList[_model.firstModule]);
		
			// set the fragment and set the page title
			_model.browserManager.setFragment(_model.viewStateList[_model.firstModule]);
			_model.browserManager.setTitle(_model.appName + ' - ' + _model.viewStateNames[_model.firstModule]);

			// show the initial login form / agent agreement if needed
			if (_model.session.data._firstlogin == 0) 
			{			    
			 	var pClass:Class = FirstLoginBox as Class; 	
			 	var p:* = PopUpManager.createPopUp( _model.mainScreen, pClass, true );
			    PopUpManager.centerPopUp(p);
			}
		}
		
	}
}