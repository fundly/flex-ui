package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.AuthentikatorDelegate;
	import com.enilsson.elephantadmin.business.GroupsProfilesDelegate;
	import com.enilsson.elephantadmin.business.PluginsDelegate;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.events.modules.RecordModuleEvent;
	import com.enilsson.elephantadmin.events.modules.UsersEvent;
	import com.enilsson.elephantadmin.events.session.SessionFailEvent;
	import com.enilsson.elephantadmin.views.modules.users.model.UsersModel;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.NewUserVO;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class UsersCommand extends RecordModuleCommand
	{
		private var _usersModel:UsersModel;
		
		public function UsersCommand()
		{
			super();
			_moduleName = 'Users';
		}
		
		override public function execute(event:CairngormEvent):void
		{
			super.execute(event);

			_usersModel = UsersModel(_presentationModel);

			switch(event.type)
			{
				case UsersEvent.GET_PLEDGES :
					getPledges(event as UsersEvent);
				break;
				case UsersEvent.USERS_DELETE :
					deleteUserRecord(event as UsersEvent);
				break;
				case UsersEvent.GET_GROUPS :
					getGroups(event as UsersEvent);
				break;
				case UsersEvent.ADD_GROUPS :
					addGroups(event as UsersEvent);
				break;
				case UsersEvent.DEL_GROUPS :
					delGroups(event as UsersEvent);
				break;
				case UsersEvent.GET_ACL :
					getACL(event as UsersEvent);
				break;
				case UsersEvent.SET_ACL :
					setACL(event as UsersEvent);
				break;
				case UsersEvent.INVITATION_SEND:
					sendInvitation(event as UsersEvent);
				break;
				case UsersEvent.INVITATION_GET_TEMPLATE:
					getTemplate(event as UsersEvent);
				break;
				case UsersEvent.USERS_EXPORT:
					exportTable(event as UsersEvent);
				break;
				case UsersEvent.USERS_DISABLE:
					disableUser(event as UsersEvent);
				break;
				case UsersEvent.USERS_ENABLE:
					enableUser(event as UsersEvent);
				break;
				case UsersEvent.RESET_PASSWORD:
					forgot(event as UsersEvent);
				break;
				case UsersEvent.ADD_POWER_USER:
					addPowerUser(event as UsersEvent);
				break;
				case UsersEvent.DEL_POWER_USER:
					delPowerUser(event as UsersEvent);
				break;
				case UsersEvent.ADD_SUPER_USER:
					addSuperUser(event as UsersEvent);
				break;
				case UsersEvent.DEL_SUPER_USER:
					delSuperUser(event as UsersEvent);
				break;
				case UsersEvent.GET_USER_EMAIL:
					getUserEmail(event as UsersEvent);
				break;
				case UsersEvent.GET_USER_CONTACT:
					getUserContact(event as UsersEvent);
				break;
				case UsersEvent.USERS_UPSERT_CONTACT:
					upsertContact(event as UsersEvent);
				break;
				case UsersEvent.ADMIN_CHANGE_EMAIL :
					adminChangeEmail( event as UsersEvent );
				break;
			}
		}

		private function getPledges(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getPledges, onFault_getPledges);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);

			_model.dataLoading = true;

			delegate.getRecords(event.recordsVO);
		}

		private function onResults_getPledges(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading User\'s Pledges Success', ObjectUtil.toString(data.result));

			// assign some variables
			var pledges:ArrayCollection = new ArrayCollection()
			for each(var item:Object in data.result.pledges)
			{
				var contributions:ArrayCollection = new ArrayCollection();
				if(item.transactions[1])
				{
					for each(var transaction:Object in item.transactions)
					{
						transaction.type = "Credit Card";
						contributions.addItem(transaction);
					}
				}
				if(item.checks[1])
				{
					for each(var check:Object in item.checks)
					{
						if(check.entry_date != "0")
						{
							check.type = "Check";
							contributions.addItem(check);
						}
					}
				}
				if(item.paypal_transactions[1])
				{
					for each(var paypal:Object in item.paypal_transactions)
					{
						paypal.type = "PayPal";
						contributions.addItem(paypal);
					}
				}
				if(contributions.length > 0)
					item.contributions = contributions;

				pledges.addItem(item);
			}

			_usersModel.pledges = pledges;

			// hide the data loading graphic
			_model.dataLoading = false;
			_usersModel.pledgesTabLoading = false;
		}
			
		private function onFault_getPledges(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Loading User\'s Pledges Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem loading pledges from this record:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Delete a record
		 */			
		private function deleteUserRecord(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteUserRecord, onFault_deleteUserRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			_usersModel.formProcessing = true;

			// Save the index of the current list to display the same record after reloading the list
			_usersModel.searchListLastIndex = _usersModel.searchListSelectedIndex;

			delegate.deleteRecord( event.recordVO );			
		}
				
		private function onResults_deleteUserRecord(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteUserRecord Success', ObjectUtil.toString(event.result));
			
			_usersModel.formProcessing = false;

			switch(event.result.state)
			{
				case '88' :
					_model.errorVO = new ErrorVO(_moduleName + ' record deleted successfully!', 'successBox', true );
					// refresh the users list
					_usersModel.lastQuery.dispatch();
					break;
				case '-88' :			
					var eMsg:String = '';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}
		
		private function onFault_deleteUserRecord(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteUserRecord Fail', ObjectUtil.toString(event));		
			
			// hide the processing indicator
			_usersModel.formProcessing = false;
			
			var faultString:String = '';
			switch(event.fault.faultCode)
			{
				case '5':
					faultString = event.fault.faultString;
					_model.errorVO = new ErrorVO( 
								'There was a problem processing this user:<br><br>' + faultString, 
								'errorBox', 
								true 
							);					
				break;
				default:
					// run the session fail event
					this.nextEvent = new SessionFailEvent( event.fault.faultCode );
					this.executeNextCommand();
					this.nextEvent = null;
				break;
			}
		}

		/**
		 * Get the users groups
		 */			
		private function getGroups(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getGroups, onFault_getGroups);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.listUsersGroups( event.params.userID );
		}
		
		private function onResults_getGroups(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('getGroups Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			_usersModel.dgGroups = new ArrayCollection();
			_usersModel.userGroups = [];

			for each ( var orgGrp:Object in _usersModel.orgGroups )
			{
				orgGrp['included'] = false;
				
				for each ( var userGrp:Object in event.result )
					if ( orgGrp.value == userGrp.group_id )
					{
						orgGrp.included = true;
						// set current user groups
						_usersModel.userGroups.push(orgGrp.value);
					}

				if ( orgGrp.value == _usersModel.selectedRecord.mod_group_id)
					_usersModel.locationGroupText = 'Regional Group: <b>' + orgGrp.label + '</b>';
				else
					_usersModel.dgGroups.addItem( orgGrp );
			}

			_usersModel.accessGroupLoading = false;
			if(!_usersModel.accessAclLoading)
				_usersModel.accessTabLoading = false;
		}
		
		public function onFault_getGroups(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('getGroups Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem loading groups from this user:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Set the users groups
		 */			
		private function addGroups(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_addGroups, onFault_addGroups);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.addUserToGroups( event.params.userID, event.params.groupIDs );
		}
		
		private function onResults_addGroups(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('addGroup Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
		}
		
		public function onFault_addGroups(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('addGroup Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}

		/**
		 * Set the users groups
		 */			
		private function delGroups(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_delGroups, onFault_delGroups);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.deleteUserFromGroups( event.params.userID, event.params.groupIDs );
		}
		
		private function onResults_delGroups(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('delGroups Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
		}
		
		public function onFault_delGroups(event:Object):void
		{
			if(_model.debug) Logger.info('delGroups Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}


		/**
		 * Get the users acl
		 */			
		private function getACL(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getACL, onFault_getACL);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getUserACL( event.params.userID );
		}
		
		private function onResults_getACL(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('getACL Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;

			_usersModel.userACL = event.result;
			_usersModel.aclPermissions = new ArrayCollection();

			for each(var item:Object in _model.aclLayout)
			{
				for (var i:uint=0;i<_usersModel.permissionsName.length;i++)	
					item[_usersModel.permissionsName[i].toString().toLowerCase()] = event.result[item.table] ? eNilssonUtils.safeBitCheck(event.result[item.table],Math.pow(2,i)) : false;
				
				_usersModel.aclPermissions.addItem(item);
			}
			if(event.result.hasOwnProperty('system_super'))
				_usersModel.userLevelSelectedIndex = 2;
			else if(event.result.hasOwnProperty('system_power'))
				_usersModel.userLevelSelectedIndex = 1;
			else
				_usersModel.userLevelSelectedIndex = 0;

			_usersModel.accessAclLoading = false;
			if(!_usersModel.accessGroupLoading)
				_usersModel.accessTabLoading = false;
		}
		
		public function onFault_getACL(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('getACL Fail', ObjectUtil.toString(event));

			_model.errorVO = new ErrorVO( 
				'There was a problem loading ACL from this user:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);

			_model.dataLoading = false;
		}


		/**
		 * Set the users acl
		 */			
		private function setACL(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_setACL, onFault_setACL);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.setUserACL( event.params.userID, event.params.acl );
		}
		
		private function onResults_setACL(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('setACL Success', ObjectUtil.toString(event.result));

			_usersModel.errorVO = new ErrorVO( 
				'The new ACL permissions were successfully set for this user', 
				'successBox', 
				true 
			);

			_model.dataLoading = false;

		}
		public function onFault_setACL(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('setACL Fail', ObjectUtil.toString(event));

			_usersModel.errorVO = new ErrorVO( 
				'There was a problem setting ACL permissions on this user:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);

			_model.dataLoading = false;
		}

		/**
		 * Disable user account
		 */			
		private function disableUser(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_disableUser, onFault_disableUser);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);

			// Save the index of the current list to display the same record after reloading the list
			_usersModel.searchListLastIndex = _usersModel.searchListSelectedIndex;
			_model.dataLoading = true;
				
			delegate.disableUser( event.params.userID );
		}
		private function onResults_disableUser(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('disable user Success', ObjectUtil.toString(event.result));
			
			_usersModel.lastQuery.dispatch();

			_model.dataLoading = false;

		}
		public function onFault_disableUser(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('disable user Fail', ObjectUtil.toString(event));

			_model.dataLoading = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem disabling this user\'s access:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Enable user account
		 */			
		private function enableUser(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_enableUser, onFault_enableUser);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);

			// Save the index of the current list to display the same record after reloading the list
			_usersModel.searchListLastIndex = _usersModel.searchListSelectedIndex;
			_model.dataLoading = true;
				
			delegate.enableUser( event.params.userID );			
		}
		private function onResults_enableUser(event:Object):void 
		{
			if(_model.debug) Logger.info('enable user Success', ObjectUtil.toString(event.result));

			_usersModel.lastQuery.dispatch();

			_model.dataLoading = false;

		}
		public function onFault_enableUser(event:Object):void
		{
			if(_model.debug) Logger.info('enable user Fail', ObjectUtil.toString(event));

			_model.dataLoading = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem enabling this user\'s access:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Get records from the users table
		 */
		private function getTemplate(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getTemplate, onFault_getTemplate);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.selectRecord( event.recordVO );
		}
				
		private function onResults_getTemplate(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Invitation getTemplate Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;

			var tableName:String = event.result.table_name;
			_usersModel.invitationTemplate = event.result[tableName][1];
		}
		
		public function onFault_getTemplate(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Invitation getTemplate Fail', ObjectUtil.toString(event.fault));
			
			_model.dataLoading = false;
		}
		

	/**
		 * Send invitation email to new fundraiser
		 */
		private function sendInvitation(event:UsersEvent):void
		{
			if(_model.debug) Logger.info('sendInvitation');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_sendInvitation, onFault_sendInvitation);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;

			// tells that is submitting the form
			_usersModel.isSubmitting = true;

			// show the message that is sending the emails
			_usersModel.sendingInvitation = true;

			if(_model.debug) Logger.info('sendInvitation',event.params.emailVO);

			delegate.sendInvitation(event.params.emailVO);
		}

		private function onResults_sendInvitation(event:Object):void 
		{
			if(_model.debug) Logger.info('sendInvitation Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			
			// remove the message that is sending the emails
			_usersModel.sendingInvitation = false;
			
			if (event.result.state === true)
				_usersModel.errorVO = new ErrorVO( 'The invitation was successfully sent', 'successBox', true );
			else
				_usersModel.errorVO = new ErrorVO( 'There was an error trying to send the invitation<br><br>- ' + event.result.error, 'errorBox', true );
			
			_usersModel.onClose = function():void {
				_usersModel.isSubmitting = false;
			}
		}

		private function onFault_sendInvitation(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('sendInvitation Fault', ObjectUtil.toString(event.fault));	

			// remove the message that is sending the emails
			_usersModel.sendingInvitation = false;

			_usersModel.errorVO = new ErrorVO( 'There was an error processing this invitation!<br><br>- ' + event.fault.message, 'errorBox', true );

			_usersModel.onClose = function():void {
				_usersModel.isSubmitting = false;
			}
			
			_model.dataLoading = false;
		}

		/**
		 * Export the table
		 */			

		private function exportTable(event:UsersEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportTable, onFault_exportTable);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true

			delegate.exportRecords(event.recordVO);
		}

		private function onResults_exportTable(data:Object):void 
		{
			if(_model.debug) Logger.info('exportTables Success', ObjectUtil.toString(data.result));
			
			navigateToURL(new URLRequest(_model.gatewayBaseURL + '/export.php?id='+data.result),'_parent');
			
			_model.dataLoading = false;
		}	

		private function onFault_exportTable(data:Object):void
		{
			if(_model.debug) Logger.info('exportTables Fault', ObjectUtil.toString(data.fault));
			
			_model.dataLoading = false;
		}

		/**
		 * Login procedures
		 */	
		private function forgot(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_forgot, onFault_forgot);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.forgot( event.params.loginVO, _model.appInstanceID );
		}
		private function onResults_forgot(event:Object):void 
		{
			if(_model.debug) Logger.info('Forget details Event Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;

			if (event.result) 
				_model.errorVO = new ErrorVO('A password reset email has been successfully sent to the account.','successBox',true);
			else 
				_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}

		public function onFault_forgot(event:Object):void
		{
			if(_model.debug) Logger.info('Forget details Event', ObjectUtil.toString(event));
			_model.dataLoading = false;

			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}


		/**
		 * Add Power user
		 */	
		private function addPowerUser(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_addPowerUser, onFault_addPowerUser);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.addPowerUser( event.params.userID );
		}
		
		private function onResults_addPowerUser(event:Object):void 
		{
			if(_model.debug) Logger.info('addPowerUser Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
		}
		
		public function onFault_addPowerUser(event:Object):void
		{
			if(_model.debug) Logger.info('addPowerUser fault', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}

		/**
		 * Del Power user
		 */	
		private function delPowerUser(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_delPowerUser, onFault_delPowerUser);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.delPowerUser( event.params.userID );
		}
		
		private function onResults_delPowerUser(event:Object):void 
		{
			if(_model.debug) Logger.info('delPowerUser Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;

		}
		
		public function onFault_delPowerUser(event:Object):void
		{
			if(_model.debug) Logger.info('delPowerUser fault', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}


		/**
		 * Add Super user
		 */	
		private function addSuperUser(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_addSuperUser, onFault_addSuperUser);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.addSuperUser( event.params.userID );
		}
		
		private function onResults_addSuperUser(event:Object):void 
		{
			if(_model.debug) Logger.info('addSuperUser Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
		}
		
		public function onFault_addSuperUser(event:Object):void
		{
			if(_model.debug) Logger.info('addSuperUser fault', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}


		/**
		 * Del Super user
		 */	
		private function delSuperUser(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_delSuperUser, onFault_delSuperUser);
			var delegate:GroupsProfilesDelegate = new GroupsProfilesDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.delSuperUser( event.params.userID );
		}
		
		private function onResults_delSuperUser(event:Object):void 
		{
			if(_model.debug) Logger.info('delSuperUser Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
		}
		
		public function onFault_delSuperUser(event:Object):void
		{
			if(_model.debug) Logger.info('delSuperUser fault', ObjectUtil.toString(event));
			_model.dataLoading = false;
			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}
		

		/**
		 * Get user's email address
		 */	
		private function getUserEmail(event:UsersEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getUserEmail, onFault_getUserEmail);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.getUserEmail( event.params.userID );
		}
		
		private function onResults_getUserEmail(event:Object):void 
		{
			if(_model.debug) Logger.info('getUserEmail Success', ObjectUtil.toString(event.result));
			
			_usersModel.userEmail = event.result;
			_usersModel.optionsTabLoading = false;
			_model.dataLoading = false;
		}
		
		public function onFault_getUserEmail(event:Object):void
		{
			if(_model.debug) Logger.info('getUserEmail fault', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
			_usersModel.optionsTabLoading = false;
			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}
		

		/**
		 * Get user's contact record
		 */	
		private function getUserContact( event:UsersEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getUserContact, onFault_getUserContact);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.selectRecord( new RecordVO( 'contacts<fname:lname>', event.params.contactID ) );
		}
		
		private function onResults_getUserContact(event:Object):void 
		{
			if(_model.debug) Logger.info('getUserContact Success', ObjectUtil.toString(event.result));
			
			_usersModel.userContactRecord = event.result.contacts['1'];
			_usersModel.optionsTabLoading = false;
			_model.dataLoading = false;
		}
		
		public function onFault_getUserContact(event:Object):void
		{
			if(_model.debug) Logger.info('getUserContact fault', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
			_usersModel.optionsTabLoading = false;
			_model.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}

		
		/**
		 * Upsert a contact record if one does not exist
		 */
		private function upsertContact( event:UsersEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertContact, onFault_upsertContact);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;
			_presentationModel.formProcessing = true;
			
			delegate.upsertContact( event.params.contactData, event.params.userID  );
		}
		
		private function onResults_upsertContact( event:Object ):void 
		{
			if(_model.debug) Logger.info('Upsert Users Contact Success', ObjectUtil.toString(event.result));
			
			switch(event.result.state)
			{
				case '98' :
				case '99' :
					_usersModel.selectedRecord['_contact_id'] = event.result.details;
					_usersModel.formVariables['_contact_id'] = event.result.details;
					
					var r:RecordVO = new RecordVO( _usersModel.table, 0, _usersModel.formVariables );
					
					this.nextEvent = new RecordModuleEvent ( RecordModuleEvent.UPSERT, _usersModel, r );
					this.executeNextCommand();
					this.nextEvent = null;										
				break;
				case '-99' :				
					var eMsg:String = '';
					if (event.result.errors is Array) 
					{
						for(var i:String in event.result.errors)
							eMsg += '- ' + event.result.errors[i] + '<br>'
					}
					else
						eMsg = event.result.errors;
						
					_model.dataLoading = false;
					_presentationModel.formProcessing = false;
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing these details:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}	
		
		private function onFault_upsertContact( event:Object ):void
		{
			if(_model.debug) Logger.info('upsert Users Contact Fault', ObjectUtil.toString(event.fault));

			_model.errorVO = new ErrorVO( 'There was an error processing your details!' + event.fault, 'errorBox', true );						
			_model.dataLoading = false;
			_presentationModel.formProcessing = false;
		}	


		/**
		 * Change a users email.
		 */	
		private function adminChangeEmail( event:UsersEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_adminChangeEmail, onFault_adminChangeEmail);
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(handlers);
			
			_model.dataLoading = true;
	
			Logger.info('adminChangeEmail params', ObjectUtil.toString(event.params));
		
			delegate.adminChangeEmail( event.params.email, event.params.userID );
		}
		
		private function onResults_adminChangeEmail(event:Object):void 
		{
			if(_model.debug) Logger.info('adminChangeEmail Success', ObjectUtil.toString(event.result));
			
			if ( event.result.state ) 
			{
				_usersModel.errorVO = new ErrorVO( 'That email was successfully changed!', 'successBox', true );
				_usersModel.userEmail = event.result.email;
			}
			else
				_usersModel.errorVO = new ErrorVO( 'There was an error changing this email!' + event.result.error, 'errorBox', true );
			
			_model.dataLoading = false;
		}
		
		public function onFault_adminChangeEmail(event:Object):void
		{
			if(_model.debug) Logger.info('adminChangeEmail fault', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
			_usersModel.errorVO = new ErrorVO('Internet connection error, please check before trying again!.','errorBox',true);
		}

		
	}
}