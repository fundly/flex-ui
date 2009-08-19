package com.enilsson.elephanttrakker.models
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephantadmin.utils.DispatchingTimer;
	import com.enilsson.elephanttrakker.events.GetVersionEvent;
	import com.enilsson.elephanttrakker.events.session.PingEvent;
	import com.enilsson.elephanttrakker.models.viewclasses.*;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.model.PledgeWorkspaceVO;
	import com.enilsson.elephanttrakker.vo.AppOptionsVO;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	import com.enilsson.elephanttrakker.vo.SessionVO;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.managers.IBrowserManager;
	
	public class ETModelLocator implements ModelLocator
	{
		//versioning:
		[Embed(source="/revision.xml", mimeType="application/octet-stream")]
        private var VersionFile:Class;        
        [Bindable] public var version 	: String;
        [Bindable] public var revision 	: String;
        [Bindable] public var versionXmlUrl : String = "revision.xml";
        
		private static var modelLocator:ETModelLocator;
		
		/**
		 * Instanciate the ModelLocator
		 */
		public static function getInstance():ETModelLocator
		{
			if (modelLocator == null)
				modelLocator = new ETModelLocator();

			return modelLocator;
		}

		public function ETModelLocator()
		{
			if ( modelLocator != null )
			{
				throw new Error( "Only one ModelLocator instance should be instantiated" );
			}
			else
			{
				var bytes:ByteArray = new VersionFile() as ByteArray;
        		var versionXML:XML 	= new XML(bytes.readUTFBytes(bytes.length));
        		
        		var regX:RegExp = /[a-zA-Z]/gi;
        		
        		version = versionXML.version;
        		revision = versionXML.revision;
			}
			
			_checkForUpdateTimer.start();
		}

		/**
		 * Application level variables
		 */
		[Bindable] public var authURL:String;
		[Bindable] public var appInstanceID:int;
		
		[Bindable] public var siteURL:String = ''; // url for the webroot of the application
		[Bindable] public var baseURL:String = ''; // url for the webroot of the application

		[Bindable] public var appName:String; // define the name of the app
		[Bindable] public var appLogo:String; // define the path to the app logo

		[Bindable] public var gatewayURL:String = null; // url defining the Struktor gateway
		[Bindable] public var gatewayBaseURL:String = ''; // base version of the Struktor gateway

		[Bindable] public var rssFeed:String = 'http://www.enilsson.com/news/rss'; // which RSS feed to read
		[Bindable] public var s3URL:String = 'https://trakker.s3.amazonaws.com/'; // where to look for S3 assets


		/**
		 * Session variables
		 */
		 [Bindable]
		public function set session( value : SessionVO ) : void
		{
			_session = value;
			
			if(_session != null)
				startPingTimer();
			else
				stopPingTimer();
		}
		private var _session : SessionVO;
		public function get session() : SessionVO { return _session; }
		
		
		[Bindable] public var firstModule:int = 0; // variable to define which module to load on initialise 
		[Bindable] public var sess_id:String; // hold the session id from Struktor


		/**
		 * Timer variables, both sys ping and version check
		 */
		private static const PING_DURATION : uint = 3;
		private static var _pingTimer : DispatchingTimer = new DispatchingTimer(new PingEvent(), PING_DURATION * 1000 * 60);
		
		private static const CHECK_UPDATE_DURATION : uint = 60; // the duration between update checks in seconds
		private static var _checkForUpdateTimer : DispatchingTimer = new DispatchingTimer(new GetVersionEvent(), CHECK_UPDATE_DURATION * 1000 * 60);
		
		private function startPingTimer() : void 
		{
			if(_pingTimer.running)
				_pingTimer.restart();
			else
				_pingTimer.start();
		}		
		private function stopPingTimer() : void 
		{ 
			if(_pingTimer.running)
				_pingTimer.stop();	
		}


		/**
		 * Site layout variables
		 */
		[Bindable] public var siteLayoutLoaded:Boolean = false; // flag to tell the app when the layout is in place

		[Bindable] public var navLayout:ArrayCollection;
		[Bindable] public var userInfoLayout:ArrayCollection;
		[Bindable] public var allowedModules:ArrayCollection;
		[Bindable] public var siteLegalese:String = '';
		[Bindable] public var paidFor:String = '';
		[Bindable] public var agentAgreement:String = '';
		[Bindable] public var workspaceAgreement:Object;
		[Bindable] public var successTextCheck:String = '';
		[Bindable] public var successTextCC:String = '';
		[Bindable] public var privacyPolicy:String;
		[Bindable] public var struktorLayout:StruktorLayoutViewClass = new StruktorLayoutViewClass();

		[Bindable] public var options:AppOptionsVO;


		/**
		 * Organisation specifc variables
		 */
		[Bindable] public var orgName:String;
		[Bindable] public var orgURL:String;
		[Bindable] public var orgLogo:String;

		/**
		 * Database specifc variables - IDs of system templates/attachments in the Database
		 */
		[Bindable] public var serverVariables:Object = new Object();

		/**
		 * User specific variables
		 */
		[Bindable] public var itemsPerPage:Number = 100; // set the number of records return for paginated pages
		[Bindable] public var siteMsgs:Number = 0; // how many unread messages there are
		[Bindable] public var loggedEmail:String = '';
		[Bindable] public var recordChanged:Boolean = false;

		/**
		 * Application Public Key
		 */
		[Bindable] public var publicKey:String = "-----BEGIN PUBLIC KEY-----\n" +
				"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHMWjZ4QhZJW/Zckui/GQ654lR\n" +
				"hYIbj+C7BR0MdB6SL6Ka8QKmwlzy4ahqz6zYLLY2rNWoZSLBofSn7PqDeow/qRvz\n" +
				"rT3jVY156ziQGKUAtNo7BTLVvDNDs0OpDRa4fLvv7c06uw++W+AIlBWhyT4rlve6\n" +
				"uzjLRNkvZCzB7UmxkQIDAQAB\n" +
				"-----END PUBLIC KEY-----"; 
				
				
		/**
		 * Variables for the deeplinking
		 */
		public var browserManager:IBrowserManager;
		public var is_parsing_url:Boolean = false;


		/**
		 * Set the application debug mode
		 */
		[Bindable] public var debug:Boolean = false;


		/**
		 * Set the location for the admin UI
		 */
		[Bindable] public var adminUI:String = 'ET_admin.html';


		/**
		 * Variable and constants to define the view state of the screens (login or main)
		 */
		[Bindable] public var screenState:uint = 0;

		public static const LOGIN_SCREEN:uint = 0;
		public static const MAIN_SCREEN:uint = 1;


		/**
		 * Variable and constants to define the view state of the main screen
		 */
		[Bindable] public var mainViewState:int = -1;

		public var viewStateList:Array = [
			'overview', 
			'pledge_processing', 
			'email', 
			'my_contacts', 
			'events', 
			'resources', 
			'my_history', 
			'my_downline', 
			'my_details', 
			'calls_reminders',
			'message_center',
			'invitation',
			'pledge_workspace'
		];
		public var viewStateNames:Array = [
			'Overview', 
			'Pledge Processing', 
			'Email', 
			'My Contacts', 
			'Events', 
			'Resources', 
			'My History', 
			'My Downline', 
			'My Details', 
			'Calls & Reminders',
			'Message Center',
			'Recruit Fundraiser',
			'Pledge Workspace'
		];
		
		public static const NO_VIEW:int = -1;
		public static const OVERVIEW_VIEW:int = 0;
		public static const CALL_LOGGING_VIEW:int = 1;
		public static const EMAIL_VIEW:int = 2;
		public static const MY_CONTACTS_VIEW:int = 3;
		public static const EVENTS_VIEW:int = 4;
		public static const RESOURCES_VIEW:int = 5;
		public static const MY_HISTORY_VIEW:int = 6;
		public static const DOWNLINE_VIEW:int = 7;
		public static const MY_DETAILS_VIEW:int = 8;
		public static const CALLS_REMINDERS_VIEW:int = 9;
		public static const MESSAGE_CENTER_VIEW:int = 10;
		public static const INVITATION_VIEW:int = 11;
		public static const PLEDGE_WORKSPACE_VIEW:int = 12;

		/**
		 * Class variables that hold the information for the view modules
		 */
		[Bindable] public var login:LoginViewClass = new LoginViewClass();
		[Bindable] public var overview:OverviewViewClass = new OverviewViewClass();
		[Bindable] public var call_logging:CallLoggingViewClass = new CallLoggingViewClass();
		[Bindable] public var my_contacts:MyContactsViewClass = new MyContactsViewClass();
		[Bindable] public var resources:ResourceViewClass = new ResourceViewClass();
		[Bindable] public var my_history:MyHistoryViewClass = new MyHistoryViewClass();
		[Bindable] public var email:EmailViewClass = new EmailViewClass();
		[Bindable] public var my_downline:MyDownlineViewClass = new MyDownlineViewClass();
		[Bindable] public var calls_reminders:CallsRemindersViewClass = new CallsRemindersViewClass();
		[Bindable] public var events:EventsViewClass = new EventsViewClass();
		[Bindable] public var my_details:MyDetailsViewClass = new MyDetailsViewClass();
		[Bindable] public var message_center:MessageCenterViewClass = new MessageCenterViewClass();
		[Bindable] public var invitation:InvitationViewClass = new InvitationViewClass();
		[Bindable] public var firstlogin:FirstLoginViewClass = new FirstLoginViewClass();
		
		[Bindable] public function get pledgeWorkspace ( ):PledgeWorkspaceVO { return _pledgeWorkspace; }
		private var _pledgeWorkspace:PledgeWorkspaceVO;
		public function set pledgeWorkspace ( value:PledgeWorkspaceVO ):void { _pledgeWorkspace = value; }

		/**
		 * Miscellaneous variables
		 */
		[Bindable] public var dataLoading:Boolean = false;
		[Bindable] public var rssData:ArrayCollection;
		[Bindable] public var mainScreen:DisplayObject;
		[Bindable] public var screenVStack:Boolean = false;
		[Bindable] public var runInit:Boolean = false;

		[Bindable] public var errorVO:ErrorVO;
		[Bindable] public var isSubmitting:Boolean = false;
		[Bindable] public var supportDescription:String = '';


		/**
		 * variables to send an email form the RSS Feed
		 */
		[Bindable] public var emails:String;
		[Bindable] public var subject:String;
		[Bindable] public var message:String;
		[Bindable] public var rss_message:String;
		[Bindable] public var rss_subject:String;
		[Bindable] public var rss_link:String;
		[Bindable] public var currFeed:uint;

		[Bindable] public var onClose:Function;
		
		/**
		 * Some embedded assets for the application
		 */
		[Bindable] public var icons:Icons = new Icons();

		/**
		 * Resets model data after closing a session.
		 */
		public function reset() : void
		{
			// move the screen to the login page
			screenState = ETModelLocator.LOGIN_SCREEN;
			mainViewState = NO_VIEW;

			// clear any residual gateway cookie
			eNilssonUtils.clearCookie('gatewayURL');

			// reset some of the model variables
			gatewayURL = null;
			session = null;
			runInit = false;
			siteLayoutLoaded = false;
			dataLoading = false;

			// reset the view state of the login form
			login.loginFormState = 'ClearPassword';
			login.loginProcessing = false;

			// reset each of the module view classes
			login = new LoginViewClass();
			overview = new OverviewViewClass();
			call_logging = new CallLoggingViewClass();
			my_contacts = new MyContactsViewClass();
			resources = new ResourceViewClass();
			my_history = new MyHistoryViewClass();
			email = new EmailViewClass();
			my_downline = new MyDownlineViewClass();
			calls_reminders = new CallsRemindersViewClass();
			message_center = new MessageCenterViewClass();
			my_details = new MyDetailsViewClass();
			events = new EventsViewClass();
			invitation = new InvitationViewClass();
			firstlogin = new FirstLoginViewClass();

			call_logging.reset();
			pledgeWorkspace = new PledgeWorkspaceVO();

			// change the browser info to the login screen
			browserManager.setFragment('login');
			browserManager.setTitle(appName + ' - Login');

			// some miscellaneous variables
			siteMsgs = 0;
		}
	}
}