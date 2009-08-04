package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.TransactionsEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class TransactionsCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'transactions';
		
		public function TransactionsCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case TransactionsEvent.TRANSACTIONS_RECORDS :
					_moduleName = 'transactions';
					getRecords(event as TransactionsEvent);
				break;
				case TransactionsEvent.TRANSACTIONS_SEARCH :
					_moduleName = 'transactions';
					searchRecords(event as TransactionsEvent);
				break;
				case TransactionsEvent.TRANSACTIONS_FAILED_RECORDS :
					_moduleName = 'transactions_failed';
					getRecords(event as TransactionsEvent);
				break;
				case TransactionsEvent.TRANSACTIONS_FAILED_SEARCH :
					_moduleName = 'transactions_failed';
					searchRecords(event as TransactionsEvent);
				break;
				}
		}


		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }


		/**
		 * Get the records from listing eSQL query
		 */			
		private function getRecords(event:TransactionsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].lastQuery = TransactionsEvent(event);

			delegate.getRecords( event.params.recordsVO );
		}
				
		private function onResults_getRecords(event:Object):void 
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
		
		public function onFault_getRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}
		

		/**
		 * Get the users table layout to build the form
		 */			
		private function searchRecords(event:TransactionsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].lastQuery = TransactionsEvent(event);

			delegate.search( event.params.searchVO );
		}
				
		private function onResults_searchRecords(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' search Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			_model[_moduleName].totalRecords = event.result[0].found_rows;
			
			var tableName:String = event.result[0].table_name;
			
			_model[_moduleName].records = new ArrayCollection();
			for each( var item:Object in event.result[0][tableName])
				_model[_moduleName].records.addItem(item);
			
			if(_model[_moduleName].records.length > 0) 
			{
				_model[_moduleName].details = _model[_moduleName].records[0];
				// Workaround to select the first element of the list
				_model[_moduleName].selectedIndex = -1;
				_model[_moduleName].selectedIndex = 0;
			}
		}
		
		public function onFault_searchRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' search Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}		

	}
}