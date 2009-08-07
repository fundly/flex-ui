package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.PluginsDelegate;
	import com.enilsson.elephanttrakker.events.modules.my_downline.GetDownlineEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
		
	public class MyDownlineCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyDownlineCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('MyDownline Command', ObjectUtil.toString(event.type)); }		
			
			switch(event.type)
			{
				case GetDownlineEvent.EVENT_GET_DOWNLINE :
					getDownline(event as GetDownlineEvent)
				break;	
				case GetDownlineEvent.EVENT_GET_PARENTS :
					getParents(event as GetDownlineEvent)
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
		private function getDownline(event:GetDownlineEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getDownline, onFault_getDownline);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			if(_model.my_downline.gettingDownline) return;
			
			// show the data loading icon
			_model.dataLoading = true;
			_model.my_downline.isEmpty = false;
			_model.my_downline.gettingDownline = true;
			
			delegate.get_downline( event.userID, event.nodeLevels );
		}
		
		private function onResults_getDownline(data:Object):void 
		{
			if(_model.debug) Logger.info('getDownline Success', ObjectUtil.toString(data.result));
			
			// get the xml data then remove any edge that is referenced to the user
			var xml:XML = new XML(data.result);
			
			for ( var i:String in xml.Edge )
			{
				var edge:XML = xml.Edge[i];
				
				if ( edge.@fromID == _model.session.user_id )
				{
					delete xml.Edge[i];
					break;
				}
			}
			
			// add xml to the downline chart			
			_model.my_downline.downlineXML = xml;
			_model.my_downline.graph = new Graph(
				"XMLAsDocsGraph",
				false,
				_model.my_downline.downlineXML
			);
			
			if (data.result.toString() == '') _model.my_downline.isEmpty = true;
			
			_model.my_downline.graphShow = true;

			_model.dataLoading = false;
			_model.my_downline.gettingDownline = false;
		}	
		
		private function onFault_getDownline(data:Object):void
		{
			if(_model.debug) Logger.info('getDownline Fault', ObjectUtil.toString(data.fault));
			
			_model.my_downline.errorVO = new ErrorVO('There was a problem fetching your downline:<br><br>' + data.fault.faultString, 'errorBox', true);
			
			_model.dataLoading = false;		
			_model.my_downline.gettingDownline = false;
			_model.my_downline.isEmpty = true;	
		}	


		/**
		 * Get the users parent fundraisers
		 */
		private function getParents(event:GetDownlineEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getParents, onFault_getParents);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true
			
			delegate.get_downline_parents( event.userID );
		}
		
		private function onResults_getParents(data:Object):void 
		{
			if(_model.debug) Logger.info('getParents Success', ObjectUtil.toString(data.result));
			
			_model.my_downline.parentXML = new XML(data.result);
			_model.my_downline.parentGraph = new Graph(
				"XMLAsDocsGraph",
				false,
				_model.my_downline.parentXML
			);
			_model.my_downline.parentGraphShow = true;
			
			if (data.result.toString() == '') _model.my_downline.isParentsEmpty = true;

			_model.dataLoading = false;
		}
			
		private function onFault_getParents(data:Object):void
		{
			if(_model.debug) Logger.info('getParents Fault', ObjectUtil.toString(data.fault));

			_model.my_downline.errorVO = new ErrorVO('There was a problem fetching your parents listing:<br><br>' + data.fault.faultString, 'errorBox', true);
			
			_model.dataLoading = false;			
		}	

	}
}