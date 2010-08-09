package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.MyContactsDelegate;
	import com.enilsson.elephanttrakker.business.PluginsDelegate;
	import com.enilsson.elephanttrakker.business.RecordsDelegate;
	import com.enilsson.elephanttrakker.events.modules.my_contacts.*;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.vo.ErrorVO;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class MyContactsCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		private var _event : CairngormEvent;

		public function MyContactsCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('MyContacts Command', ObjectUtil.toString(event.type));
			
			_event = event;
			
			switch(event.type)
			{
				case GetContactEvent.EVENT_GET_CONTACT :
					getContact(event as GetContactEvent);
				break;
				case GetContactEvent.EVENT_GET_CONTACT_INFO :
					getContactInfo(event as GetContactEvent);
				break;
				case GetMyContactsEvent.EVENT_GET_MYCONTACTS : 
					_model.my_contacts.lastQuery = event;
					getMyContacts(event as GetMyContactsEvent);
				break;
				case SearchMyContactsEvent.EVENT_SEARCH_MYCONTACTS :
					_model.my_contacts.lastQuery = event;
					searchContacts(event as SearchMyContactsEvent);
				break;
				case UpsertContactEvent.EVENT_UPSERT_CONTACT :
					upsertContact(event as UpsertContactEvent);
				break;
				case GetContactHistoryEvent.EVENT_GET_CONTACT_HISTORY : 
					getContactTree(event as GetContactHistoryEvent);
				break;				
				case ImportContactEvent.FETCH_CONTACTS: 
					fetchContacts(event as ImportContactEvent);
				break;				
				case ImportContactEvent.IMPORT_CONTACTS: 
					importContacts(event as ImportContactEvent);
				break;	
				case ImportContactEvent.DELETE_IMPORTED: 
					deleteImported(event as ImportContactEvent);
				break;	
				case ExportContactEvent.EXPORT_CONTACTS: 
					exportTables(event as ExportContactEvent);
				break;	
				case DeleteContactEvent.EVENT_DELETE_CONTACT :
					deleteContact( event as DeleteContactEvent );
				break;			
			}
			
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }


		/**
		 * Get a single Contact record
		 */
		private function getContact(event:GetContactEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContact, onFault_getContact);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);

			_model.dataLoading = true
			
			delegate.getContact( event.contactID );
		}

		private function onResults_getContact(data:Object):void 
		{
			if(_model.debug) Logger.info('getContact Success', ObjectUtil.toString(data.result));
			
			_model.my_contacts.contactData = data.result.contacts['1'];
			
			_model.dataLoading = false;
		}	

		private function onFault_getContact(data:Object):void
		{
			if(_model.debug) Logger.info('getContact Fault');	
			
			_model.dataLoading = false;			
		}				

		/**
		 * Get a single Contact record
		 */
		private function getContactInfo(event:GetContactEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContactInfo, onFault_getContactInfo);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);

			_model.dataLoading = true
			
			delegate.getContactInfo( event.contactID );
		}

		private function onResults_getContactInfo(data:Object):void 
		{
			if(_model.debug) Logger.info('getContactInfo Success', ObjectUtil.toString(data.result));
			
			_model.my_contacts.contactInfo = data.result.tr_users_details['1'];
			_model.my_contacts.sharedName = _model.my_contacts.contactInfo.fname + ' ' + _model.my_contacts.contactInfo.lname + ' ('+_model.my_contacts.contactInfo._fid+')';
			
			
			_model.dataLoading = false;
		}	

		private function onFault_getContactInfo(data:Object):void
		{
			if(_model.debug) Logger.info('getContactInfo Fault');
			
			_model.dataLoading = false;			
		}				

		/**
		 * Process the My Contacts data
		 */
		private function getMyContacts(event:GetMyContactsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getMyContacts, onFault_getMyContacts);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			_model.dataLoading = true
					
			delegate.getContacts( _model.session.user_id, event.iFrom, event.iCount, event.paginate, event.sort );
		}

		private function onResults_getMyContacts(data:Object):void 
		{
			if(_model.debug) Logger.info('getMyContacts Success', ObjectUtil.toString(data.result));
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.contacts)
			{
				item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
				item['fullName'] = item.lname + ', ' + item.fname;
				item['shared'] = ((item.created_by_id != _model.session.user_id) ? true : false)
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.my_contacts.contacts = dp;
			
			_model.my_contacts.contacts.refresh();
			
			// show the contacts table
			_model.my_contacts.showTable = true;
			
			// save the number of contacts
			if(data.result.total_rows)
				_model.my_contacts.numContacts = parseInt(data.result.total_rows);
				
			if (_model.my_contacts.numContacts <= 0) 
			{
				_model.my_contacts.contactData = null;		
				_model.my_contacts.showContactForm = true;
			}
			
			// show the pagination
			_model.my_contacts.showPagination = _model.my_contacts.numContacts > _model.itemsPerPage;
			
			_model.dataLoading = false;
			
		}	

		private function onFault_getMyContacts(data:Object):void
		{
			if(_model.debug) Logger.info('getMyContacts Fault');	
			
			_model.dataLoading = false;			
		}		


		/**
		 * Delete a Contact record
		 */
		private function deleteContact( event:DeleteContactEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteContact, onFault_deleteContact);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);

			_model.dataLoading = true;
			
			delegate.deleteContact( event.contactID );
		}

		private function onResults_deleteContact(event:Object):void 
		{
			if(_model.debug) Logger.info('deleteContact Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;

			switch (event.result.state)
			{
				case '-87' :
				case '-88' :
					var eMsg:String = 'There was a problem deleting this contact:<br><br>';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.my_contacts.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;
				case '88' :
					_model.my_contacts.errorVO = new ErrorVO( 'That contact was successfully deleted', 'successBox', true );
					
					this.nextEvent = _model.my_contacts.lastQuery;
					this.executeNextCommand();
					this.nextEvent = null;
				break;				
			}
		}	

		private function onFault_deleteContact(event:Object):void
		{
			if(_model.debug) Logger.info('deleteContact Fault');
			
			_model.dataLoading = false;			
		}				

		
		
		/**
		 * Search the contacts table
		 */
		private function searchContacts(event:SearchMyContactsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchContacts, onFault_searchContacts);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			_model.dataLoading = true
			
			delegate.searchContacts( event.searchTerm, event.iFrom, event.iCount );
		}
		
		private function onResults_searchContacts(data:Object):void 
		{
			if(_model.debug) Logger.info('searchContacts Success', ObjectUtil.toString(data.result));
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result[0].contacts)
			{
				item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
				item['fullName'] = item.lname + ', ' + item.fname;
				item['shared'] = ((item.created_by_id != _model.session.user_id) ? true : false)
				
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.my_contacts.contacts = dp;
			// show the contacts table
			_model.my_contacts.showTable = true;
			// save the number of contacts
			_model.my_contacts.numContacts = parseInt(data.result[0].found_rows);
			// show the pagination
			_model.my_contacts.showPagination = _model.my_contacts.numContacts > _model.itemsPerPage;
			
			_model.dataLoading = false;
		}	
		private function onFault_searchContacts(data:Object):void
		{
			if(_model.debug) Logger.info('searchContacts Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}	
		
		
		/**
		 * Upsert a contact record
		 */
		private function upsertContact(event:UpsertContactEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertContact, onFault_upsertContact);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			_model.dataLoading = true

			_model.my_contacts.isSubmitting = true;
			
			delegate.upsertContact( event.formData );
		}

		private function onResults_upsertContact(data:Object):void 
		{
			if(_model.debug){ Logger.info('upsertContact Success', ObjectUtil.toString(data.result)); }
			
			switch(data.result.state)
			{
				case '99' :
					_model.my_contacts.resetPopupContactForm();
					
					var e		: UpsertContactEvent 	= _event as UpsertContactEvent;
					var message : String; 
					
					if ( e != null && e.formData['id'] === undefined ) {
						message = 'A duplicate contact you own has been edited';
					}
					else {
						message = 'That contact was successfully edited';
					}
					
					_model.my_contacts.errorVO = new ErrorVO( message, 'successBox', true );
					_model.my_contacts.onClose = function():void {
						_model.my_contacts.isSubmitting = false;
					}
					
					this.nextEvent = _model.my_contacts.lastQuery;
					this.executeNextCommand();
					this.nextEvent = null;
				break;
				case '98' :
					_model.my_contacts.resetPopupContactForm();
					
					_model.my_contacts.errorVO = new ErrorVO( 'That contact was successfully added', 'successBox', true );
					_model.my_contacts.onClose = function():void
					{
						_model.my_contacts.isSubmitting = false;
						_model.my_contacts.showContactForm = false;
					}
					
					this.nextEvent = _model.my_contacts.lastQuery;
					this.executeNextCommand();
					this.nextEvent = null;
				break;
				case '-99' :				
					var eMsg:String = '';
					for(var i:String in data.result.errors)
					{
						eMsg += '- ' + data.result.errors[i] + '<br>'
					}
					_model.my_contacts.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
					_model.my_contacts.onClose = function():void {
						_model.my_contacts.isSubmitting = false;
					}
				break;	
			}

			_model.dataLoading = false;
		}	

		private function onFault_upsertContact(data:Object):void
		{
			if(_model.debug){ Logger.info('upsertContact Fault', ObjectUtil.toString(data.fault)); }	

			_model.my_contacts.errorVO = new ErrorVO( 'There was an error processing this contact record!' + data.fault, 'errorBox', true );
			_model.my_contacts.onClose = function():void {
				_model.my_contacts.isSubmitting = false;
			}
						
			_model.dataLoading = false;			
		}	
		

		/**
		 * Get Contact Pledge History
		 */
		private function getContactTree(event:GetContactHistoryEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContactTree, onFault_getContactTree);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			if(_model.debug) Logger.info('getContactTree Call', event.contactID);
			
			_model.dataLoading = true;
			_model.my_contacts.pledgeStack = 0;
			
			var w:Object =  {
				'statement' : '(1)',
				'1' : { 'what' : 'pledges.contact_id', 'val' : event.contactID, 'op' : '=' }
			};
			var r:RecordsVO = new RecordsVO('pledges<ALL>(event_id<source_code:name>)', w, 'pledges.pledge_date DESC', 0, 1000);

			delegate.getRecords( r );
		}
		
		private function onResults_getContactTree(data:Object):void 
		{
			if(_model.debug) Logger.info('getContactTree Success', ObjectUtil.toString(data.result));

			if(data.result.pledges)
			{
				var d:Object = data.result.pledges;
				
				if (d['1'])
					_model.my_contacts.pledgeStack = 1;
				else
					_model.my_contacts.pledgeStack = 2;				
				
				// add some convenience items to the contacts array collection
				var dp:ArrayCollection = new ArrayCollection();		
				for each( var item:Object in d)
				{
					item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;	
					item['sourceCode'] = item.event_id.source_code;
					item['eventName'] = item.event_id.name;				
					dp.addItem(item);				
				}		

				_model.my_contacts.contactPledges = dp;
			}
			else
				_model.my_contacts.pledgeStack = 2;
			
			_model.dataLoading = false;
		}	
		
		private function onFault_getContactTree(data:Object):void
		{
			if(_model.debug) Logger.info('getContactTree Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}
		
		
		/**
		 * Import Contacts
		 */
		private function fetchContacts(event:ImportContactEvent):void
		{			
			if(_model.debug) Logger.info('fetch imported contacts');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_fetchContacts, onFault_fetchContacts);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.fetchContacts( event.obj.from, event.obj.limit );
		}

		private function onResults_fetchContacts( event:Object ):void 
		{
			if(_model.debug) Logger.info('Fetch Imported Contacts Success', ObjectUtil.toString( event.result ));
			
			_model.dataLoading = false;
			_model.my_contacts.importData = new ArrayCollection();
			
			for (var index:String in event.result.data)
			{
				var data:Object = event.result.data[index];
				data.selected = _model.my_contacts.importIgnore.indexOf(data.id) == -1;
				_model.my_contacts.importData.addItem(event.result.data[index]);
				
/* 				// add the row to the imported data
				_model.my_contacts.importData.addItem(event.result.data[index]);
				
				// if browsing through the records make sure the unchecked records remain
				var data:Object = _model.my_contacts.importData.getItemAt(Number(index));
				var ignore:Boolean = _model.my_contacts.importIgnore.indexOf(data.id) == -1
				_model.my_contacts.importData.getItemAt(Number(index)).selected = ignore;
 */			}			

			// check if they are including the headers in the first line
			if (_model.my_contacts.headerFirst && _model.my_contacts.importCurrPage == 0) 
			{
				_model.my_contacts.firstRow = _model.my_contacts.importData.getItemAt(0);
				_model.my_contacts.importData.removeItemAt(0);				
			}
			
			// set the total number of imports	
			_model.my_contacts.importTotal = event.result.total;
			
			if(_model.debug) Logger.info('Import Total', event.result.total);
			
			// notify the view that the upload is complete
			this.nextEvent = new ImportContactEvent("contacts_imported");
			this.executeNextCommand();
			this.nextEvent = null;
		}	

		private function onFault_fetchContacts(data:Object):void
		{
			if(_model.debug) Logger.info('fetch Contacts Fault', ObjectUtil.toString(data.fault));
			
			_model.dataLoading = false;			
		}				


		/**
		 * Import Contacts
		 */
		private function importContacts(event:ImportContactEvent):void
		{			
			if(_model.debug){ Logger.info('Importing Contacts....', ObjectUtil.toString(event.obj)); }

			var handlers:IResponder = new mx.rpc.Responder(onResults_importContacts, onFault_importContacts);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			_model.dataLoading = true
			delegate.importContacts( event.obj.mappings, event.obj.rows );
		}

		private function onResults_importContacts(data:Object):void 
		{
			if(_model.debug){ Logger.info('import Contacts Success', ObjectUtil.toString(data.result)); }
			
			_model.dataLoading = false;
			
			if (data.result.state) 
			{
				_model.my_contacts.stackIndex = 3;
				_model.my_contacts.importMessage = '<br><b>' + data.result.rows + '</b> records inserted';
				
				this.nextEvent = new GetMyContactsEvent(GetMyContactsEvent.EVENT_GET_MYCONTACTS, 0, _model.itemsPerPage, 'P',  'lname ASC, fname ASC');
				this.executeNextCommand();
				this.nextEvent = null;			
			} 
			else 
			{
				_model.my_contacts.errorVO = new ErrorVO( 
					'There was a problem processing this record:<br><br>' + data.result.error, 
					'errorBox', 
					true 
				);
				_model.my_contacts.onClose = null;
			}
		}	

		private function onFault_importContacts(data:Object):void
		{
			if(_model.debug) Logger.info('import Contacts Fault');	
			
			_model.dataLoading = false;			
		}				
		
		/**
		 * Export the users contacts into a CSV file
		 */
		private function exportTables(event:ExportContactEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportTables, onFault_exportTables);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);

			_model.dataLoading = true;

			delegate.export_contacts();
		}

		private function onResults_exportTables(data:Object):void 
		{
			if(_model.debug) Logger.info('exportTables Success', ObjectUtil.toString(data.result));
			
			var d:Date = new Date();
			var df:DateFormatter = new DateFormatter();
			df.formatString = 'MMDDYYYY';
			
			navigateToURL( new URLRequest( _model.gatewayBaseURL + '/export.php?id=' + data.result + '&file_name=my-blueswarm-contacts-' + df.format(d) ), '_parent' );
			
			_model.dataLoading = false;
		}	

		private function onFault_exportTables(data:Object):void
		{
			if(_model.debug) Logger.info('exportTables Fault');	
			
			_model.dataLoading = false;			
		}			


		/**
		 * Import Contacts
		 */
		private function deleteImported(event:ImportContactEvent):void
		{			
			if(_model.debug){ Logger.info('delete imported contacts'); }
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteImported, onFault_deleteImported);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			delegate.deleteContacts();
		}

		private function onResults_deleteImported(data:Object):void 
		{
			if(_model.debug) Logger.info('delete imported Success', ObjectUtil.toString(data.result));
		}	

		private function onFault_deleteImported(data:Object):void
		{
			if(_model.debug) Logger.info('delete imported Fault');	
		}				
										
	}
}