package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.LayoutVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class LayoutDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function LayoutDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorLayout');
		}
		
		public function getLayout( layout:LayoutVO ):void
		{
			var token:AsyncToken = service.fetch_layout(layout.table_name);
			token.addResponder(responder);
		}
		
		public function getLayouts():void
		{
			var token:AsyncToken = service.fetch_layout( );
			token.addResponder(responder);
		}	
		
		public function getApplicationLayout ( type:String='client' ):void
		{
			var token:AsyncToken = service.get_application_layout( type );
			token.addResponder(responder);
		}	
	}
}