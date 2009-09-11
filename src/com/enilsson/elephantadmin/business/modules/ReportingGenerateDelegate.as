package com.enilsson.elephantadmin.business.modules
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class ReportingGenerateDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function ReportingGenerateDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('reportingGenerate');
		}
		
		public function generateReport ( reportID:int, page:int ):void
		{
			var token:AsyncToken = service.create_report( [_loadedData.reportID, page * _model.itemsPerPage - _model.itemsPerPage, _model.itemsPerPage ] );
			token.addResponder(responder);
		}
	}
}