package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.AdminPledgeVO;
	import com.enilsson.elephantadmin.vo.EmailVO;
	import com.enilsson.elephantadmin.vo.NewUserVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class PluginsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function PluginsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function get_downline( userID:Number, depth:int = 4 ):void
		{	
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsDownline');
			
			var token:AsyncToken = service.get_downline( userID, depth );
			token.addResponder(responder);
		}

		public function get_contact( contactID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.list_contacts(contactID, null, null, 0 , 1, null);
			token.addResponder(responder);
		}

		public function sendInvitation(emailVO:EmailVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
		
		
			var token:AsyncToken = service.send_invite( 
										emailVO.addresses,
										emailVO.fname,
										emailVO.lname,
										emailVO.templateID,
										emailVO.templateVars,
										emailVO.senderName,
										emailVO.senderEmail,
										emailVO.subject,
										emailVO.addDownline
			);
			token.addResponder(responder);
		}

		public function createNewUser(vo:NewUserVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
		
			var token:AsyncToken = service.add_fundraiser( 
										{
											fname:vo.fname
											,lname:vo.lname
											,email: vo.email
											,address1:vo.address1
											,address2:vo.address2
											,city:vo.city
											,state:vo.state
											,zip:vo.zip
											,phone:vo.phone
										}
										,vo.addDownline
			);
			token.addResponder(responder);
		}

		public function sendSystemEmail(emailVO:EmailVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_system_email(
										emailVO.addresses,
										emailVO.content,
										emailVO.templateID,
										emailVO.templateVars,
										emailVO.attachmentList,
										emailVO.logged
										);
			token.addResponder(responder);
		}

		public function sendUserEmail(emailVO:EmailVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_user_email(
										{to:emailVO.addresses},
										emailVO.subject,
										emailVO.content,
										emailVO.templateID,
										emailVO.attachmentList,
										emailVO.logged
										);
			token.addResponder(responder);
		}

		public function sendTestEmail(emailVO:EmailVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_test_email(
										emailVO.addresses,
										emailVO.subject,
										emailVO.content,
										emailVO.templateVars,
										emailVO.attachmentList
										);
			token.addResponder(responder);
		}

		public function validateCheckEntry(checkID:int, checkAmount:int):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsPledges');
			var token:AsyncToken = service.validate_check_entry(
										checkID,
										checkAmount
										);
			token.addResponder(responder);
		}
		
		public function upsertContact( params:Object, userID:int=0 ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.upsert_contact( params, userID );
			token.addResponder(responder);
		}

		public function listMaxOut( matchID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.list_maxout( matchID );
			token.addResponder(responder);
		}

		public function process_pledge( p:AdminPledgeVO ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsPledges');
			
			var token:AsyncToken = service.process_pledge( p.tr_users_id, p.contact, p.pledge, p.transaction, p.check, p.inKind );
			token.addResponder(responder);
		}
	}
}