package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class S3Delegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function S3Delegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorS3');
		}
		
		public function delete_object( urlkey:String ):void
		{	
			var token:AsyncToken = service.delete_object( urlkey );
			token.addResponder(responder);
		}
		
		public function get_bucket( prefix:String='' ):void
		{	
			var token:AsyncToken = service.get_bucket( prefix, null, null, null );
			token.addResponder(responder);
		}
		
		public function get_credentials( ):void
		{	
			var token:AsyncToken = service.get_credentials( );
			token.addResponder(responder);
		}

	}
}