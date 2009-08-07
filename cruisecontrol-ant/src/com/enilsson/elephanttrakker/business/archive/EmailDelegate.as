package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class EmailDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function EmailDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getContacts():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.list_contacts(null, null, 'lname ASC, fname ASC', 0 , 10000, null);			
			token.addResponder(responder);
			
		/*
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('contacts<fname:lname:email:state>',null,'contacts.lname ASC contacts.fname ASC',0,10000);			
			token.addResponder(responder);
		*/
		}
	
		public function getAttachments():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('email_attachments');
			token.addResponder(responder);
		}
		public function getTemplates():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('email_templates',null,null,0,500);			
			token.addResponder(responder);
		}

		public function sendEmails():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_email(_model.email.emails,_model.email.subject,_model.email.message,_model.email.attachment);			
			token.addResponder(responder);
		}



	}
}