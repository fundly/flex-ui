package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.PledgeVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class PluginsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
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
		
		public function get_downline_parents( userID:Number ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsDownline');
			
			var token:AsyncToken = service.get_parents( userID );			
			token.addResponder(responder);
		}		
		
		public function get_contact( contactID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.list_contacts(contactID, null, null, 0 , 1, null);			
			token.addResponder(responder);
		}		

		public function get_all_contacts( sort:String = 'lname ASC, fname ASC', count:int = 10000 ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.list_contacts(null, null, sort, 0 , count, null);			
			token.addResponder(responder);
		}

		public function export_contacts( ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.export_contacts();			
			token.addResponder(responder);
		}

		
		public function upsertContact( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.upsert_contact( params );
			token.addResponder(responder);
		}

		public function sendEmails( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_email( params.emails, params.subject, params.message, params.attachments );			
			token.addResponder(responder);
		}

		public function getRSS():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsRSS');
			
			var token:AsyncToken = service.selective_feed(_model.options.rss_feed, 10);
			token.addResponder(this.responder);			
		}

		public function send_user_email( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_user_email( 
				params.emails, 
				params.subject, 
				params.message, 
				params.template_id, 
				params.attachments 
			);			
			token.addResponder(responder);
		}
				
		public function send_system_email( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_system_email( 
				params.emails, 
				params.message, 
				params.template_id, 
				params.template_vars, 
				params.attachments 
			);			
			token.addResponder(responder);
		}
				
		public function send_invite( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_invite( 
				params.emails, 
				params.fname, 
				params.lname, 
				params.subject, 
				params.template_id, 
				params.template_vars, 
				params.attachments 
			);			
			token.addResponder(responder);
		}
		
		public function process_pledge( p:PledgeVO ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsPledges');
			
			var token:AsyncToken = service.process_pledge( p.tr_users_id, p.contact, p.pledge, p.transaction, p.check );			
			token.addResponder(responder);
		}
	}
}