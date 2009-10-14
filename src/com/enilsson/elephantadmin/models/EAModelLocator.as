package com.enilsson.elephantadmin.models
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.asual.swfaddress.SWFAddress;
	import com.enilsson.elephantadmin.events.GetVersionEvent;
	import com.enilsson.elephantadmin.events.session.PingEvent;
	import com.enilsson.elephantadmin.models.viewclasses.*;
	import com.enilsson.elephantadmin.utils.DispatchingTimer;
	import com.enilsson.elephantadmin.views.modules.app_options.model.AppOptionsModel;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.model.PledgeWorkspaceVO;
	import com.enilsson.elephantadmin.vo.*;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	public class EAModelLocator implements ModelLocator
	{		
		/**
		 * Versioning
		 */
		[Embed(source="/revision.xml", mimeType="application/octet-stream")]
        private var VersionFile:Class;        
        [Bindable] public var version 	: String;
        [Bindable] public var revision 	: String;
        [Bindable] public var versionXmlUrl : String = "revision.xml";
		
		private static var modelLocator : EAModelLocator;
		
		/**
		* Instanciate the ModelLocator
		*/
		public static function getInstance() : EAModelLocator
		{
			if (modelLocator == null)
				modelLocator = new EAModelLocator();

			return modelLocator;
		}

		public function EAModelLocator()
		{
			if ( modelLocator != null )
			{
				throw new Error( "Only one ModelLocator instance should be instantiated" );
			}
			else
			{
				var bytes:ByteArray = new VersionFile() as ByteArray;
        		var versionXML:XML 	= new XML(bytes.readUTFBytes(bytes.length));
        		
        		version = versionXML.version;
        		revision = versionXML.revision;
        		
        		// starts checking for updates regularly
        		_checkForUpdateTimer.start();
			}
		}
		

		/**
		* Application level variables
		*/
		[Bindable] public var applicationURL : String;
		
		// url for the auth gateway, and the instance ID
 		[Bindable] public var authURL:String;
		[Bindable] public var appInstanceID:int;  	
		
		// urls for the webroot of the application
		[Bindable] public var siteURL : String = '';
		[Bindable] public var baseURL : String = '';	
			
		// app specific variables for name and logo
		[Bindable] public var appName : String;
		[Bindable] public var appLogo : String;
		
		// urls to define the gateway and the path the S3 bucket
		[Bindable] public var gatewayURL : String = null;
		[Bindable] public var gatewayBaseURL : String = '';
		[Bindable] public var s3URL : String = 'https://trakker.s3.amazonaws.com/';
		
		/**
		* Session variables
		*/
		[Bindable]
		public function set session( value : SessionVO ) : void
		{
			_session = value;
			
			if(_session != null) {
				startPingTimer();
			}
			else {
				stopPingTimer();
			}
		}
		public function get session() : SessionVO
		{
			return _session;
		}
		private var _session : SessionVO;
		// variable to define which module to load on initialise 
		[Bindable] public var firstModule : int = 0;
		// hold the session id from Struktor
		[Bindable] public var sess_id : String;
		// flag to notify the InitMainCommand that the user is completing the login.
		[Bindable] public var isLoggingIn : Boolean = false;
		
		[Bindable] public var supportDescription:String = '';
		
		/**
		 * Timer variables
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
		[Bindable] public var siteLayoutLoaded : Boolean = false;
		[Bindable] public var navLayout : ArrayCollection;
		[Bindable] public var aclLayout : ArrayCollection;
		[Bindable] public var searchBoxCombo : ArrayCollection;
		[Bindable] public var allowedModules : ArrayCollection;
		[Bindable] public var struktorLayout : StruktorLayoutViewClass = new StruktorLayoutViewClass();
		[Bindable] public var mastheadOpen : Boolean = true;
		
		
		/**
		* Database specifc variables - IDs of system templates/attachments in the Database
		*/
		[Bindable] public var serverVariables : Object = new Object();
		
		
		/**
		* Organisation specifc variables
		*/
		[Bindable] public var orgName : String;
		[Bindable] public var orgURL : String;
		[Bindable] public var orgLogo : String;
		
		public var allGroupsList : Array;
		private var _orgGroups : Array;
		public function set orgGroups ( value : Array ) : void
		{
			_orgGroups = value;
		}

		[Bindable] public function get orgGroups ( ) : Array
		{
			return _orgGroups;
		}

		
		/**
		* User specific variables
		*/
		[Bindable] public var userLevel : String;
		[Bindable] public var itemsPerPage : Number = 50;
		[Bindable] public var aclPermissions : ArrayCollection;
		[Bindable] public var permissionsName : Array = ['Read' , 'Write' , 'Modify' , 'Del' , 'Export' , 'Restore' , 'Search' , 'RLAC' , 'Auditing'];
		[Bindable] public var allGroups : ArrayCollection;
		
		
		/**
		* Application Public Key
		*/
		[Bindable] public var publicKey : String = "-----BEGIN PUBLIC KEY-----\n" + "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHMWjZ4QhZJW/Zckui/GQ654lR\n" + "hYIbj+C7BR0MdB6SL6Ka8QKmwlzy4ahqz6zYLLY2rNWoZSLBofSn7PqDeow/qRvz\n" + "rT3jVY156ziQGKUAtNo7BTLVvDNDs0OpDRa4fLvv7c06uw++W+AIlBWhyT4rlve6\n" + "uzjLRNkvZCzB7UmxkQIDAQAB\n" + "-----END PUBLIC KEY-----";
		
		
		/**
		* Variables for the deeplinking
		*/
		public var is_parsing_url : Boolean = false;
		// array holding the fragment portions delimited by a forward slash
		
		
		/**
		* Set the application debug mode
		*/
		[Bindable] public var debug : Boolean = false;
		
		
		/**
		* Set the locations for the client UI
		*/
		[Bindable] public var clientUI : String = 'ET_cairngorm.html';
		
		
		/**
		* Variable and constants to define the view state of the screens (login or main)
		*/
		[Bindable] public var screenState : uint = 0;
		public static const LOGIN_SCREEN : uint = 0;
		public static const MAIN_SCREEN : uint = 1;
		
		
		/**
		* Variable and constants to define the view state of the main screen
		*/
		private var _mainViewState : int = - 1;
		[Bindable] public function get mainViewState() : int
		{
			return _mainViewState;
		}
		public function set mainViewState( value : int ) : void
		{
			if(value != _mainViewState)
			{
				_lastViewState = _mainViewState;
				_mainViewState = value;
			}
		}
		
		/**
		 * The last viewed module
		 */
		private var _lastViewState : int = - 1;
		[Bindable] public function get lastViewState() : int
		{
			return _lastViewState;
		}
		public function set lastViewState( value : int ) : void { /*read only */ }

		/**
		 * Array of all the module url names
		 */
		public var viewStateList : Array = [
			'dashboard' , 'users' , 'search' , 'record' , 'browse' , 'reporting' , 
			'news' , 'events' , 'resources' , 'app_store' , 'email_log' , 'email_system' , 
			'email_user' , 'email_attachments' , 'checks' , 'custom_reporting' , 
			'pledges' , 'transactions' , 'transactions_failed' , 'contacts' , 
			'paypal_transactions', 'batch', 'app_options'
		];

		/**
		 * Array of all the module titles
		 */
		[Bindable] public var viewStateNames : ArrayCollection = new ArrayCollection([
			'Dashboard' , 'Users' , 'Search' , 'Record' , 'Browse' , 'Reporting' , 
			'News' , 'Events' , 'Resources' , 'App Store' , 'Email - Log' , 'Email - System Templates' , 
			'Email - User Templates' , 'Email - Attachments' , 'Checks' , 'Custom Reporting' , 
			'Pledges' , 'Transactions - Successful' , 'Transactions - Failed' , 'Contacts' , 
			'Paypal Transactions', 'Batches', 'Application Options'
		]);
		
		/**
		 * Static variables defining the view foreach module
		 */
		public static const NO_VIEW:int						= -1;
		public static const DASHBOARD_VIEW : int 			= 0;
		public static const USERS_VIEW : int 				= 1;
		public static const SEARCH_VIEW : int 				= 2;
		public static const RECORD_VIEW : int 				= 3;
		public static const BROWSE_VIEW : int 				= 4;
		public static const REPORTING_VIEW : int			= 5;
		public static const NEWS_VIEW : int 				= 6;
		public static const EVENTS_VIEW : int 				= 7;
		public static const RESOURCES_VIEW : int 			= 8;
		public static const APP_STORE_VIEW : int 			= 9;
		public static const EMAIL_LOG_VIEW : int 			= 10;
		public static const EMAIL_SYSTEM_VIEW : int 		= 11;
		public static const EMAIL_USER_VIEW : int 			= 12;
		public static const EMAIL_ATTACHMENTS_VIEW : int 	= 13;
		public static const CHECKS : int 					= 14;
		public static const CUSTOM_REPORTING : int 			= 15;
		public static const PLEDGES : int 					= 16;
		public static const TRANSACTIONS_VIEW : int 		= 17;
		public static const TRANSACTIONS_FAILED_VIEW : int 	= 18;
		public static const CONTACTS_VIEW : int 			= 19;
		public static const PAYPAL_VIEW : int 				= 20;
		public static const BATCH_VIEW : int 				= 21;
		public static const APP_OPTIONS_VIEW : int 			= 22;
		
		
		/**
		* Mapping for the returned table names from an sid request to their correct module
		*/
		public var tableModuleMapping : Object =
		{
			'tr_users' : 1 ,
			'news' : 6 ,
			'events' : 7 ,
			'resources' : 8 ,
			'email_log' : 10 ,
			'email_system_templates' : 11 ,
			'email_user_templates' : 12 ,
			'checks' : 14 ,
			'pledges' : 16 ,
			'transactions' : 17 ,
			'transactions_failed' : 18 ,
			'contacts' : 19 ,
			'paypal_transactions' : 20,
			'reporting' : 5
		};
		
		
		/**
		* Variable to hold the result of an SID call, so it can be passed to the module on load
		*/
		[Bindable] public var sidChange:Boolean = false;
		private var _sid : SidVO;
		public function set sid ( value : SidVO ) : void
		{
			_sid = value;
			sidChange = value != null;
		}
		[Bindable] public function get sid ( ) : SidVO
		{
/* 			
			// flash the sid when it is retrieved
			var sidTemp : SidVO = _sid;
			_sid = null;
			// set the change flag back to false
			sidChange = false;
			return sidTemp;
 */		
 			return _sid;
 		}

		
		/**
		* Class variables that hold the information for the view modules
		*/
		[Bindable] public var login : LoginViewClass = new LoginViewClass();
		//		[Bindable] public var users:UsersViewClass = new UsersViewClass();
		[Bindable] public var downline : DownlineViewClass = new DownlineViewClass();
		[Bindable] public var news : NewsViewClass = new NewsViewClass();
		[Bindable] public var search : SearchViewClass = new SearchViewClass();
		[Bindable] public var resources : ResourcesViewClass = new ResourcesViewClass();
		[Bindable] public var reporting : ReportingViewClass = new ReportingViewClass();
		[Bindable] public var record : RecordViewClass = new RecordViewClass();
		[Bindable] public var checks : ChecksViewClass = new ChecksViewClass();
		[Bindable] public var events : EventsViewClass = new EventsViewClass();
		[Bindable] public var browse : BrowseViewClass = new BrowseViewClass();
		[Bindable] public var transactions : TransactionsViewClass = new TransactionsViewClass();
		[Bindable] public var transactions_failed : TransactionsFailedViewClass = new TransactionsFailedViewClass();
		[Bindable] public var paypal_transactions : PaypalTransactionsViewClass = new PaypalTransactionsViewClass();
		[Bindable] public var batch : BatchViewClass = new BatchViewClass();
				
		//Email submodules
		[Bindable] public var email_log : EmailLogViewClass = new EmailLogViewClass();
		[Bindable] public var email_system : EmailSystemViewClass = new EmailSystemViewClass();
		[Bindable] public var email_user : EmailUserViewClass = new EmailUserViewClass();
		[Bindable] public var email_attachments : EmailAttachmentsViewClass = new EmailAttachmentsViewClass();
		
		// model to store application options stored in the site_options table
		[Bindable] public var appOptions : AppOptionsModel = new AppOptionsModel();
		
		// pledge workspace module
		[Bindable] public function get pledgeWorkspace ( ):PledgeWorkspaceVO { return _pledgeWorkspace; }
		private var _pledgeWorkspace:PledgeWorkspaceVO;
		public function set pledgeWorkspace ( value:PledgeWorkspaceVO ):void { _pledgeWorkspace = value; }

		/**
		* Miscellaneous variables
		*/
		[Bindable] public var dataLoading : Boolean = false;
		[Bindable] public var mainScreen : DisplayObject;
		[Bindable] public var mainScreenVisible : Boolean = false;
		[Bindable] public var runInit : Boolean = false;
		[Bindable] public var dataChanged : Boolean = false;
		[Bindable] public var recordChanged : Boolean = false;
		[Bindable] public var s3vo : S3VO;
		[Bindable] public var errorVO : ErrorVO;
		[Bindable] public var isSubmitting : Boolean = false;
		[Bindable] public var onClose : Function;
		
		
		/**
		* Resets model data after closing a session.
		*/
		public function reset() : void
		{
			runInit = false;
			
			// set the main screen back to the login
			screenState = LOGIN_SCREEN;
			mainScreenVisible = true;
			mainViewState = NO_VIEW;
			
			// reset some of the model variables
			session = null;
			gatewayURL = null;
			siteLayoutLoaded = false;
			dataLoading = false;
			
			// reset the view state of the login form
			login.loginFormState = 'ClearPassword';
			
			// reset each of the module view classes
			login = new LoginViewClass();
			//			users = new UsersViewClass();
			downline = new DownlineViewClass();
			news = new NewsViewClass();
			search = new SearchViewClass();
			resources = new ResourcesViewClass();
			reporting = new ReportingViewClass();
			record = new RecordViewClass();
			checks = new ChecksViewClass();
			transactions = new TransactionsViewClass();
			transactions_failed = new TransactionsFailedViewClass();
			batch = new BatchViewClass();

			// email submodules
			email_log = new EmailLogViewClass();
			email_system = new EmailSystemViewClass();
			email_user = new EmailUserViewClass();
			email_attachments = new EmailAttachmentsViewClass();
			
			appOptions = new AppOptionsModel();
			
			// change the browser info to the login screen
			SWFAddress.setValue('login');
			SWFAddress.setTitle(appName + ' - Login');
			
			// remove any moduleFWD references from the LSO
			eNilssonUtils.flashCookie('module_fwd');
			
			// remove the gatewayUrl from the LSO
			eNilssonUtils.clearCookie('gatewayURL');
		}
	}
}
