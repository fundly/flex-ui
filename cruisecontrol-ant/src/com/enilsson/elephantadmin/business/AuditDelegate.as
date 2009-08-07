package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class AuditDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function AuditDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorAudit');
		}
		
		public function history( userID:Number ):void
		{	
			var token:AsyncToken = service.history( null, null, userID );
			token.addResponder(responder);
		}

		public function recordHistory( table:String, recordID:int ):void
		{	
			var token:AsyncToken = service.history( table, recordID );
			token.addResponder(responder);
		}
		
		public function fetchArchive ( table:String, deletedID:int ):void
		{
			var token:AsyncToken = service.fetchArchive( table, deletedID );
			token.addResponder(responder);
		}

	}
}