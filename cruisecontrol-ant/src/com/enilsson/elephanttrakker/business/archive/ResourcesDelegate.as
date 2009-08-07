package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class ResourcesDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function ResourcesDelegate(responder:IResponder)
		{
			this.responder = responder;
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
		}
		
		public function getRecords():void
		{
			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'resources.publish',
				'val' : '1',
				'op' : '='
			}};
			
			var token:AsyncToken = service.record_tree('resources',where);
			token.addResponder(responder);
		}
	}
}