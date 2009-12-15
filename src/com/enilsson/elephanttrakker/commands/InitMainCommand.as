package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
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
	import mx.managers.PopUpManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ObjectProxy;
	import mx.utils.ObjectUtil;
	import mx.utils.URLUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class InitMainCommand extends SequenceCommand implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
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
			
			_model.mainViewState = _model.firstModule;
			_model.mainScreenVisible = true;
			
			this.nextEvent = new GetSiteLayoutEvent();
			this.executeNextCommand();
			this.nextEvent = null;
		}	

		private function onFault_sessionCheck(data:Object):void
		{
			if(_model.debug) Logger.info('InitMainCommand Session Fault');

			var f : String = SWFAddress.getValue().split("/")[1];
			eNilssonUtils.clearCookie('module_fwd');
			eNilssonUtils.writeCookie('module_fwd', f);
			
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
			
			// add a link to the website to the user info layout
			var link : Object = getWebsiteLink();
			if(link)
				_model.userInfoLayout.addItem(link);
			
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
			_model.reset();
		}
		
		private function getWebsiteLink() : Object {
			
			if(!_model.orgURL) return null;
			
			var domain : String = URLUtil.getServerName( _model.orgURL ).replace(/^www\./gi,"");
			var url : String = _model.orgURL;
				
			return new ObjectProxy( { name: domain, icon:"web_browser", action:{ type:"url",destination:url }, type:"url" } );
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
			_model.reset();
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
			
			// set all the flags and browser elements once the session and layout have been returned
			handleSuccessfulLoad();
			
			// tell the model that the layouts are in place	
			_model.struktorLayout.loaded = true;	
			
			// run the command to get the RSS info
			this.nextEvent = new GetRSSEvent('get_rss');
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		public function onFault_getStruktorLayout(event:Object):void
		{
			if(_model.debug) Logger.info('getStruktorLayout Fail', ObjectUtil.toString(event));		
			_model.reset();			
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
				
				if(dp.length == 0) {
					dp.addItem( getNoNewsRssVO() );
				}
			}
			catch( e : Error ) {
				dp.removeAll();
				dp.addItem( getErrorMessageRssVO() );
			}		
			
			_model.rssData = dp;
		}
		
		private function onFault_getRSS(event:FaultEvent):void
		{
			event.preventDefault();
			event.stopImmediatePropagation();
			
			if(_model.debug) Logger.info('Fail RSS', ObjectUtil.toString(event));
			
			var dp:ArrayCollection = new ArrayCollection();
			dp.addItem( getErrorMessageRssVO() );		
			_model.rssData = dp;
		}
		
		private function getErrorMessageRssVO() : RssVO { return getErrorRssVO('There is an error with the RSS feed, please inform your admin team!'); }
		private function getNoNewsRssVO() : RssVO { return getErrorRssVO("There is no news available today."); }
		
		private function getErrorRssVO( title : String ) : RssVO
		{
			var rssVO:RssVO = new RssVO();
			rssVO.title = title;
			rssVO.error = true;			
			return rssVO;			
		}

		/**
		 * Handler to launch the required elements once the session and layout have been loaded
		 */
		private function handleSuccessfulLoad():void
		{				
			// set the main container to the correct module
				
			// test to see if the requested module is in the allowed list
			if(_model.allowedModules.getItemIndex(_model.viewStateList[_model.firstModule]) == -1)
				_model.firstModule = 0;
				
			// initialise the first view module
			_model.runInit = true;	
			
			// clear the login form processing
			_model.login.loginProcessing = false;			

			if(_model.debug) Logger.info('handleSuccessfulLoad', _model.firstModule, _model.viewStateList[_model.firstModule]);
		
			// set the fragment and set the page title
			SWFAddress.setValue(_model.viewStateList[_model.firstModule]);
			SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[_model.firstModule]);

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