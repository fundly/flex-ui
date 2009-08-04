package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	
	public class GroupsProfilesDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function GroupsProfilesDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
		}

		public function listUsersGroups( userID:int ):void
		{
			if(_model.debug) Logger.info('List a users groups', userID)
			
			var token:AsyncToken = service.list_users_groups( userID );
			token.addResponder(this.responder);			
		}
		
		public function listGroups():void
		{
			if(_model.debug) Logger.info('List groups')
			
			var token:AsyncToken = service.list_groups();
			token.addResponder(this.responder);			
		}
		
		public function listProfiles():void
		{
			if(_model.debug) Logger.info('List profiles')
			
			var token:AsyncToken = service.list_profiles();
			token.addResponder(this.responder);			
		}
		
		public function addUserToInstance( email:String, fname:String, lname:String ):void
		{
			if(_model.debug) Logger.info('Add User To Instance')
			
			var token:AsyncToken = service.add_user( email, fname, lname );
			token.addResponder(this.responder);			
		}
		
		public function addUserToGroups( userID:int, groupIDs:Array):void
		{
			if(_model.debug) Logger.info('Add User To Groups')
			
			var token:AsyncToken = service.add_user_to_groups( userID, groupIDs );
			token.addResponder(this.responder);			
		}		
		
		public function addUserToProfile( email:String, profileID:Number):void
		{
			if(_model.debug) Logger.info('Add User To Profile')
			
			var token:AsyncToken = service.add_user_to_profile( email, profileID );
			token.addResponder(this.responder);			
		}				
		
		public function deleteUserFromGroups(userID:int, groupIDs:Array):void
		{
			if(_model.debug) Logger.info('Remove User From Groups')
			
			var token:AsyncToken = service.delete_user_from_groups( userID, groupIDs );
			token.addResponder(this.responder);			
		}		
		
		public function deleteUserFromProfile( email:String, profileID:Number):void
		{
			if(_model.debug) Logger.info('Delete Profile From User')
			
			var token:AsyncToken = service.delete_profile_from_user( email, profileID );
			token.addResponder(this.responder);			
		}	
		
							
		public function getUserACL( userID:int ):void
		{
			if(_model.debug){ Logger.info('Get User ACL', userID); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.get_user_acl( userID );
			token.addResponder(this.responder);
		}		

		public function setUserACL( userID:int, acl:Object  ):void
		{
			if(_model.debug){ Logger.info('Set User ACL', userID, acl); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.set_user_acl( userID, acl );
			token.addResponder(this.responder);
		}		

		public function addPowerUser( userID:int ):void
		{
			if(_model.debug){ Logger.info('Add Power User', userID); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.add_user_poweruser( userID );
			token.addResponder(this.responder);
		}

		public function delPowerUser( userID:int ):void
		{
			if(_model.debug){ Logger.info('Del Power User', userID); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.delete_user_from_poweruser( userID );
			token.addResponder(this.responder);
		}

		public function addSuperUser( userID:int ):void
		{
			if(_model.debug){ Logger.info('Add Super User', userID); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.add_user_superuser( userID );
			token.addResponder(this.responder);
		}

		public function delSuperUser( userID:int ):void
		{
			if(_model.debug){ Logger.info('Del Super User', userID); }

			this.service = ServiceLocator.getInstance().getRemoteObject('authentikatorManagement');
			
			var token:AsyncToken = service.delete_user_from_superuser( userID );
			token.addResponder(this.responder);
		}


	}
}