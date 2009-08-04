package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class MainDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();	
	
		public function MainDelegate(responder:IResponder)
		{
			this.responder = responder;
		}

		public function getRSS():void
		{
			if(_model.debug){ Logger.info('Retrieving RSS'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsRSS');
			
			var token:AsyncToken = service.selective_feed(_model.rssFeed, 10);
			token.addResponder(this.responder);			
		}
		
		public function getOptions():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('site_options', null, null, 0, 1000, 'N');
			token.addResponder(this.responder);			
		}
	}
}