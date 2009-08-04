package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.AuthentikatorDelegate;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.DashboardEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class DashboardCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'dashboard';
		
		public function DashboardCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case DashboardEvent.GET_LATEST_PLEDGES :
					getLatestPledges(event as DashboardEvent);
				break;
				case DashboardEvent.GET_ACTIVE_USERS :
					getActiveUsers(event as DashboardEvent);
				break;
				case DashboardEvent.SEARCH_EVENTS :
					searchEvents(event as DashboardEvent);
				break;
				case DashboardEvent.GET_EVENT :
					getLatestEvent(event as DashboardEvent);
				break;
				case DashboardEvent.GET_EVENT_STATS :
					getEventStats(event as DashboardEvent);
				break;
			}
		}

		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }


		/**
		 * Get the users table layout to build the form
		 */			
		private function getLatestPledges(event:DashboardEvent):void
		{
			var delegate:RecordsDelegate = new RecordsDelegate(event.responder);
			delegate.getRecords(event.recordsVO);
		}

		/**
		 * Get the users table layout to build the form
		 */			
		private function getActiveUsers(event:DashboardEvent):void
		{
			var delegate:AuthentikatorDelegate = new AuthentikatorDelegate(event.responder);
			delegate.getActiveUsers();
		}

		private function searchEvents(event:DashboardEvent):void
		{
			var delegate:SearchDelegate = new SearchDelegate(event.responder);
			delegate.search(event.searchVO);
		}

		private function getEventStats(event:DashboardEvent):void
		{
			var delegate:RecordsDelegate = new RecordsDelegate(event.responder);
			delegate.getRecords(event.recordsVO);
		}

		private function getLatestEvent(event:DashboardEvent):void
		{
			var delegate:RecordDelegate = new RecordDelegate(event.responder);
			delegate.selectRecord(event.recordVO);
		}
	}
}