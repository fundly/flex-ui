package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class MyContactsDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyContactsDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getContact( contactID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.list_contacts( contactID );
			token.addResponder(responder);
		}
		
		public function getContactInfo( contactID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('tr_users_details', contactID );
			token.addResponder(responder);
		}		
		
		public function getContacts( userID:Number, iFrom:int, iCount:int, paginate:String, sort:String ):void
		{
 			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			sort = sort == '' ? 'lname ASC, fname ASC' : sort;
			
			var token:AsyncToken = service.list_contacts(null, null, sort, iFrom, iCount, paginate);			 
			token.addResponder(responder);
		}
		
		public function upsertContact( params:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.upsert_contact( params );
			token.addResponder(responder);
		}
		
		public function searchContacts( searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsContacts');
			
			var token:AsyncToken = service.search( searchTerm, null, iFrom, iCount);
			token.addResponder(responder);
		}
		
		public function contactTree( contactID:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var whereObj:Object =  new Object();
			whereObj['statement'] = '(1)';
			whereObj[1] = { 
				'what' : 'contacts.id',
				'val' : contactID,
				'op' : '='
			};
			
			var token:AsyncToken = service.record_tree( 'contacts(pledges<ALL>(event_id<source_code:name>))', contactID, 'contacts__pledges.pledge_date DESC' );
			token.addResponder(responder);
		}

		
		public function fetchContacts( from:int, limit:int ):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorImporter');
			
			var token:AsyncToken = service.fetch_imported( 'contacts', from, limit );
			token.addResponder(responder);
			
		}		
		
		public function importContacts(mappings:Array, rows:Array):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorImporter');
			
			var token:AsyncToken = service.migrate('contacts',mappings,rows);
			token.addResponder(responder);
			
		}
		
		public function deleteContact( contactID:int ):void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.del( 'contacts', contactID );
			token.addResponder(responder);		
		}		

		public function deleteContacts():void 
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorImporter');
			
			var token:AsyncToken = service.delete_imported();
			token.addResponder(responder);		
		}

	}
}