package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.*;
	import com.enilsson.elephantadmin.events.main.*;
	import com.enilsson.elephantadmin.events.modules.RecordEvent;
	import com.enilsson.elephantadmin.events.session.*;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephantadmin.vo.S3VO;
	import com.enilsson.elephantadmin.vo.SessionVO;
	import com.enilsson.elephantadmin.vo.StruktorLayoutVO;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.IResponder;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class InitMainCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function InitMainCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			switch(event.type)
			{
				case RecordEvent.GET_LAYOUTS :
					getLayouts(event as RecordEvent);
				break;
				case SessionEvent.INIT_SESSION_CHECK :
					sessionCheck(event as SessionEvent);
				break;
				case GetSiteLayoutEvent.EVENT_GET_LAYOUT :
					getSiteLayout(event as GetSiteLayoutEvent);
				break;
				case GetGroupsEvent.EVENT_GET_GROUPS :
					getGroups(event as GetGroupsEvent);
				break;
				case S3Event.EVENT_S3 :
					getS3credentials(event as S3Event);
				break;
			}
		}

		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		

		/**
		 * Session Check method
		 */
		private function sessionCheck(event:SessionEvent):void
		{
			var handlers : IResponder = new mx.rpc.Responder(onResults_sessionCheck, onFault_sessionCheck);
			var delegate:SessionDelegate = new SessionDelegate(handlers);
			
			if(_model.session)
			{
				if(_model.debug) Logger.info('Session is already present!');
				
				// if the user does not have the sufficient admin rights send back to login
				if(!_model.session.admin_acl.hasOwnProperty('system_super') || !_model.session.admin_acl.hasOwnProperty('system_power'))
				{
					// set the users level
					if(_model.session.admin_acl.hasOwnProperty('system_power')) _model.userLevel = 'power';
					if(_model.session.admin_acl.hasOwnProperty('system_super')) _model.userLevel = 'super';
	
					// set the items per page
					_model.itemsPerPage = Number(_model.session.data._itemsperpage);

					// run the command to get the layout info for this instance
					this.nextEvent = new RecordEvent( RecordEvent.GET_LAYOUTS )
					this.executeNextCommand();
					this.nextEvent = null;
				} 
				else
				{
					Alert.show(	
						'You do not have sufficient permission to proceed with the ' + _model.appName + ' Admin Panel!',
						'Insufficient system priveledges', 
						0, 
						null,
						handleClose,
						Icons.ALERT
					);
				}
			}
			else
			{
				if(_model.debug) Logger.info('Get session information');
				
				_model.dataLoading = true;
				
				delegate.sessionInfo();
			}
		}

		private function onResults_sessionCheck(data:Object):void 
		{
			if(_model.debug) Logger.info('Session Success', ObjectUtil.toString(data.result));

			// apply the session data to the VO
			_model.session = new SessionVO( data.result );
			
			if(_model.debug) Logger.info('Session', _model.session.admin_acl.hasOwnProperty('system_super'), _model.session.admin_acl.hasOwnProperty('system_power'));

			// if the user does not have the sufficient admin rights send back to login
			if(_model.session.admin_acl.hasOwnProperty('system_super') || _model.session.admin_acl.hasOwnProperty('system_power'))
			{		
				// set the users level
				if(_model.session.admin_acl.hasOwnProperty('system_power')) _model.userLevel = 'power';
				if(_model.session.admin_acl.hasOwnProperty('system_super')) _model.userLevel = 'super';
				
				// show the main screen
				_model.mainScreenVisible = true;
				_model.screenState = EAModelLocator.MAIN_SCREEN;
				
				// set the items per page
				_model.itemsPerPage = Number(_model.session.data._itemsperpage);
				
				// run the command to get the layout info for this instance
				this.nextEvent = new RecordEvent( RecordEvent.GET_LAYOUTS )
				this.executeNextCommand();
				this.nextEvent = null;
			}
			else
			{
				// if this is a login then show the login error box
				if(_model.isLoggingIn)
				{
					if(_model.debug) Logger.info('User does NOT have sufficient rights');
				
					_model.login.loginProcessing = false;
					_model.login.loginErrorMessage = 'You do not have sufficient permission to proceed!';
					_model.login.loginFormState = 'ClearPassword';
					_model.login.loginErrorVisible = true;
					_model.login.loginErrorStyle = 'errorBox';
				} 
				// if it is page refresh then show the Alert box
				else
				{
					Alert.show(	
						'You do not have sufficient permission to proceed with the ' + _model.appName + ' Admin Panel!',
						'Insufficient system priviledges', 
						0, 
						null,
						handleClose,
						Icons.ALERT
					);
				}
			}
		}	

		private function onFault_sessionCheck(data:Object):void
		{
			// show the main screen
			_model.mainScreenVisible = true;
			
			// hide the loading icon
			_model.dataLoading = true;
			
			// remove the gURL from the cookie and save the attempted fragment
			eNilssonUtils.clearCookie('gatewayURL');
			eNilssonUtils.clearCookie('module_fwd');
			eNilssonUtils.writeCookie('module_fwd', _model.browserManager.fragment);
			
			//if(_model.debug)
				Logger.info('Session Fault', ObjectUtil.toString(data.fault)) 

		 	if(data.fault.faultCode){
		 		switch(data.fault.faultCode)
		 		{
		 			case 'AMFPHP_AUTHENTICATE_ERROR' :
						// check to see if the session is invalid or the user doesnt have sufficient rights
						if(data.fault.faultString.indexOf('You do not have permission to login to the admin.') == 0)
						{
							// if this is a login then show the login error box
							if(_model.isLoggingIn)
							{
								if(_model.debug) Logger.info('User does NOT have sufficient rights');
							
								_model.login.loginProcessing = false;
								_model.login.loginErrorMessage = 'You do not have sufficient permission to proceed!';
								_model.login.loginFormState = 'ClearPassword';
								_model.login.loginErrorVisible = true;
								_model.login.loginErrorStyle = 'errorBox';
							} 
							// if it is page refresh then show the Alert box
							else
							{
								Alert.show(	
									'You do not have sufficient permission to proceed with the ' + _model.appName + ' Admin Panel!',
									'Insufficient system priveledges', 
									0, 
									null,
									handleClose,
									Icons.ALERT
								);
							}
						}
						else if(_model.session)
						{
							logout();
							Alert.show(	
								'Your ' + _model.appName + ' session has expired, please login to continue!',
								'Session timeout', 
								0, 
								null,
								null,
								Icons.ALERT
							);
						}
					break;
					default:
						logout();
					break;
		 		}
		 	}			
		}
		
		private function handleClose( e : CloseEvent ) : void
		{
			logout();
		}
		
		private function logout() : void
		{			
			_model.reset();
		}
		

		/**
		 * Get the site layout once the session is verified
		 */
		private function getSiteLayout(event:GetSiteLayoutEvent):void
		{
			var handlers : IResponder = new mx.rpc.Responder(onResults_getSiteLayout, onFault_getSiteLayout);	
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			delegate.getApplicationLayout();
		}

		private function onResults_getSiteLayout(event:Object):void
		{
			if(_model.debug) Logger.info('Success Layout', ObjectUtil.toString(event.result));
			
			// convert the XML returned string into an Object
			var xml:XMLDocument = new XMLDocument( event.result );		
			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
            var xmlObj:Object = decoder.decodeXML(xml);
            
            // assign the various values to the model			
			_model.navLayout = xmlObj.layout.nav.link;
			_model.aclLayout = xmlObj.layout.acl.item;

			for each(var item:Object in xmlObj.layout.variables.variable)
				_model.serverVariables[item.key] = item.value;

			if(_model.debug) Logger.info('ACL Layout', ObjectUtil.toString(_model.aclLayout));
		
			_model.allowedModules = xmlObj.layout.allowed_modules.module;

			// run the command to get the groups info for this instance
			this.nextEvent = new GetGroupsEvent();
			this.executeNextCommand();
			this.nextEvent = null;
			
			// set all the flags and browser elements once the session and layout have been returned
			handleSuccessfulLoad();

			// flip a model switch to enabled the central workspace
			_model.siteLayoutLoaded = true;
		}
		
		private function onFault_getSiteLayout(event:Object):void
		{
			if(_model.debug){ Logger.info('Fail Layout', ObjectUtil.toString(event)); }
		
			_model.dataLoading = false;
		}


		/**
		 * Get the site layout once the session is verified
		 */
		private function getGroups(event:GetGroupsEvent):void
		{
			var handlers : IResponder = new mx.rpc.Responder(onResults_getGroups, onFault_getGroups);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			delegate.listGroups();
		}

		private function onResults_getGroups(event:Object):void
		{
			if(_model.debug) Logger.info('Success Get Groups', ObjectUtil.toString(event.result));
			
			// close the loading indicator
			_model.dataLoading = false;
			
			// parse the returned groups and remove those the user is not allowed to see
			var orgGroups:Array = [];
			var allGroupsList:Array = []
			_model.allGroups = new ArrayCollection();
			
			for each ( var item:Object in event.result)
			{
				_model.allGroups.addItem(item);

				var obj:Object = new Object();

				// Build list of All Groups
				obj['value'] = item.id;
				obj['label'] = item.group_name + ' (' + item.id + ')';
				allGroupsList.push(obj);

				// show all the groups for super users
				if(_model.userLevel == 'super')
				{
					orgGroups.push(obj);
				}
				
				// remove all the non-allowed groups from the power users.
				if(_model.userLevel == 'power')
				{
					for( var groupID:String in _model.session.groups )
					{
						if(groupID == item.id)
						{
							orgGroups.push(obj);
						}	
					}
				}
			}
			
			_model.allGroupsList = allGroupsList;
			_model.orgGroups = orgGroups;
			_model.orgGroups.sortOn('label');
		}
		
		private function onFault_getGroups(event:Object):void
		{
			if(_model.debug){ Logger.info('Fail Get Groups', ObjectUtil.toString(event)); }
		
			_model.dataLoading = false;
		}					


		/**
		 * Get the Amazon s3 credentials
		 */
		private function getS3credentials(event:S3Event):void
		{
			var handlers : IResponder = new mx.rpc.Responder(onResults_getS3credentials, onFault_getS3credentials);
			var delegate:S3Delegate = new S3Delegate(handlers);
			
			delegate.get_credentials();
		}

		private function onResults_getS3credentials(event:Object):void
		{
			if(_model.debug) Logger.info('Success getS3credentials', ObjectUtil.toString(event.result));
			
			_model.s3vo = new S3VO ( event.result );
		}
		
		private function onFault_getS3credentials(event:Object):void
		{
			if(_model.debug) Logger.info('Fail getS3credentials', ObjectUtil.toString(event));
		}
		
		
		/**
		 * Handle the actions needed when the session, layout and groups are all loaded successfully
		 */
		private function handleSuccessfulLoad():void
		{
			// test to see if the requested module is in the allowed list
			if(_model.allowedModules.getItemIndex(_model.viewStateList[_model.firstModule]) == -1)
				_model.firstModule = 0;
			
			// set the main container to the correct module	
			_model.screenState = EAModelLocator.MAIN_SCREEN;
			_model.mainViewState = _model.firstModule;
			_model.mainScreenVisible = true;

			// initialise the first view module
			_model.runInit = true;				

			// some debugging
			if(_model.debug) 
			{
				Logger.info(
					'handleSuccessfulLoad', 
					_model.firstModule, 
					_model.browserManager.fragment, 
					_model.viewStateList[_model.firstModule]
				);
			}

			// set the fragment if it needs changing
			if(_model.firstModule == 0)
				_model.browserManager.setFragment(_model.viewStateList[_model.firstModule]);
	
			// set the title
			_model.browserManager.setTitle(_model.appName + ' - ' + _model.viewStateNames[_model.firstModule]);			
		}
		

		/**
		 * Get the users table layout to build the form
		 */			
		private function getLayouts(event:RecordEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getLayouts, onFault_getLayouts);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getLayouts();			
		}
				
		private function onResult_getLayouts(event:Object):void 
		{
			if(_model.debug) Logger.info(' getLayouts Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			// loop through the tables and add them to the struktorLayout view class
			for each ( var table:Object in event.result )
				if(_model.struktorLayout.hasOwnProperty(table.table))
					_model.struktorLayout[table.table] = new StruktorLayoutVO(table);
			
			// tell the model that the layouts are in place	
			_model.struktorLayout.loaded = true;	

			this.nextEvent = new GetSiteLayoutEvent();
			this.executeNextCommand();
			this.nextEvent = null;
		}
		
		public function onFault_getLayouts(event:Object):void
		{
			if(_model.debug) Logger.info('getLayouts Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}
		
	}
}