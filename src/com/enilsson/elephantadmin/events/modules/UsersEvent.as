package com.enilsson.elephantadmin.events.modules
{
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	
	import flash.events.Event;

	public class UsersEvent extends RecordModuleEvent
	{
		static public const INVITATION_SEND:String 			= 'invitation_send';
		static public const INVITATION_GET_TEMPLATE:String 	= 'invitationGetTemplate';
		static public const GET_GROUPS:String 				= 'usersGetGroups';		
		static public const ADD_GROUPS:String 				= 'usersAddGroups';
		static public const DEL_GROUPS:String 				= 'usersDelGroups';
		static public const GET_ACL:String 					= 'usersGetAcl';		
		static public const SET_ACL:String 					= 'usersSetAcl';
		static public const GET_UI_RIGHTS:String			= 'usersGetUIRights';
		static public const SET_UI_RIGHTS:String			= 'usersSetUIRights';		
		static public const USERS_EXPORT:String 			= 'usersExport';		
		static public const USERS_DELETE:String 			= 'usersDelete';		
		static public const USERS_ENABLE:String 			= 'usersEnable';		
		static public const USERS_DISABLE:String 			= 'usersDisable';		
		static public const RESET_PASSWORD:String 			= 'userResetPassword';		
		static public const GET_PLEDGES:String 				= 'usersGetPledges';
		static public const ADD_POWER_USER:String 			= 'usersAddPowerUser';
		static public const DEL_POWER_USER:String 			= 'usersDelPowerUser';
		static public const ADD_SUPER_USER:String 			= 'usersAddSuperUser';
		static public const DEL_SUPER_USER:String 			= 'usersDelSuperUser';
		static public const GET_USER_EMAIL:String 			= 'usersUserEmail';
		static public const GET_USER_CONTACT:String 		= 'usersUserContact';
		static public const USERS_UPSERT_CONTACT:String 	= 'usersUpsertContact';
		static public const ADMIN_CHANGE_EMAIL:String 		= 'usersAdminChangeEmail';
		static public const CREATE_USER:String 				= 'usersCreateUser';

		public function UsersEvent( type:String, model:RecordModel, vo:Object = null )
		{
			super( type , model , vo);
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return UsersEvent( super.clone() );
		}
	}
}