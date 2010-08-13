package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.EventsDelegate;
	import com.enilsson.elephanttrakker.events.modules.events.EventsEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class EventsCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();

		public function EventsCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('Events Command', ObjectUtil.toString(event.type)); }
			
			switch(event.type)
			{
				case EventsEvent.EVENT_GET_EVENTS :
					getEvents(event as EventsEvent);
				break;
				case EventsEvent.EVENT_SEARCH_CONTACTS :
					searchContacts(event as EventsEvent);
				break;
				case EventsEvent.EVENT_SEARCH_EVENTS :
					searchEvents(event as EventsEvent);
				break;
				case EventsEvent.EVENT_ATTEND_EVENT :
					attendEvent(event as EventsEvent);
				break;
				case EventsEvent.EVENT_SEARCH :
					generalSearch(event as EventsEvent);
				break;
			}
			
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }


		/**
		 * Get the events
		 */
		private function getEvents(event:EventsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getEvents, onFault_getEvents);
			var delegate:EventsDelegate = new EventsDelegate(handlers);
			
			_model.dataLoading = true
			
			delegate.getEvents( event.obj.iFrom, event.obj.iCount, event.obj.paginate, event.obj.sort );
		}
			


		private function onResults_getEvents(data:Object):void 
		{
			if(_model.debug){ Logger.info('get Events Success', ObjectUtil.toString(data.result)); }
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.events)
			{
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.events.events = dp;
			
			// show the contacts table
			_model.events.showTable = true;
			
			// save the number of contacts
			if(data.result.total_rows)
				_model.events.numEvents = parseInt(data.result.total_rows);
				
			// show the pagination
			_model.events.showPagination = _model.events.numEvents > _model.itemsPerPage;
			
			_model.dataLoading = false;
		}	

		private function onFault_getEvents(data:Object):void
		{
			if(_model.debug){ Logger.info('get Events Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}		

		
		
		
		/**
		 * Search the contacts table
		 */
		private function searchEvents(event:EventsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchEvents, onFault_searchEvents);
			var delegate:EventsDelegate = new EventsDelegate(handlers);
			
			_model.dataLoading = true
			if(_model.debug){ Logger.info('search Events RUN', ObjectUtil.toString(event.obj)); }
			
			delegate.searchEvents( event.obj.searchTerm, event.obj.iFrom, event.obj.searchCount );
		}

		private function onResults_searchEvents(data:Object):void 
		{
			if(_model.debug){ Logger.info('search Events Success', ObjectUtil.toString(data.result)); }
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result[0].events)
			{
				dp.addItem(item);				
			}
			
			// assign the altered array collection to the model for binding
			_model.events.events = dp;
			// show the contacts table
			_model.events.showTable = true;
			// save the number of contacts
			_model.events.numEvents = parseInt(data.result[0].found_rows);
			// show the pagination
			_model.events.showPagination = _model.events.numEvents > _model.itemsPerPage;
			
			_model.dataLoading = false;
		}	

		private function onFault_searchEvents(data:Object):void
		{
			if(_model.debug){ Logger.info('search Events Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}	

		
		/**
		 * Search Contacts
		 */
		private function searchContacts(event:EventsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchContacts, onFault_searchContacts);
			var delegate:EventsDelegate = new EventsDelegate(handlers);
			
			if(_model.debug){ Logger.info('searchContacts Run', ObjectUtil.toString(event.obj)); }
			
			delegate.searchContacts( event.obj.searchTerm, 0, event.obj.iCount );
		}

		private function onResults_searchContacts(data:Object):void 
		{
			if(_model.debug){ Logger.info('searchContacts Success', ObjectUtil.toString(data.result)); }
			
			var dp:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in data.result.contacts )
			{
					item['label'] = item.lname + ', ' + item.fname;				
					item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
					item['fullName'] = item.lname + ', ' + item.fname;
				
				dp.addItem( item );
			}

			if(_model.debug){ Logger.info('searchContacts dataprovider', ObjectUtil.toString(dp)); }
			_model.events.events_contactsSearch = dp
		}	

		private function onFault_searchContacts(data:Object):void
		{
			if(_model.debug){ Logger.info('searchContacts Fault', ObjectUtil.toString(data.fault)); }	
		}						


		
		/**
		 * RSVP a contact
		 */
		private function attendEvent(event:EventsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_attendEvent, onFault_attendEvent);
			var delegate:EventsDelegate = new EventsDelegate(handlers);
			
			if(_model.debug){ Logger.info('attendEvent Run', ObjectUtil.toString(event.obj)); }
			
			_model.events.isSubmitting = true;

			delegate.attendEvent(event.obj);
		}

		private function onResults_attendEvent(data:Object):void 
		{
			if(_model.debug){ Logger.info('attendEvent Success', ObjectUtil.toString(data.result)); }
			
			switch(data.result.state)
			{
				case '99' :
				case '98' :
					_model.events.errorVO = new ErrorVO( 'This RSVP was successfully saved', 'successBox', true );
					_model.events.onClose = function():void
					{
						_model.events.showRSVPForm = false;
						_model.events.isSubmitting = false;
					}

				break;
				case '-99' :				
					var eMsg:String = "";
					
					for(var i:String in data.result.errors)
						eMsg += '- ' + data.result.errors[i] + '<br>';
						
					_model.events.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
					_model.events.onClose = function():void {
						_model.events.isSubmitting = false;
					}
				break;	
			}
		}	

		private function onFault_attendEvent(data:Object):void
		{
			if(_model.debug){ Logger.info('attendEvent Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.events.errorVO = new ErrorVO( 'There was an error processing this attending record!' + data.fault, 'errorBox', true );

			_model.events.onClose = function():void {
				_model.events.isSubmitting = false;
			}
		}						


	
		/**
		 * General Search
		 */
		private function generalSearch(event:EventsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_generalSearch, onFault_generalSearch);
			var delegate:EventsDelegate = new EventsDelegate(handlers);
			
			if(_model.debug){ Logger.info('General Search Run', ObjectUtil.toString(event.obj)); }
			
			delegate.generalSearch( event.obj.table, event.obj.searchTerm, event.obj.iFrom, event.obj.searchCount );
		}

		private function onResults_generalSearch(data:Object):void 
		{
			if(_model.debug){ Logger.info('General Search Success', ObjectUtil.toString(data.result)); }
			var dp:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in data.result[0][data.result[0].table_name] )
			{
				item['value'] = item.id;				

				if (data.result[0].table_name == "contacts") {				
					item['label'] = item.lname + ', ' + item.fname;				
					item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
					item['fullName'] = item.lname + ', ' + item.fname;
				} else {
					item['label'] = item.name;				
				}
				
				dp.addItem( item );
			}

			if(_model.debug){ Logger.info('General Search dataprovider', ObjectUtil.toString(dp)); }
			
			_model.events['events_'+data.result[0].table_name+'Search'] = dp;
		}	

		private function onFault_generalSearch(data:Object):void
		{
			if(_model.debug){ Logger.info('General Search Fault', ObjectUtil.toString(data.fault)); }	
		}						

		
							
	}
}