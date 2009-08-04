package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class EventsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function EventsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getEvents( iFrom:int, iCount:int, paginate:String, sort:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			sort = sort == '' ? 'events.created_on DESC' : sort;
			
			var token:AsyncToken = service.record_tree('events', null, sort, iFrom, iCount, paginate);			
			token.addResponder(responder);
		}
		
	
		public function searchEvents( searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSearch');
			
			var token:AsyncToken = service.table('events', searchTerm.replace(/ /g,"*")+'*', null, iCount, iFrom);
			token.addResponder(responder);
		}		
	

		public function searchContacts( searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');


			var where:Object = {
				'statement':'(1 OR 2)',
				'1':{ 
					'what' : 'contacts.fname',
					'val' : searchTerm.replace(/ /g,"%")+'%',
					'op' : 'LIKE'
				},
				'2':{ 
					'what' : 'contacts.lname',
					'val' : searchTerm.replace(/ /g,"%")+'%',
					'op' : 'LIKE'
				}
			};
						
			var token:AsyncToken = service.record_tree('contacts', where, null, iFrom, iCount);
			token.addResponder(responder);
		}


		public function attendEvent(params:Object):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.upsert('attend', params);
			token.addResponder(responder);
		}		

		public function generalSearch(table:String, searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSearch');
			
			var token:AsyncToken = service.table(table, searchTerm.replace(/ /g,"*")+'*', null, iCount,iFrom);
			token.addResponder(responder);
		}		
	
		

	}
}