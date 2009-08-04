package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.vo.LayoutVO;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class LayoutDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function LayoutDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorLayout');
		}
		
		public function getLayout(layout:LayoutVO):void
		{
			var token:AsyncToken = service.fetch_layout(layout.table_name);
			token.addResponder(responder);
		}
		
		public function getLayouts():void
		{
			var token:AsyncToken = service.fetch_layout();
			token.addResponder(responder);
		}		
		
		public function getLayoutSchema(layout:LayoutVO):void
		{
			var token:AsyncToken = service.fetch_layout_schema(layout.table_name);
			token.addResponder(responder);
		}		
		
		public function getRelations(layout:LayoutVO):void
		{
			var token:AsyncToken = service.fetch_relations(layout.table_name);
			token.addResponder(responder);
		}				
		
		public function getTableNames():void
		{
			var token:AsyncToken = service.fetch_tables();
			token.addResponder(responder);
		}
		
		public function getApplicationLayout ( type:String='admin' ):void
		{
			var token:AsyncToken = service.get_application_layout( type );
			token.addResponder(responder);
		}	
								
	}
}