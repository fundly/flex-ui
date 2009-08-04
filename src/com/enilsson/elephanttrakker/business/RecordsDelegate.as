package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.CountingVO;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class RecordsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function RecordsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getRecords( r:RecordsVO ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			if(_model.debug) Logger.info('getRecords RecordsVO', ObjectUtil.toString(r));
			
			var token:AsyncToken = service.record_tree( r.table, r.where, r.sort, r.iFrom, r.iCount, r.options );			
			token.addResponder( responder );
		}

		public function countRecords( c:CountingVO ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorCounting');
			
			var token:AsyncToken = service.global_count( c.table_name, c.group_field, c.table_name );
			token.addResponder(responder);
		}

	}
}
