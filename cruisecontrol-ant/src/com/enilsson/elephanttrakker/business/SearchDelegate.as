package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.vo.SearchVO;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class SearchDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function SearchDelegate(responder:IResponder)
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSearch');
			this.responder = responder;
		}
		
		public function search( s:SearchVO ):void
		{
			var token:AsyncToken = service.table( s.table, s.query, s.mode, s.iCount, s.iFrom, s.sort, s.priv, s.export );
			token.addResponder(responder);
		}

	}
}