package com.enilsson.elephantadmin.business.modules
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class BatchDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function BatchDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsChecks');
		}
		
		public function saveNewBatch ( checkIDs:Array ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsChecks');
			var token:AsyncToken = service.insert_checks_batches( checkIDs );
			token.addResponder(responder);
		}

		// This will return all unfulfilled checks regardless of the RLAC permissions
		public function getAllUnfulfilledChecks ( where:Object, order:String, from:int, limit:int, options:String):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsChecks');
			var token:AsyncToken = service.list_unfulfilled_checks(where, order, from, limit, options);
			token.addResponder(responder);
		}

		// This will return all checks in a batch regardless of the RLAC permissions
		public function getBatchChecks ( batchID:int, order:String, from:int, limit:int, options:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsChecks');
			var token:AsyncToken = service.list_batch_checks( batchID, order, from, limit, options );
			token.addResponder(responder);
		}
		public function exportBatch ( batchID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsBatches');
			var token:AsyncToken = service.export_batch( batchID );
			token.addResponder(responder);
		}
	}
}