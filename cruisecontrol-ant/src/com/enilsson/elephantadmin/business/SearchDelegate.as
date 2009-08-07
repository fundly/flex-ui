package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.SearchVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SearchDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
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