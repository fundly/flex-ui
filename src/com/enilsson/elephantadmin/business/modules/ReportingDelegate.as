package com.enilsson.elephantadmin.business.modules
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.CustomReportVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class ReportingDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function ReportingDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('customReporting');
		}
		
		public function loadReport ( reportID:int ):void
		{
			var token:AsyncToken = service.load_report( reportID );
			token.addResponder(responder);
		}

		// This will return all unfulfilled checks regardless of the RLAC permissions
		public function saveReport ( vo:CustomReportVO):void
		{
			var token:AsyncToken = service.save_report([ vo.id, vo.name, vo.description, vo.data ]);
			token.addResponder(responder);
		}
	}
}