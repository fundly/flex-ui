package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.*;
	import com.enilsson.elephantadmin.events.modules.RecordModuleEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class RecordModuleCommand extends SequenceCommand implements ICommand, IResponder
	{
		protected var _model:EAModelLocator = EAModelLocator.getInstance();
		protected var _moduleName:String = 'Record Module';
		protected var _presentationModel:RecordModel;

		public function RecordModuleCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type));
			this._presentationModel = RecordModuleEvent(event).model;

			switch(event.type)
			{
				case RecordModuleEvent.GET_AUDIT_TRAIL :
					getAuditTrail( event as RecordModuleEvent );
				break;
				case RecordModuleEvent.SEARCH_RECORDS :
					searchRecords( event as RecordModuleEvent );
				break;
				case RecordModuleEvent.GET_RECORDS :
					getRecords( event as RecordModuleEvent );
				break;
				case RecordModuleEvent.GET_FULL_RECORD :
					getFullRecord( event as RecordModuleEvent );
				break;
				case RecordModuleEvent.UPSERT :
					upsertRecord( event as RecordModuleEvent );
				break;
				case RecordModuleEvent.DELETE :
					deleteRecord( event as RecordModuleEvent );
				break;
				case RecordModuleEvent.GET_DELETED_RECORD :
					getDeleted( event as RecordModuleEvent );
				break;				
			}
		}


		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		

		/**
		 * Get the audit trail for the record in question
		 */	
		private function getAuditTrail(event:RecordModuleEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getAuditTrail, onFault_getAuditTrail);
			var delegate:AuditDelegate = new AuditDelegate(handlers);
			
			if(_model.debug) Logger.info(_moduleName + ' getAuditTrail Call', ObjectUtil.toString(event.params));

			
			delegate.recordHistory( event.params.table, event.params.recordID );
		}
				
		private function onResult_getAuditTrail(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getAuditTrail Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			this._presentationModel.auditTrail = new ArrayCollection(event.result as Array);
			_presentationModel.auditTrailTabLoading = false;
		}
		
		public function onFault_getAuditTrail(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getAuditTrail Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}


		/**
		 * Run a search and return the data
		 */	
		private function searchRecords(event:RecordModuleEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
			
			if(_model.debug) Logger.info(_moduleName + ' searchRecords call', ObjectUtil.toString(event.searchVO));
				
			delegate.search( event.searchVO );
		}
				
		private function onResult_searchRecords(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' searchRecords Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			var table:String = event.result[0].table_name;
			var data:Object = event.result[0][table];

			if( event.result[0].hasOwnProperty('found_rows') ) 
				_presentationModel.searchListItemsTotal = event.result[0].found_rows;
			
			var s:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in data)
				s.addItem( item );
			
			_presentationModel.records = s;
		}
		
		public function onFault_searchRecords(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' searchRecords Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}	
		
		
		/**
		 * Run a search and return the data
		 */	
		private function getRecords(event:RecordModuleEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			
			if(_model.debug) Logger.info('getRecords call', ObjectUtil.toString(event.recordsVO) );

			delegate.getRecords( event.recordsVO );
		}
				
		private function onResult_getRecords(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			var records:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in event.result[event.result.table_name] )
				records.addItem( item );

			_presentationModel.searchListItemsTotal = event.result.total_rows;
			_presentationModel.records = records;

			if(_presentationModel.refreshingRecords)
			{
				for(var i:int = 0; i < _presentationModel.records.length; i++)
				{
					// reinsert the edited form variables back into the list
					if(_presentationModel.records[i].id == _presentationModel.recordID)
						_presentationModel.searchListSelectedIndex = i;
				}
			}
/* 
			// If this is a refresh query after an operation set list index to last position
			if(_presentationModel.searchListLastIndex > -1 )
			{
				if(records.length > _presentationModel.searchListLastIndex)
				{
					_presentationModel.searchListSelectedIndex = _presentationModel.searchListLastIndex;
					_presentationModel.selectedRecord = records[_presentationModel.searchListSelectedIndex];
				}
				else
				{
					_presentationModel.searchListSelectedIndex = records.length - 1;
					_presentationModel.selectedRecord = records[records.length - 1];
				}
				_presentationModel.searchListLastIndex = -1;
			}
 */			// If this is a new listing query
			else
			{
				// if it is not a SID direct access and has more than 1 record
				if(_presentationModel.viewState != 'showOptions' && records.length > 0)
					{
						// set selected record to the first item in the list
						_presentationModel.searchListSelectedIndex = 0;
						_presentationModel.selectedRecord = records[_presentationModel.searchListSelectedIndex];
					}
			}
		}
		
		public function onFault_getRecords(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}
		
		
		/**
		 * Get the full record via the SID
		 */		
		private function getFullRecord(event:RecordModuleEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getFullRecord, onFault_getFullRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getSidRecord( event.params.sid );
		}
				
		private function onResult_getFullRecord(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getFullRecord Success', ObjectUtil.toString(event.result));
			
			// close the dataloading icon
			_model.dataLoading = false;			
			// update the selected record with the new data
			_presentationModel.selectedRecord = event.result[_presentationModel.table][1];
			// fire a handler to add any methods when the update is completed
			_presentationModel.onRecordUpdate();			
		}
		
		public function onFault_getFullRecord(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getFullRecord Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}


		/**
		 * Upsert the Record
		 */		
		private function upsertRecord(event:RecordModuleEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' upsertRecord Success', ObjectUtil.toString(event.recordVO));

			var handlers:IResponder = new mx.rpc.Responder(onResult_upsertRecord, onFault_upsertRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			_model.dataLoading = true;
			_presentationModel.formProcessing = true;

			// Save the index of the current list to display the same record after reloading the list
			_presentationModel.searchListLastIndex = _presentationModel.searchListSelectedIndex;

			delegate.upsertRecord( event.recordVO );
		}
				
		private function onResult_upsertRecord(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' upsertRecord Success', ObjectUtil.toString(event.result));

			_presentationModel.formProcessing = false;

			switch(event.result.state)
			{
				case '99' :
				case '98' :
					_model.errorVO = new ErrorVO( _presentationModel.layout.title +' record edited successfully!', 'successBox', true );
					
					// refresh the modules search list
					for( var prop:String in _presentationModel.formVariables )
					{
						_presentationModel.selectedRecord[prop] = _presentationModel.formVariables[prop];
						_presentationModel.records.refresh();
					}

					// set addingNewRecord flag as false if adding new record
					if( _presentationModel.addingNewRecord )
					{
						_presentationModel.addingNewRecord = false;
						_presentationModel.lastQuery.dispatch();
						_presentationModel.searchListSelectedIndex = _presentationModel.searchListLastIndex;
					}
					_model.dataLoading = false;
				break;
				case '-99' :
					var eMsg:String = '';
					for(var j:String in event.result.errors)
						eMsg += '- ' + event.result.errors[j] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
					_model.dataLoading = false;
				break;	
			}
		}
		
		public function onFault_upsertRecord(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('upsertRecord Fail', ObjectUtil.toString(event.fault));
			
			_presentationModel.formProcessing = false;			
			_model.errorVO = new ErrorVO( 'There was a problem processing this record!<br><br>' + event.fault.faultString, 'errorBox', true );
		}
		

		/**
		 * Delete a record
		 */		
		private function deleteRecord( event:RecordModuleEvent ):void
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteRecord', ObjectUtil.toString(event.recordVO));

			var handlers:IResponder = new mx.rpc.Responder(onResult_deleteRecord, onFault_deleteRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			_model.dataLoading = true;
			_presentationModel.formProcessing = true;

			delegate.deleteRecord( event.recordVO );
		}
				
		private function onResult_deleteRecord(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteRecord Success', ObjectUtil.toString(event.result));

			_presentationModel.formProcessing = false;

			switch(event.result.state)
			{
				case '88' :
					_model.errorVO = new ErrorVO( _presentationModel.layout.title +' record deleted successfully!', 'successBox', true );

					_presentationModel.lastQuery.dispatch();
					_presentationModel.searchListSelectedIndex = 0;
						
					_model.dataLoading = false;
				break;
				case '-88' :
					var eMsg:String = '';
					for(var j:String in event.result.errors)
						eMsg += '- ' + event.result.errors[j] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
					_model.dataLoading = false;
				break;	
			}
		}
		
		private function onFault_deleteRecord(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('deleteRecord Fail', ObjectUtil.toString(event.fault));
			
			_presentationModel.formProcessing = false;	
			_model.dataLoading = false;		
			_model.errorVO = new ErrorVO( 'There was a problem processing this record!<br><br>' + event.fault.faultString, 'errorBox', true );
		}


		
		/**
		 * Get a deleted record from the archive
		 */	
		private function getDeleted(event:RecordModuleEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getDeleted, onFault_getDeleted);
			var delegate:AuditDelegate = new AuditDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.fetchArchive( event.params.table, event.params.deletedID );
		}
				
		private function onResult_getDeleted(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getDeleted Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			_presentationModel.deletedRecord = event.result;
		}
		
		public function onFault_getDeleted(event:FaultEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}
	}
}