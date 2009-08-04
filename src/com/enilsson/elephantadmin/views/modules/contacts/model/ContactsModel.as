package com.enilsson.elephantadmin.views.modules.contacts.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephantadmin.events.modules.ContactsEvent;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	[Bindable]
	public class ContactsModel extends RecordModel
	{
		public var sharedUsers:ArrayCollection;
		public var sharedTabLoading:Boolean;
		
		public var pledges:ArrayCollection;
		public var pledgesTabLoading:Boolean;
		
		public var matches:ArrayCollection;
		public var matchTabLoading:Boolean;
		

		public function ContactsModel(parentModel:ModelLocator=null)
		{
			super(parentModel);
		}

		/**
		 * Set the delete btn for this module
		 */
		override protected function setDeleteBtn( value:Object ):void
		{
			showDeleteBtn = true;
			enableDeleteBtn = value.p == 0;
		}

		/**
		 * Handle the actions when the record details are fetched
		 */
		override protected function getRecordDetails():void
		{
			super.getRecordDetails();
			
			getSharedUsers();
			getPledges();
			getMatches(); 
			getMaxOut(); 
		}
		
		/**
		 * Get list of all fundraisers that share this contact
		 */
		private function getSharedUsers():void
		{
			sharedTabLoading = true;
			sharedUsers = new ArrayCollection();
			var where:Object = {'statement':'(1)','1':{ 
					'what' : 'contacts_sharing.created_by_id',
					'val' : this.selectedRecord.created_by_id,
					'op' : '='
				}};

			var recordsVO:RecordsVO = new RecordsVO(
				'contacts_sharing(share_id<fname:lname:_fid>)',
				where,
				null,
				0,
				1000,
				'P'
				);
			new ContactsEvent(ContactsEvent.GET_SHARED_USERS, this, recordsVO).dispatch();
		}
		
		/**
		 * Get list of all pledge made by this contact
		 */
		private function getPledges():void
		{
			pledgesTabLoading = true;
			pledges = new ArrayCollection();
			
			var eSQL:String = 'pledges(';
			eSQL += 'event_id,';
			eSQL += 'transactions<amount:full_name:card_number:card_number_type:created_on:transactionid:address:city:state:zip>,';
			eSQL += 'checks<entry_date:amount:batch_code:batch_id>,';
			eSQL += 'paypal_transactions<amount:created_on:transactionid>';
			eSQL += ')';
			
			var where:Object = {'statement':'(1)','1':{ 
					'what' : 'pledges.contact_id',
					'val' : this.recordID,
					'op' : '='
				}};

			var recordsVO:RecordsVO = new RecordsVO( eSQL, where );

			new ContactsEvent(ContactsEvent.GET_PLEDGES, this, recordsVO).dispatch();
		}
		
		/**
		 * Get list of all matched contacts records to this one
		 */
		private function getMatches():void
		{
			matches = new ArrayCollection();

			if( debug ) Logger.info('Contact Record', ObjectUtil.toString (this.selectedRecord) );
			if ( !selectedRecord.match_id ) return;			
			
			matchTabLoading = true;
			var where:Object = {
				'statement':'(1 AND 2)',
				'1' :
					{ 
						'what' : 'contacts.match_id',
						'val' : selectedRecord.match_id,
						'op' : '='
					},
				'2' :
					{ 
						'what' : 'contacts.id',
						'val' : recordID,
						'op' : '!='
					}				
			};

			var recordsVO:RecordsVO = new RecordsVO(
				'contacts<ALL>(created_by_id<fname:lname:_fid>)',
				where
			);

			new ContactsEvent(ContactsEvent.GET_MATCHES, this, recordsVO).dispatch();
		}
		
		/**
		 * Get a list of all the maxout records corresponding to this contact
		 */
		public var maxOutTabEnabled:Boolean = false;
		public var maxOut:Object;
		private function getMaxOut():void
		{
			if ( selectedRecord.match_id > 0 )
			{
				maxOutTabEnabled = false;
				new ContactsEvent( ContactsEvent.GET_MAXOUT, this, { matchID: selectedRecord.match_id } ).dispatch();
			}
			else
				maxOutTabEnabled = false;
		}

	}
}