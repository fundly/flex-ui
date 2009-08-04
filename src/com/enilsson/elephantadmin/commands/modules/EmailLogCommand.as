package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.LayoutDelegate;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.EmailEvent;
	import com.enilsson.elephantadmin.events.session.SessionFailEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.LayoutVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class EmailLogCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		private var _moduleName:String = 'email_log';
		
		public function EmailLogCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info(_moduleName + ' Command', ObjectUtil.toString(event.type)); }

			switch(event.type)
			{
				case EmailEvent.EMAIL_LOG_LAYOUT :
					getLayout(event as EmailEvent);
				break;
				case EmailEvent.EMAIL_LOG_RECORDS :
					getRecords(event as EmailEvent);
				break;
				case EmailEvent.EMAIL_LOG_SEARCH :
					searchRecords(event as EmailEvent);
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
		private function getLayout(event:EmailEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getLayout, onFault_getLayout);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getLayout( new LayoutVO("email_log") );
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
		private function getRecords(event:EmailEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRecords, onFault_getRecords);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			_model.email_log.lastQuery = EmailEvent(event);

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
			if(_model[_moduleName].records.length > 0){
				_model[_moduleName].details = _model[_moduleName].records[0];
				// Workaround to select the first element of the list
				_model[_moduleName].selectedIndex = -1;
				_model[_moduleName].selectedIndex = 0;
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
		private function searchRecords(event:EmailEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchRecords, onFault_searchRecords);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.dataLoading = true;
			_model.email_log.lastQuery = EmailEvent(event);

			delegate.search( event.params.searchVO );			
		}
				
		private function onResults_searchRecords(event:Object):void 
		{
			if(_model.debug){ Logger.info(_moduleName + ' search Success', ObjectUtil.toString(event.result)); }
			
			_model.dataLoading = false;
			
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
		}
		
		public function onFault_searchRecords(event:Object):void
		{
			if(_model.debug) Logger.info(_moduleName + ' search Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}		

	}
}