package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.RecordsDelegate;
	import com.enilsson.elephanttrakker.events.modules.resources.*;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class ResourcesCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function ResourcesCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('Resources Command', ObjectUtil.toString(event.type)); }


			switch(event.type)
			{
				case ResourcesEvent.EVENT_RESOURCES :
					fetchRecords(event as ResourcesEvent);
				break;
			}
		}
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		

		/**
		 * Get the records
		 */
		private function fetchRecords(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_fetchRecords, onFault_fetchRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;
			
			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'resources.publish',
				'val' : '1',
				'op' : '='
			}};
			
			delegate.getRecords( new RecordsVO( 'resources', where ) );
		}

		private function onResults_fetchRecords(data:Object):void 
		{
			if(_model.debug) Logger.info('Resources Success', ObjectUtil.toString(data.result));

			_model.dataLoading = false;
			
			var dp:ArrayCollection = new ArrayCollection();
			
			for (var i:String in data.result.resources) 
			{
				dp.addItem(data.result.resources[i]);
			}
			
			if(_model.debug) Logger.info('Resources DP', ObjectUtil.toString(dp));
			
			_model.resources.list = dp;
		}	

		private function onFault_fetchRecords(data:Object):void
		{
			if(_model.debug){ Logger.info('Resources Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}
	
			
		
	}
}