package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.PluginsDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.events.modules.ContactsEvent;
	import com.enilsson.elephantadmin.views.modules.contacts.model.ContactsModel;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class ContactsCommand extends RecordModuleCommand
	{
		private var _contactsModel:ContactsModel;
		
		public function ContactsCommand()
		{
			super();
			_moduleName = 'Contacts';
		}
		
		override public function execute(event:CairngormEvent):void
		{
			super.execute(event);

			_contactsModel = ContactsModel(_presentationModel);

			switch(event.type)
			{
				case ContactsEvent.UPSERT_CONTACT :
					upsertContactRecord(event as ContactsEvent);
				break;
				case ContactsEvent.GET_SHARED_USERS :
					getSharedUsers(event as ContactsEvent);
				break;
				case ContactsEvent.GET_PLEDGES :
					getPledges(event as ContactsEvent);
				break;
				case ContactsEvent.GET_MATCHES :
					getMatches(event as ContactsEvent);
				break;
				case ContactsEvent.GET_MAXOUT :
					getMaxOut(event as ContactsEvent);
				break;
			}
		}

		/**
		 * Upsert the Record
		 */		
		private function upsertContactRecord(event:ContactsEvent):void
		{
			if(_model.debug) Logger.info('Upsert contact Success', ObjectUtil.toString(event.recordVO));

			var handlers:IResponder = new mx.rpc.Responder(onResult_upsertContactRecord, onFault_upsertContactRecord);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);

			_model.dataLoading = true;
			_presentationModel.formProcessing = true;

			// Save the index of the current list to display the same record after reloading the list
			_presentationModel.searchListLastIndex = _presentationModel.searchListSelectedIndex;

			delegate.upsertContact( event.recordVO.params );
		}
				
		private function onResult_upsertContactRecord(event:ResultEvent):void 
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
						_presentationModel.viewState = 'showSearch';
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
		
		public function onFault_upsertContactRecord(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('upsertRecord Fail', ObjectUtil.toString(event.fault));
			
			_presentationModel.formProcessing = false;			
			_model.errorVO = new ErrorVO( 'There was a problem processing this record!<br><br>' + event.fault.faultString, 'errorBox', true );
		}


		/**
		 * Get all the shared users for the contact in question
		 */
		private function getSharedUsers(event:ContactsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getSharedUsers, onFault_getSharedUsers);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);

			if(_model.debug) Logger.info(_moduleName + ' getSharedUsers Call', ObjectUtil.toString(event.recordsVO));

			_model.dataLoading = true;

			delegate.getRecords(event.recordsVO );
		}
		
		private function onResults_getSharedUsers(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Shared Contacts Success', ObjectUtil.toString(data.result));

			// assign some variables
			var sharedUsers:ArrayCollection = new ArrayCollection()
			for each(var item:Object in data.result.contacts_sharing)
			{
				sharedUsers.addItem(item);
			}

			_contactsModel.sharedUsers = sharedUsers;
			_contactsModel.sharedTabLoading = false;

			// hide the data loading graphic
			_model.dataLoading = false;
		}
			
		private function onFault_getSharedUsers(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Loading Shared Contacts Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;	

			_model.errorVO = new ErrorVO( 
				'There was a problem loading shared users from this contact:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


		/**
		 * Get all the pledges for the contact in question
		 */
		private function getPledges(event:ContactsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getPledges, onFault_getPledges);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);

			_model.dataLoading = true;

			delegate.getRecords(event.recordsVO);
		}

		private function onResults_getPledges(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Contact\'s Pledges Success', ObjectUtil.toString(data.result));

			// assign some variables
			var pledges:ArrayCollection = new ArrayCollection()
			for each(var item:Object in data.result.pledges)
			{
				var contributions:ArrayCollection = new ArrayCollection();
				if(item.transactions[1])
				{
					for each(var transaction:Object in item.transactions)
					{
						transaction.type = "Credit Card";
						contributions.addItem(transaction);
					}
				}
				if(item.checks[1])
				{
					for each(var check:Object in item.checks)
					{
						if(check.entry_date != "0")
						{
							check.type = "Check";
							contributions.addItem(check);
						}
					}
				}
				if(item.paypal_transactions[1])
				{
					for each(var paypal:Object in item.paypal_transactions)
					{
						paypal.type = "PayPal";
						contributions.addItem(paypal);
					}
				}
				if(contributions.length > 0)
					item.contributions = contributions;

				pledges.addItem(item);
			}

			_contactsModel.pledges = pledges;

			// hide the data loading graphic
			_model.dataLoading = false;
			
			_contactsModel.pledgesTabLoading = false;
		}
			
		private function onFault_getPledges(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Loading Contact\'sPledges Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem loading pledges from this contact:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


		/**
		 * Get all the shared users for the contact in question
		 */
		private function getMatches( event:ContactsEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getMatches, onFault_getMatches);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);

			if(_model.debug) Logger.info(_moduleName + ' getMatches Call', ObjectUtil.toString(event.recordsVO));

			_model.dataLoading = true;

			delegate.getRecords( event.recordsVO );
		}
		
		private function onResults_getMatches(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Success Matched Contacts', ObjectUtil.toString(data.result));

			// assign some variables
			var matches:ArrayCollection = new ArrayCollection()
			for each(var item:Object in data.result.contacts)
				matches.addItem(item);

			_contactsModel.matches = matches;
			_contactsModel.matchTabLoading = false;

			// hide the data loading graphic
			_model.dataLoading = false;
		}
			
		private function onFault_getMatches(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Fault Matched Contacts', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;	

			_model.errorVO = new ErrorVO( 
				'There was a problem loading the matches for this contact:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


		/**
		 * Get all the shared users for the contact in question
		 */
		private function getMaxOut( event:ContactsEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getMaxOut, onFault_getMaxOut);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);

			if(_model.debug) Logger.info(_moduleName + ' getMaxOut Call', ObjectUtil.toString(event.recordsVO));

			_model.dataLoading = true;

			delegate.listMaxOut( event.params.matchID );
		}
		
		private function onResults_getMaxOut(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Success getMaxOut', ObjectUtil.toString(data.result));

			_contactsModel.maxOut = data.result;
			_model.dataLoading = false;
			_contactsModel.maxOutTabEnabled = true;
		}
			
		private function onFault_getMaxOut(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Fault getMaxOut Contacts', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			_model.dataLoading = false;	
			_contactsModel.maxOutTabEnabled = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem loading the maxout details for this contact:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}
		
		
	}
}