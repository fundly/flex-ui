package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.*;
	import com.enilsson.elephantadmin.events.modules.RecordEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephantadmin.vo.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class RecordCommand extends SequenceCommand
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'record';
		
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type));

			switch(event.type)
			{
				case RecordEvent.GET_FULL_RECORD :
					getFullRecord(event as RecordEvent);
				break;
				case RecordEvent.GET_AUDIT_TRAIL :
					getAuditTrail(event as RecordEvent);
				break;				
			}
		}


		/**
		 * Get the users table layout to build the form
		 */			
		private function getFullRecord(event:RecordEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getFullRecord, onFault_getFullRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getSidRecord( event.params.sid );			
		}
				
		private function onResult_getFullRecord(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getFullRecord Success', ObjectUtil.toString(event.result));
			
			var tableName:String = event.result.table_name;
			
			// if there is a record then get the audit trail
			if(event.result.hasOwnProperty(tableName))
			{
				_model.record.tree = event.result[tableName][1];
				_model.record.layout = _model.struktorLayout[tableName];
				_model.record.icon = _model.record.tableIcons[tableName];
				
				var params:Object = { 
					'table' : tableName, 
					'recordID' : _model.record.tree[_model.record.layout.primary_key] 
				};
				this.nextEvent = new RecordEvent( RecordEvent.GET_AUDIT_TRAIL, params );
				this.executeNextCommand();
				this.nextEvent = null;
			}
			// if the sid is not valid then show the alert window and return the user to the dashboard
			else
			{
				_model.dataLoading = false;
				
				Alert.show(	
					'Please select a valid record id before attempting to show record details',
					'Record ID is not valid', 
					0, 
					null,
					function(e:CloseEvent):void { _model.mainViewState = 0; },
					Icons.ALERT
				);
			}
		}
		
		public function onFault_getFullRecord(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getFullRecord Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}
		

		/**
		 * Get the audit trail for the record in question
		 */			
		private function getAuditTrail(event:RecordEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getAuditTrail, onFault_getAuditTrail);
			var delegate:AuditDelegate = new AuditDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.recordHistory( event.params.table, event.params.recordID );			
		}
				
		private function onResult_getAuditTrail(event:Object):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' getAuditTrail Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			_model.record.auditHistory = new ArrayCollection(event.result);
		}
		
		public function onFault_getAuditTrail(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' getAuditTrail Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}
	
	}
}