package com.enilsson.elephantadmin.commands.popups
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.PluginsDelegate;
	import com.enilsson.elephantadmin.events.popups.DownlineEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
		
	public class DownlineCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function DownlineCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('MyDownline Command', ObjectUtil.toString(event.type));		
			
			switch(event.type)
			{
				case DownlineEvent.GET_DOWNLINE :
					getDownline(event as DownlineEvent)
				break;	
			}	
			
		}

		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }


		/**
		 * Get the users pledge data
		 */
		private function getDownline(event:DownlineEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getDownline, onFault_getDownline);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true
			
			delegate.get_downline( event.params.userID, event.params.nodeLevels );
		}

		private function onResults_getDownline(data:Object):void 
		{
			//if(_model.debug) Logger.info('getDownline Success', ObjectUtil.toString(data.result));
			if(_model.debug) Logger.info('getDownline Success');
			
			_model.downline.downlineXML = new XML(data.result);
			_model.downline.graph = new Graph(
				"XMLAsDocsGraph",
				false,
				_model.downline.downlineXML
			);
			_model.downline.graphShow = true;

			_model.dataLoading = false;
		}	

		private function onFault_getDownline(data:Object):void
		{
			if(_model.debug){ Logger.info('getDownline Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}	

	}
}