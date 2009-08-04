package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.BrowseEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	import com.enilsson.elephantadmin.vo.SearchVO;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.rpc.Responder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class BrowseCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'browse';
		
		public function BrowseCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type));

			switch(event.type)
			{
				case BrowseEvent.RECORDS :
					getRecords(event as BrowseEvent);
				break;
				case BrowseEvent.SEARCH :
					searchRecords(event as BrowseEvent);
				break;
				case BrowseEvent.EXPORT :
					exportTable(event as BrowseEvent);
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
		private function getRecords(event:BrowseEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].lastQuery = event;			
			_model[_moduleName].lastExportableQuery = event;

			delegate.getRecords( event.params.recordsVO );			
		}
				
		private function onResults_getRecords(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			if (event.result.hasOwnProperty('total_rows')) {
				_model[_moduleName].totalRecords = event.result.total_rows;
			}
			
			var table_name:String = event.result.table_name;
			
			var records:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result[table_name])
			{
				records.addItem(item);
			}
			
			_model[_moduleName].records = records;
		}
		
		public function onFault_getRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}
		

		/**
		 * Get the users table layout to build the form
		 */			
		private function searchRecords(event:BrowseEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].isSearching = true;
			_model[_moduleName].lastQuery = event;
			_model[_moduleName].lastExportableQuery = event;
			_model[_moduleName].totalRecords = 0;

			delegate.search( event.params.searchVO );			
		}
				
		private function onResults_searchRecords(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' search Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			_model[_moduleName].isSearching = false;
			
			if (event.result.hasOwnProperty('0')) 
			{
				if (event.result[0].hasOwnProperty('found_rows')) {
					_model[_moduleName].totalRecords = event.result[0].found_rows;
				}
				
				var tableName:String = event.result[0].table_name;
				
				_model[_moduleName].records = new ArrayCollection();
				for each( var item:Object in event.result[0][tableName])
				{
					_model[_moduleName].records.addItem(item);
				}
			} else {
				_model[_moduleName].records = new ArrayCollection();
			}
		}
		
		public function onFault_searchRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' search Fail', ObjectUtil.toString(event));		
			
			_model[_moduleName].isSearching = false;
			_model.dataLoading = false;
		}
		
		private function exportTable(event:BrowseEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportTable, onFault_exportTable);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model[_moduleName].lastQuery = event;
			_model.dataLoading = true;
			
			var e : BrowseEvent = _model.browse.lastExportableQuery;
			if(e) 
			{
				switch(e.type)
				{
					case BrowseEvent.SEARCH:
						var searchDelegate : SearchDelegate = new SearchDelegate(handlers);
						var searchVO : SearchVO = _model.browse.lastExportableQuery.params.searchVO as SearchVO;
						searchVO.export = true; 
						searchDelegate.search(searchVO);
					break;
					case BrowseEvent.RECORDS:
						var vo : RecordsVO = _model.browse.lastExportableQuery.params.recordsVO as RecordsVO;
						vo.table = (event.params.recordVO as RecordVO).table_name;
						delegate.exportRecords( vo );
					break;					
				}
			}
		}
		
		private function onResults_exportTable(data:Object):void 
		{
			if(_model.debug) Logger.info('exportTable Success', ObjectUtil.toString(data.result));
			
			var e : BrowseEvent = _model[_moduleName].lastQuery as BrowseEvent;
			var tableName : String = e.params.recordVO.table_name;
			var df : DateFormatter = new DateFormatter();
			df.formatString = "MMDDYYYY";
			var dateStr : String = df.format(new Date());
			
			var filename : String = _model.browse.table + '_' + dateStr; 
			
			navigateToURL(new URLRequest(_model.gatewayBaseURL + '/export.php?id='+data.result+'&file_name='+filename),'_parent') 
			
			_model.dataLoading = false;
		}	
	
		private function onFault_exportTable(data:Object):void
		{
			if(_model.debug) Logger.info('exportTable Fault', ObjectUtil.toString(data.fault));
			
			_model.dataLoading = false;			
		}
	}
}