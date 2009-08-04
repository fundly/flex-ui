package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.AuditDelegate;
	import com.enilsson.elephantadmin.business.LayoutDelegate;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.ResourcesEvent;
	import com.enilsson.elephantadmin.events.session.SessionFailEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.LayoutVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	import flash.net.URLRequest
	import flash.net.navigateToURL;	

	import org.osflash.thunderbolt.Logger;

	public class ResourcesCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'resources';
		
		public function ResourcesCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case ResourcesEvent.RESOURCES_LAYOUT :
					getLayout(event as ResourcesEvent);
				break;
				case ResourcesEvent.RESOURCES_RECORDS :
					getRecords(event as ResourcesEvent);
				break;
				case ResourcesEvent.RESOURCES_SEARCH :
					searchRecords(event as ResourcesEvent);
				break;
				case ResourcesEvent.RESOURCES_UPSERT :
					upsertRecord(event as ResourcesEvent);
				break;
				case ResourcesEvent.RESOURCES_DELETE :
					deleteRecord(event as ResourcesEvent);
				break;
				case ResourcesEvent.RESOURCES_ACTIVITY :
					recordActivity(event as ResourcesEvent);
				break;
				case ResourcesEvent.RESOURCES_EXPORT :
					exportTable(event as ResourcesEvent);
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
		private function getLayout(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getLayout, onFault_getLayout);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getLayout( new LayoutVO(_moduleName) );			
		}
				
		private function onResult_getLayout(event:Object):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' getLayout Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;
			
			_model[_moduleName].layout = event.result[0];	
		}
		
		public function onFault_getLayout(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getLayout Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}


		/**
		 * Get the users table layout to build the form
		 */			
		private function getRecords(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			_model.resources.lastQuery = ResourcesEvent(event);
				
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

			if(_model[_moduleName].records.length > 0)
			{
				if(_model[_moduleName].lastIndex == -1)
				{
					// Workaround to select the first element of the list
					_model[_moduleName].formRecord = _model[_moduleName].records[0];
					_model[_moduleName].selectedIndex = -1;
					_model[_moduleName].selectedIndex = 0;
				}
				else
				{
					if(_model[_moduleName].records.length > _model[_moduleName].lastIndex)
					{
						_model[_moduleName].formRecord = _model[_moduleName].records[_model[_moduleName].lastIndex];
						_model[_moduleName].selectedIndex = -1;
						_model[_moduleName].selectedIndex = _model[_moduleName].lastIndex;
						_model[_moduleName].lastIndex = -1;
					}
					else
					{
						_model[_moduleName].formRecord = _model[_moduleName].records[0];
						_model[_moduleName].selectedIndex = -1;
						_model[_moduleName].selectedIndex = 0;
						_model[_moduleName].lastIndex = -1;
					}
				}
			}
		}
		
		public function onFault_getRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getRecords Fail', ObjectUtil.toString(event));
			
			_model.dataLoading = false;
		}
		

		/**
		 * Get the table layout to build the form
		 */			
		private function searchRecords(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
			_model.resources.lastQuery = ResourcesEvent(event);
				
			delegate.search( event.params.searchVO );			
		}
				
		private function onResults_searchRecords(event:Object):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' search Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;

			if(event.result.length > 0)
				_model[_moduleName].totalRecords = event.result[0].found_rows;
			
			var tableName:String = event.result[0].table_name;
			
			_model[_moduleName].records = new ArrayCollection();
			for each( var item:Object in event.result[0][tableName])
			{
				_model[_moduleName].records.addItem(item);
			}
			
			if(_model[_moduleName].records.length > 0)
			{
				if(_model[_moduleName].lastIndex == -1)
				{
					// Workaround to select the first element of the list
					_model[_moduleName].formRecord = _model[_moduleName].records[0];
					_model[_moduleName].selectedIndex = -1;
					_model[_moduleName].selectedIndex = 0;
				}
				else
				{
					if(_model[_moduleName].records.length > _model[_moduleName].lastIndex)
					{
						_model[_moduleName].formRecord = _model[_moduleName].records[_model[_moduleName].lastIndex];
						_model[_moduleName].selectedIndex = -1;
						_model[_moduleName].selectedIndex = _model[_moduleName].lastIndex;
						_model[_moduleName].lastIndex = -1;
					}
					else
					{
						_model[_moduleName].formRecord = _model[_moduleName].records[0];
						_model[_moduleName].selectedIndex = -1;
						_model[_moduleName].selectedIndex = 0;
						_model[_moduleName].lastIndex = -1;
					}
				}
			}
		}
		
		public function onFault_searchRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' search Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}		
		
		
		/**
		 * Upsert a record
		 */			
		private function upsertRecord(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertRecord, onFault_upsertRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model[_moduleName].formProcessing = true;
			_model[_moduleName].lastIndex = _model[_moduleName].selectedIndex;

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
					_model[_moduleName].lastQuery.dispatch();
					_model[_moduleName].selectedIndex = _model[_moduleName].lastIndex;

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
		 * Delete a record
		 */			
		private function deleteRecord(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteRecord, onFault_deleteRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model[_moduleName].formProcessing = true;
			_model[_moduleName].lastIndex = _model[_moduleName].selectedIndex;

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
					_model[_moduleName].lastQuery.dispatch();
					_model[_moduleName].selectedIndex = _model[_moduleName].lastIndex;

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
				default:
					// run the session fail event
					this.nextEvent = new SessionFailEvent( event.fault.faultCode );
					this.executeNextCommand();
					this.nextEvent = null;
				break;
			}

		}	

		/**
		 * Get the record activity
		 */			
		private function recordActivity(event:ResourcesEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_recordActivity, onFault_recordActivity);
			var delegate:AuditDelegate = new AuditDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.recordHistory( event.params.table, event.params.recordID );			
		}
				
		private function onResults_recordActivity(event:Object):void 
		{
			if(_model.debug){ Logger.info('recordActivity Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;
			
			_model[_moduleName].recordActivity = new ArrayCollection();

			for each( var item:Object in event.result)
				_model[_moduleName].recordActivity.addItem(item);
				
			var create:Object = { 
				'fname' : _model[_moduleName].formRecord.created_by,
				'lname' : '',
				'action' : 'CREATE',
				'timestamp' : _model[_moduleName].formRecord.created_on
			};
			_model[_moduleName].recordActivity.addItem(create);				
		}
		
		public function onFault_recordActivity(event:Object):void
		{
			if(_model.debug) Logger.info('recordActivity Fail', ObjectUtil.toString(event.result));		
			
			_model.dataLoading = false;
		}							
		
		/**
		 * Export the table
		 */			

		private function exportTable(event:ResourcesEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportTable, onFault_exportTable);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true

			delegate.exportRecords(event.params.recordVO);
		}

		private function onResults_exportTable(data:Object):void 
		{
			if(_model.debug) Logger.info('exportTables Success', ObjectUtil.toString(data.result));
			
			navigateToURL(new URLRequest(_model.gatewayBaseURL + '/export.php?id='+data.result),'_parent') 
			
			_model.dataLoading = false;
		}	

		private function onFault_exportTable(data:Object):void
		{
			if(_model.debug) Logger.info('exportTables Fault', ObjectUtil.toString(data.fault));
			
			_model.dataLoading = false;			
		}		
	}
}