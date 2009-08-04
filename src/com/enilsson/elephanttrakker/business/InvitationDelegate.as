package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class InvitationDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function InvitationDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function sendInvitation():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsEmail');
			
			var token:AsyncToken = service.send_invite(
										_model.invitation.email,
										_model.invitation.fname,
										_model.invitation.lname,
										_model.serverVariables.invitation_template_id,
										_model.invitation.template_variables
									);
			token.addResponder(responder);
		}
	}
}