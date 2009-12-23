package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.PluginsDelegate;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.ChecksEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.BatchRecordVO;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.RecordVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class ChecksCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'checks';
		
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case ChecksEvent.RECORD  :
					getRecord(event as ChecksEvent); 
				break;
				case ChecksEvent.RECORDS :
					getRecords(event as ChecksEvent);
				break;
				case ChecksEvent.SEARCH :
					searchRecords(event as ChecksEvent);
				break;
				case ChecksEvent.UPSERT :
					upsertRecord(event as ChecksEvent);
				break;
				case ChecksEvent.DELETE :
					deleteRecord(event as ChecksEvent);
				break;
				case ChecksEvent.VALIDATE :
					validateRecord(event as ChecksEvent);
				break;
				case ChecksEvent.UPSERT_MULTIPLE :
					upsertRecords(event as ChecksEvent);
				break;
			}
		}

		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		/**
		 * Get a single Check record
		 */
		private function getRecord(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getRecord, onFault_getRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
			delegate.selectRecord( event.params.recordVO );
		}
		
		private function onResult_getRecord(event:ResultEvent) : void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecord Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			var tableName:String = event.result.table_name;
			
			_model[_moduleName].details = event.result[tableName][1];
			_model[_moduleName].selectedIndex = -1;
		}
		private function onFault_getRecord(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecord Fail', ObjectUtil.toString(event));			
			_model.dataLoading = false;
		}
		
		

		/**
		 * Get the checks table layout to build the form
		 */			
		private function getRecords(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].lastQuery = event;

			delegate.getRecords( event.params.recordsVO );			
		}
				
		private function onResults_getRecords(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;			
			_model[_moduleName].totalRecords = event.result.total_rows;
			
			var tableName:String = event.result.table_name;
			
			_model[_moduleName].records = new ArrayCollection();
			for each( var item:Object in event.result[tableName]) {
				_model[_moduleName].records.addItem(item);
			}
						
			if(_model[_moduleName].records.length > 0)
			{
				if(!_model[_moduleName].sidRecord)
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
		private function searchRecords(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
			_model[_moduleName].isSearching = true;
			_model[_moduleName].lastQuery = ChecksEvent(event);

			delegate.search( event.params.searchVO );
		}
				
		private function onResults_searchRecords(event:Object):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' search Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;
			_model[_moduleName].isSearching = false;
			
			if (event.result.hasOwnProperty('0')) 
			{
				_model[_moduleName].totalRecords = event.result[0].found_rows;
				
				var tableName:String = event.result[0].table_name;
				
				_model[_moduleName].records = new ArrayCollection();
				for each( var item:Object in event.result[0][tableName])
				{
					_model[_moduleName].records.addItem(item);
				}
				
				if(_model[_moduleName].records.length > 0) 
				{
					_model[_moduleName].details = _model[_moduleName].records[0];
					// Workaround to select the first element of the list
					_model[_moduleName].selectedIndex = -1;
					_model[_moduleName].selectedIndex = 0;
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


	
		/**
		 * Upsert a record
		 */			
		private function upsertRecord(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertRecord, onFault_upsertRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model[_moduleName].formProcessing = true;
				
			delegate.upsertRecord( event.params.recordVO );
		}

		private function onResults_upsertRecord(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' upsertRecord Success', ObjectUtil.toString(event.result));
			
			_model[_moduleName].formProcessing = false;

			switch(event.result.state)
			{
				case '99' :
				case '98' :
					_model.errorVO = new ErrorVO(_moduleName + ' record edited successfully!', 'successBox', true );
					// refresh the users list
					new ChecksEvent(
						ChecksEvent.RECORDS, {
							'recordsVO' : _model[_moduleName].recordQuery
						}
					).dispatch()
				break;
				case '-99' :			
					var eMsg:String = '';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}
		
		public function onFault_upsertRecord(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' upsertRecord Fail', ObjectUtil.toString(event));
			
			// hide the processing indicator
			_model[_moduleName].formProcessing = false;
		}	


		/**
		 * Upsert multiple records
		 */			
		private function upsertRecords(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertRecords, onFault_upsertRecords);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model[_moduleName].formProcessing = true;
				
			delegate.upsertRecords( BatchRecordVO(event.params) );
		}

		private function onResults_upsertRecords(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' upsertRecords Success', ObjectUtil.toString(event.result));
			
			_model[_moduleName].formProcessing = false;

			switch(event.result.state)
			{
				case true :
					_model.errorVO = new ErrorVO(event.result.upserts + ' records edited successfully!', 'successBox', true );
					// refresh the checks list
					new ChecksEvent(
						ChecksEvent.RECORDS, {
							'recordsVO' : _model[_moduleName].recordQuery
						}
					).dispatch()
				break;
				default :
					var eMsg:String = '';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}
		
		public function onFault_upsertRecords(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' upsertRecords Fail', ObjectUtil.toString(event));
			
			// hide the processing indicator
			_model[_moduleName].formProcessing = false;
		}	


		/**
		 * Delete a record
		 */			
		private function deleteRecord(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteRecord, onFault_deleteRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model[_moduleName].formProcessing = true;
				
			delegate.deleteRecord( event.params.recordVO );
		}
				
		private function onResults_deleteRecord(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteRecord Success', ObjectUtil.toString(event.result));
			
			_model[_moduleName].formProcessing = false;
			switch(event.result.state)
			{
				case '88' :
					_model.errorVO = new ErrorVO(_moduleName + ' record deleted successfully!', 'successBox', true );
					new ChecksEvent(
						ChecksEvent.RECORDS, {
							'recordsVO' : _model[_moduleName].recordQuery
						}
					).dispatch()
				break;
				case '-88' :			
					var eMsg:String = '';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}
		
		public function onFault_deleteRecord(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteRecord Fail', ObjectUtil.toString(event));
			
			// hide the processing indicator
			_model[_moduleName].formProcessing = false;
			
			var faultString:String = '';
			switch(event.fault.faultCode)
			{
				case '5':
					faultString = event.fault.faultString;
					_model.errorVO = new ErrorVO( 
								'There was a problem processing this record:<br><br>' + faultString, 
								'errorBox', 
								true 
							);
				break;
			}
		}

		/**
		 * Get the users table layout to build the form
		 */			
		private function validateRecord(event:ChecksEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_validateRecord, onFault_validateRecord);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);

			_model.dataLoading = true;

			// set next event for upsert
			this.nextEvent = new ChecksEvent( 
					ChecksEvent.UPSERT, {
						'recordVO' : event.params.recordVO
					}
				);

			delegate.validateCheckEntry(RecordVO(event.params.recordVO).params.id, RecordVO(event.params.recordVO).params.amount);
		}
				
		private function onResult_validateRecord(event:ResultEvent):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' validateRecord Success', ObjectUtil.toString(event.result)); }
			

			if(event.result.state == true)
				this.executeNextCommand();
			else
			{
				_model.dataLoading = false;
				_model.errorVO = new ErrorVO(event.result.errors[0],"errorBox",true);
			}
		}
		
		public function onFault_validateRecord(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' validateRecord Fail', ObjectUtil.toString(event));
			_model.errorVO = new ErrorVO(event.fault.faultString,"errorBox",true);

			_model.dataLoading = false;
		}
	}
}