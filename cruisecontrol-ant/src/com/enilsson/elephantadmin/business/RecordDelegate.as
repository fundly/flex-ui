package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.BatchRecordVO;
	import com.enilsson.elephantadmin.vo.RecordVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class RecordDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function RecordDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function selectRecord(record:RecordVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree(record.table_name, record.id, null, 0, 1000);
			token.addResponder(responder);
		}
		
		public function upsertRecord(record:RecordVO):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.upsert(record.table_name, record.params);
			token.addResponder(responder);
		}
		
		public function upsertRecords(records:BatchRecordVO):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');

			var data:Array = [];

			for each(var record:RecordVO in records.list)
			{
				var row:Array = [record.table_name, record.params];
				data.push(row);
			}

			var token:AsyncToken = service.batch_upserts( data );
			token.addResponder(responder);
		}
		
		public function deleteRecord(record:RecordVO):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.del(record.table_name, record.id);
			token.addResponder(responder);
		}

		public function exportRecords(record:RecordVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree(record.table_name,null,null,null,record.params.limit,'X');
			token.addResponder(responder);
		}

		public function getSidRecord( sid:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.get_sid_record( sid );
			token.addResponder(responder);
		}
				
		public function getSidTree( sid:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.get_sid_tree( sid );
			token.addResponder(responder);
		}
	}
}
