package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.*;
	import com.enilsson.elephanttrakker.events.modules.calls_reminders.CallsReminders_Event;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.LayoutVO;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class CallsRemindersCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function CallsRemindersCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('CallsReminders Command', ObjectUtil.toString(event.type));
			
			switch(event.type)
			{
				case CallsReminders_Event.EVENT_CR_CALLS_LAYOUT :
					getCallsLayout(event as CallsReminders_Event);
				break;
				case CallsReminders_Event.EVENT_CR_CALLS_SEARCHCONTACTS :
					searchContacts(event as CallsReminders_Event);
				break;
			}			
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }


		/**
		 * Get a layout for the calls form
		 */
		private function getCallsLayout(event:CallsReminders_Event):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getCallsLayout, onFault_getCallsLayout);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			_model.dataLoading = true
			
			delegate.getLayout( new LayoutVO('calls') );
		}

		private function onResults_getCallsLayout(data:Object):void 
		{
			if(_model.debug){ Logger.info('getCallsLayout Success', ObjectUtil.toString(data.result)); }
			
			_model.calls_reminders.callsLayout = data.result[0];
			
			_model.dataLoading = false;
		}	

		private function onFault_getCallsLayout(data:Object):void
		{
			if(_model.debug){ Logger.info('getCallsLayout Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}				
		
		
		/**
		 * Get a layout for the calls form
		 */
		private function searchContacts(event:CallsReminders_Event):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchContacts, onFault_searchContacts);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			if(_model.debug){ Logger.info('searchContacts Run', ObjectUtil.toString(event.params)); }
			
			var whereObj:Object =  new Object();
			whereObj['statement'] = '(1)';
			whereObj[1] = { 
				'what' : "contacts.lname",
				'val' : event.params.searchTerm + '%',
				'op' : 'LIKE'
			};
			
			var r:RecordsVO = new RecordsVO('contacts', whereObj, null, 0, event.params.searchCount);
			
			delegate.getRecords( r );
		}

		private function onResults_searchContacts(data:Object):void 
		{
			if(_model.debug){ Logger.info('searchContacts Success', ObjectUtil.toString(data.result)); }
			
			var dp:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in data.result.contacts )
			{
				item['value'] = item.id;				
				item['label'] = item.lname + ', ' + item.fname;								
				dp.addItem( item );
			}

			if(_model.debug){ Logger.info('searchContacts dataprovider', ObjectUtil.toString(dp)); }
			
			_model.calls_reminders.callsContactsSearch = dp;
		}	

		private function onFault_searchContacts(data:Object):void
		{
			if(_model.debug){ Logger.info('searchContacts Fault', ObjectUtil.toString(data.fault)); }	
		}						

		
	}
}