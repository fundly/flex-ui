package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.EventsEvent;
	import com.enilsson.elephantadmin.views.modules.events.model.EventsModel;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class EventsCommand extends RecordModuleCommand
	{
		private var _eventsModel:EventsModel;

		public function EventsCommand()
		{
			super();
			_moduleName = 'Events Module';
		}
		
		override public function execute(event:CairngormEvent):void
		{
			super.execute(event);

			_eventsModel = EventsModel(_presentationModel);

			switch(event.type)
			{
				case EventsEvent.EXPORT :
					exportTable( event as EventsEvent );
				break;
				case EventsEvent.GET_HOSTS :
					getHosts( event as EventsEvent );
				break;
				case EventsEvent.LOOKUP_SEARCH :
					hostsLookup( event as EventsEvent );
				break;
				case EventsEvent.UPSERT_HOST_RECORD :
					upsertHostRecord( event as EventsEvent );
				break;
				case EventsEvent.DELETE_HOST_RECORD :
					deleteHostRecord( event as EventsEvent );
				break;
			}
		}	

		/**
		 * Export the table
		 */
		private function exportTable(event:EventsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportTable, onFault_exportTable);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true

			delegate.exportRecords(event.params.recordVO);
		}

		private function onResults_exportTable(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('exportTables Success', ObjectUtil.toString(data.result));

			navigateToURL(new URLRequest(_model.gatewayBaseURL + '/export.php?id='+data.result),'_parent') 

			_model.dataLoading = false;
		}

		private function onFault_exportTable(data:FaultEvent):void
		{
			if(_model.debug) Logger.info('exportTables Fault', ObjectUtil.toString(data.fault));

			_model.dataLoading = false;
		}
		
		
		/**
		 * Get the list of event hosts for a specific events
		 */
		private function getHosts( event:EventsEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getHosts, onFault_getHosts);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true

			delegate.getRecords( event.recordsVO );			
		}
		
		private function onResults_getHosts( event:ResultEvent ):void 
		{
			if(_model.debug) Logger.info('getHosts Success', ObjectUtil.toString( event.result ));

			_model.dataLoading = false;
			
			var records:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in event.result[event.result.table_name] )
				records.addItem( item );
				
			_eventsModel.hostCommittee = records;			
		}

		private function onFault_getHosts( event:FaultEvent ):void 
		{
			//if(_model.debug) 
			Logger.info('getHosts Fault', ObjectUtil.toString( event.fault ));

			_model.dataLoading = false;
		}


		/**
		 * Get the list of event hosts for a specific events
		 */
		private function hostsLookup( event:EventsEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_hostsLookup, onFault_hostsLookup);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true

			delegate.search( event.searchVO );			
		}
		
		private function onResults_hostsLookup( event:ResultEvent ):void 
		{
			if(_model.debug) Logger.info('hostsLookup Success', ObjectUtil.toString( event.result ));

			_model.dataLoading = false;
			
			var records:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in event.result['0'].tr_users_details )
			{
				item['value'] = item.user_id;				
				item['label'] = item.lname + ', ' + item.fname;								
				records.addItem( item );
			}
				
			_eventsModel.hostsList = records;			
		}

		private function onFault_hostsLookup( event:FaultEvent ):void 
		{
			if(_model.debug) Logger.info('hostsLookup Fault', ObjectUtil.toString( event.fault ));

			_model.dataLoading = false;
		}


		/**
		 * Upsert a host record
		 */
		private function upsertHostRecord( event:EventsEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertHostRecord, onFault_upsertHostRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
			_eventsModel.hostCommitteeProcessing = true;
			
			delegate.upsertRecord( event.recordVO );
		}
		
		private function onResults_upsertHostRecord( event:ResultEvent ):void 
		{
			//if(_eventsModel.debug) 
			Logger.info('upsertHostRecord Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			_eventsModel.hostCommitteeProcessing = false;

			switch(event.result.state)
			{
				case '98' :
					_eventsModel.newHost['id'] = event.result.details;
					_eventsModel.hostCommittee.addItem( _eventsModel.newHost );
				case '99' :

				break;
				case '-99' :
					var eMsg:String = '';
					
					if( typeof(event.result.errors) == 'Array')
						for(var i:String in event.result.errors)
							eMsg += '- ' + event.result.errors[i] + '<br>';
					else
						eMsg = event.result.errors;
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}	
		
		private function onFault_upsertHostRecord( event:FaultEvent ):void
		{
			if(_eventsModel.debug) Logger.info('upsertHostRecord Fault', ObjectUtil.toString(event.fault));	
			
			_model.dataLoading = false;			
			_model.errorVO = new ErrorVO( 
				'There was a problem processing this record!<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}	


		/**
		 * Delete a committee member
		 */		
		private function deleteHostRecord( event:EventsEvent ):void
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteHostRecord', ObjectUtil.toString(event.recordVO));

			var handlers:IResponder = new mx.rpc.Responder(onResult_deleteHostRecord, onFault_deleteHostRecord);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			_model.dataLoading = true;
			_eventsModel.hostCommitteeProcessing = true;

			delegate.deleteRecord( event.recordVO );
		}
				
		private function onResult_deleteHostRecord( event:ResultEvent ):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteHostRecord Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			_eventsModel.hostCommitteeProcessing = false;

			switch(event.result.state)
			{
				case '88' :
					_model.errorVO = new ErrorVO( 'Committee member deleted successfully!', 'successBox', true );
					
					for ( var i:int = 0; i < _eventsModel.hostCommittee.length; i++ )
						if ( _eventsModel.hostCommittee[i].id == _eventsModel.deleteHostID )
							_eventsModel.hostCommittee.removeItemAt(i);
					
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

				break;	
			}
		}
		
		private function onFault_deleteHostRecord( event:FaultEvent ):void
		{
			if(_model.debug) Logger.info('deleteHostRecord Fail', ObjectUtil.toString(event.fault));
			
			_model.dataLoading = false;		
			_model.errorVO = new ErrorVO( 'There was a problem processing this record!<br><br>' + event.fault.faultString, 'errorBox', true );
		}

		
	}
}