package com.enilsson.elephantadmin.views.modules.users.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephantadmin.events.modules.RecordModuleEvent;
	import com.enilsson.elephantadmin.events.modules.UsersEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.views.modules.users.popups.*;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	[Bindable]
	public class UsersModel extends RecordModel
	{
		public var pledges:ArrayCollection;

		public var optionsTabLoading:Boolean;
		public var accessTabLoading:Boolean;
		public var accessAclLoading:Boolean;
		public var accessGroupLoading:Boolean;
		public var pledgesTabLoading:Boolean;

		/**
		 * User Access Tab Variables
		 */
		public var dgGroups:ArrayCollection;
		public var userGroups:Array;
		public var locationGroupText:String;
		public var userLevelList:Array = [{label:'BASE',data:'base'},{label:'POWER',data:'power'},{label:'SUPER',data:'super'}];
		
		/**
		 * User level of the person selected
		 */
		public var userLevelSelectedIndex:int;

		public function get orgGroups():Array
		{
			return EAModelLocator(mainModel).orgGroups;
		}
		
		/**
		 * The user level of the person logged in
		 */
		public function get userLevel():String
		{
			return EAModelLocator(mainModel).userLevel;
		}

		/**
		 * Get the Client UI url from the main model
		 */
		public function get clientUI():String
		{
			return EAModelLocator(mainModel).clientUI;
		}

		/**
		 * ACL Popup Variables
		 */
		public var userACL:Object;
		public var aclPermissions:ArrayCollection;
		public var permissionsName:Array = ['Read','Write','Modify','Del','Export','Restore','Search','RLAC','Auditing'];

		/**
		 * Add User Popup Variables
		 */
		public var formState:String = 'hideMsg';
		
		/**
		 * Variables used to mask the sender details
		 */
		public var senderEmail:String = '';
		public var senderFname:String = '';
		public var senderLname:String = '';
		public var email:String = '';
		public var fname:String = '';
		public var lname:String = '';
		public var subject:String = '';
		public var message:String = '';
		public var errorVO:ErrorVO;

		public var invitationTemplate:ObjectProxy;
		public var selectedEmails:Array = new Array();
		public var isSubmitting:Boolean = false;
		public var sendingInvitation:Boolean = false;
		public var onClose:Function;

		/**
		 * User Options Tab Variables
		 */
		public var userEmail:String;
		public var userContactRecord:Object;

		public function UsersModel(parentModel:ModelLocator=null)
		{
			super(parentModel);
			_allowAddNewRecord = true;
			_excludedFields = ['_itemsperpage'];
			_addNewRecordLabel = 'ADD USER';
			whereFilterObject = { 
				'what' : 'tr_users.user_id',
				'val' : '-99',
				'op' : '>'
			};
		}

		/**
		 * Grab the getRecordsDetail event and insert some users specific actions
		 */
		override protected function getRecordDetails():void
		{
			super.getRecordDetails();
			
			loadOptionsTab();
			loadPledgesTab();
			loadAccessTab();
			
			Logger.info('Users Information', ObjectUtil.toString( selectedRecord ));
		}

		/**
		 * Override the add record behaviour
		 */
		override public function addNewRecord():void
		{
			var addUserPopUp:Users_Add = new Users_Add();
			addUserPopUp.presentationModel = this;

			addUserPopUp.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void{
				PopUpManager.removePopUp(Users_Add(e.currentTarget));
			});
			
			PopUpManager.addPopUp(addUserPopUp, DisplayObject(Application.application), true);
			PopUpManager.centerPopUp(addUserPopUp);
		}

		/**
		 * Show the popup to manage the ACL record
		 */
		public function manageACL():void
		{
			var aclPopUp:Users_ACL = new Users_ACL();
			aclPopUp.presentationModel = this;
			aclPopUp.width = Application.application.stage.width - 40;
			aclPopUp.height = Application.application.stage.height - 40;

			aclPopUp.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void{
				PopUpManager.removePopUp(Users_ACL(e.currentTarget));
			});
			PopUpManager.addPopUp(aclPopUp, DisplayObject(Application.application), true);
			PopUpManager.centerPopUp(aclPopUp);
		}

		/**
		 * Get the appropriate data and build the pledges tab
		 */
		private function loadPledgesTab():void
		{
			pledgesTabLoading = true;
			pledges = new ArrayCollection();
			
			var esql:String = 'pledges(';
			esql += 'event_id,contact_id<email>,';
			esql += 'transactions<amount:full_name:card_number:card_number_type:created_on:transactionid:address:city:state:zip>,';
			esql += 'checks<ALL>,';
			esql += 'paypal_transactions<amount:created_on:transactionid>';
			esql += ')';
			
			var where:Object = {
				'statement' : '(1)',
				'1':{ 
						'what' : 'pledges.tr_users_id',
						'val' : recordID,
						'op' : '='
					}
			};

			var recordsVO:RecordsVO = new RecordsVO( esql, where );

			new UsersEvent(UsersEvent.GET_PLEDGES, this, recordsVO).dispatch();
		}

		private function loadAccessTab():void
		{
			accessTabLoading = true;

			// get the acl for this user
			accessAclLoading = true;
			new UsersEvent( UsersEvent.GET_ACL, this, { 'userID' : recordID } ).dispatch();

			// get the groups for this user
			accessGroupLoading = true;
			new UsersEvent( UsersEvent.GET_GROUPS, this, { 'userID' : recordID } ).dispatch();
		}

		private function loadOptionsTab():void
		{
			// get the contact record for this users
			if ( selectedRecord._contact_id )
			{
				optionsTabLoading = true;
				new UsersEvent( UsersEvent.GET_USER_CONTACT, this, { 'contactID' : selectedRecord._contact_id } ).dispatch();	
			}
		}

		public function updateAccess(value:Array):void
		{
			var delList:Array = [];
			var addList:Array = [];
			for each(var group:Object in dgGroups)
			{
				// If group is selected and the user was not already part of the group
				if(group.included && userGroups.indexOf(group.value) == -1)
					addList.push(group.value);
				// If group is unselected and the user was already part of the group
				else if(!group.included && userGroups.indexOf(group.value) > -1)
					delList.push(group.value);
			}
			new UsersEvent( UsersEvent.DEL_GROUPS, this, { 'userID' : recordID, 'groupIDs' : delList } ).dispatch();
			new UsersEvent( UsersEvent.ADD_GROUPS, this, { 'userID' : recordID, 'groupIDs' : addList } ).dispatch();

			// set the user's user access level if super user
			if(userLevel == 'super')
			{
				switch(userLevelSelectedIndex)
				{
					case 0: // If base user selected
						if(userACL.hasOwnProperty('system_super'))
							new UsersEvent( UsersEvent.DEL_SUPER_USER, this, { 'userID' : recordID } ).dispatch();
						if(userACL.hasOwnProperty('system_power'))
							new UsersEvent( UsersEvent.DEL_POWER_USER, this, { 'userID' : recordID } ).dispatch();
						break;
					case 1: // If power user selected
						new UsersEvent( UsersEvent.ADD_POWER_USER, this, { 'userID' : recordID } ).dispatch();
						if(userACL.hasOwnProperty('system_super'))
							new UsersEvent( UsersEvent.DEL_SUPER_USER, this, { 'userID' : recordID } ).dispatch();
						break;
					case 2: // If super user selected
						new UsersEvent( UsersEvent.ADD_SUPER_USER, this, { 'userID' : recordID } ).dispatch();
						if(userACL.hasOwnProperty('system_power'))
							new UsersEvent( UsersEvent.DEL_POWER_USER, this, { 'userID' : recordID } ).dispatch();
						break;
				}
			}
			// Refresh with data from server
			loadAccessTab();
		}
		
		
		/**
		 * Override the upsertRecord method to insert some users specific logic
		 */
		override public function upsertRecord(formVariables:Object):void
		{
			// save the form variables so they can be used later
			this.formVariables = ObjectUtil.copy( formVariables );

			// do nothing if there is no change in the data
			if(this.formVariables == selectedRecord) return;

 			// if there is a contact record existing just upsert the user data
			if ( selectedRecord._contact_id > 0 )
			{
				new RecordModuleEvent( 
					RecordModuleEvent.UPSERT,
					this,
					new RecordVO ( table, 0, formVariables )
				).dispatch();
			}
			
			// upsert the contact data 
			else
			{
				var cd:Object = new Object();
				
				// build the contact details array
				cd['lname'] 		= formVariables['lname'];	
				cd['fname'] 		= formVariables['fname'];	
				cd['zip'] 			= formVariables['_zip'];	
				cd['city'] 			= formVariables['_city'];	
				cd['address1'] 		= formVariables['_address1'];	
				cd['address2'] 		= formVariables['_address2'];	
				cd['state'] 		= formVariables['_state'];
				
				// remove the id from the contact details just in case...
				delete cd['id'];
			
				new UsersEvent (
					UsersEvent.USERS_UPSERT_CONTACT,
					this,
					{ contactData : cd, userID : selectedRecord['user_id'] }
				).dispatch();
			}
 
 		}
	}
}