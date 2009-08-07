package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.RecordVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class RecordDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function RecordDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function selectRecord( record:RecordVO ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree(record.table_name, record.id);
			token.addResponder(responder);
		}
		
		public function upsertRecord( record:RecordVO ):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.upsert(record.table_name, record.params);
			token.addResponder(responder);
		}
		
		public function deleteRecord( record:RecordVO ):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.del(record.table_name, record.id);
			token.addResponder(responder);
		}
		
		public function exportRecords( table_name:String, where:Object=null ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree( table_name, where, null, null, 100000, 'X');
			token.addResponder(responder);
		}
	}
}
