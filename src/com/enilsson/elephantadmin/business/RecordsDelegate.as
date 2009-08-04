package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class RecordsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function RecordsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getRecords(r:RecordsVO):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			if(_model.debug) Logger.info('getRecords RecordsVO', ObjectUtil.toString(r));
			
			var token:AsyncToken = service.record_tree(r.table, r.where, r.sort, r.iFrom, r.iCount, r.options);			
			token.addResponder(responder);
		}
		
		public function exportRecords( r : RecordsVO ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree(r.table, r.where, null, null, 100000, 'X');
			token.addResponder(responder);
		}
	}		
}
