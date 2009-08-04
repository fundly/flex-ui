package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.ReportingEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class ReportingCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'reporting';
		
		public function ReportingCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case ReportingEvent.REPORTING_RECORDS :
					getRecords(event as ReportingEvent);
				break;
				case ReportingEvent.REPORTING_SEARCH :
					searchRecords(event as ReportingEvent);
				break;
				case ReportingEvent.SHOW_RECORD :
					showRecord(event as ReportingEvent);
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
		private function getRecords(event:ReportingEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getRecords( event.params.recordsVO );			
		}
				
		private function onResults_getRecords(event:Object):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' getRecords Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;
			
			_model[_moduleName].totalRecords = event.result.total_rows;
			
			var tableName:String = event.result.table_name;
			
			_model[_moduleName].records = new ArrayCollection();
			for each( var item:Object in event.result[tableName])
			{
				_model[_moduleName].records.addItem(item);
			}

			this.nextEvent = new ReportingEvent(ReportingEvent.RECORDS_LOADED);
			this.executeNextCommand();
			this.nextEvent = null;
			
		}
		
		public function onFault_getRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}
		

		/**
		 * Get the table layout to build the form
		 */			
		private function searchRecords(event:ReportingEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.search( event.params.searchVO );			
		}
				
		private function onResults_searchRecords(event:Object):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' search Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;
			
			if (event.result[0]) 
			{
			
				_model[_moduleName].totalRecords = event.result[0].found_rows;
				
				var tableName:String = event.result[0].table_name;
				
				_model[_moduleName].records = new ArrayCollection();
				for each( var item:Object in event.result[0][tableName])
				{
					_model[_moduleName].records.addItem(item);
				}
			} 
			else 
			{
				_model[_moduleName].totalRecords = 0;
				_model[_moduleName].records = new ArrayCollection();
			}

		}
		
		public function onFault_searchRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' search Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}		
		
		public function showRecord(event:ReportingEvent):void
		{
			if(event.moduleName && event.recordID)
				_model.reporting.reportModule = event.moduleName;
				_model.reporting.reportRecordID = event.recordID;

				_model.mainViewState = _model.tableModuleMapping['reporting'];
		}
		
	}
}