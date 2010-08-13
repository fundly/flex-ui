package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.events.modules.RecordsEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class RecordsCommand implements ICommand
	{
		private var _model : EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName : String;
		private var _event : RecordsEvent;
		private var _recordsVO : RecordsVO;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as RecordsEvent;			
			if(!_event) return;
			
			_recordsVO = _event.recordsVO;
			if(!_recordsVO) return;
						
			_moduleName = _event.table;
			
			switch( _event.type ) {
				case RecordsEvent.GET_RECORDS: getRecords(_event); break;
				case RecordsEvent.EXPORT_RECORDS: exportTable(_event); break;
			}
		}
		
		/**
		 * Get the records from listing eSQL query
		 */			
		private function getRecords(event:RecordsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].lastQuery = event;

			delegate.getRecords( event.recordsVO );
		}
		
		private function onResults_getRecords(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			_model[_moduleName].totalRecords = event.result.total_rows;
			
			var tableName:String = event.result.table_name;
			
			_model[_moduleName].records = new ArrayCollection();
			for each( var item:Object in event.result[tableName])
				_model[_moduleName].records.addItem(item);
			
			if(_model[_moduleName].records.length > 0)
			{				
				if( !_model.transactions.sidRecord )
				{
					_model[_moduleName].details = _model[_moduleName].records[0];
					_model[_moduleName].selectedIndex = -1;
					_model[_moduleName].selectedIndex = 0;
				} 
			}
		}
		
		public function onFault_getRecords(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}
		
		
		
		private function exportTable( event : RecordsEvent ) : void {
			var handlers:IResponder = new mx.rpc.Responder(onResult_exportTable, onFault_exportTable);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			_model.dataLoading = true;

			delegate.exportRecords( event.recordsVO  );
		}
		
		private function onResult_exportTable( event : ResultEvent ) : void {
			if(_model.debug) Logger.info('exportTables Success', ObjectUtil.toString(event.result));
			
			var df : DateFormatter = new DateFormatter();
			navigateToURL(new URLRequest(_model.gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+_moduleName+"_"+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent'); 
			_model.dataLoading = false;
		}
		
		private function onFault_exportTable( event : FaultEvent ) : void {
			if(_model.debug) Logger.info('exportTables Fault', ObjectUtil.toString(event.fault));
			_model.dataLoading = false;	
		}
	}
}