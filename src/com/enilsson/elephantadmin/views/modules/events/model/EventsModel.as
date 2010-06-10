package com.enilsson.elephantadmin.views.modules.events.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephantadmin.events.modules.EventsEvent;
	import com.enilsson.elephantadmin.views.common.ErrorMsgBox;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	import com.enilsson.elephantadmin.vo.SearchVO;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.events.DataGridEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;

	[Bindable]
	public class EventsModel extends RecordModel
	{
		public function EventsModel(parentModel:ModelLocator=null)
		{
			super(parentModel);
			
			//Allow the module to add new records
			this._allowAddNewRecord = true;
			_addNewRecordLabel = 'ADD EVENT';
		}
		
		public var pledgesTabLoading:Boolean;
		
		public var pledges:ArrayCollection;
		
		public var tempSourceCodes:ArrayCollection;
		
		/**
		 * Capture the get record event and add the Pledge specific elements to it
		 */
		override protected function getRecordDetails():void
		{
			super.getRecordDetails();
			
			getHostCommittee();
			getPledges();
		}

		/**
		 * Set the delete button based on the events criteria
		 */
		override protected function setDeleteBtn( value:Object ):void
		{
			showDeleteBtn = true;
			enableDeleteBtn = value.c == 0;
		}


		/**
		 * Handle the action list clicks
		 */
		private function addClickHandler(event:Event):void
		{
			this.selectedRecord = {};
		}

		private function exportClickHandler(event:Event):void
		{
			var params:Object = {};
		//	params.limit = eventsList.itemsTotal;
			
			new EventsEvent( 
					EventsEvent.EXPORT,
					this,
					new RecordVO (
						'events',
						0,
						params
					)
			).dispatch();
		}
		
		/**
		 * sets the access rights for an event
		 */ 
		public function set eventAccessRights( value : Object ) : void
		{			
			_eventAccessRights = defaultAccessRights;
			
			if(value)
			{
				if(value.mod_e_read !== undefined) _eventAccessRights.mod_e_read = value.mod_e_read;
				if(value.mod_g_read !== undefined) _eventAccessRights.mod_g_read = value.mod_g_read;
				if(value.mod_g_write !== undefined) _eventAccessRights.mod_g_write = value.mod_g_write;
				if(value.mod_group_id !== undefined) _eventAccessRights.mod_group_id = value.mod_group_id;
			}
			
			_eventAccessRightsChanged = true;
		}
		private var _eventAccessRights : Object;
		private var _eventAccessRightsChanged : Boolean;			
		
		/**
		 * provides a set of default access rights for an event
		 */
		private function get defaultAccessRights() : Object
		{
			return { 
				mod_e_read 		: 1,
				mod_g_read 		: 0,
				mod_g_write		: 0,
				mod_group_id	: 0
			};
		}
		
		
		/**
		 * Override the upsert method to include the access parameters
		 */
		override public function upsertRecord(formVariables:Object):void
		{
			this.formVariables = formVariables;

			// Upsert if formVariables was changed
			if(this.formVariables != selectedRecord || _eventAccessRightsChanged )
			{
				_eventAccessRightsChanged = false;
				
				if(!_eventAccessRights) {
					_eventAccessRights = defaultAccessRights;
				}
					
				for(var prop : String in _eventAccessRights) {
					formVariables[prop] = _eventAccessRights[prop];
				}
					
				_eventAccessRights = null;						
				

				new EventsEvent( EventsEvent.UPSERT_EVENT, this, formVariables ).dispatch();
			}
		}
		
		/**
		 * Get and save the list of host committee members
		 */
		public var hostCommittee:ArrayCollection;
		public function getHostCommittee():void
		{
			var where:Object = {};
			where['statement'] = '(1)';
			where[1] = { 
				'what' 	: 'events_host_committee.event_id',
				'val' 	: recordID,
				'op' 	: '='
			};
			
			var r:RecordsVO = new RecordsVO(
				'events_host_committee<ALL>(user_id<fname:lname:_fid>)',
				where,
				null,
				0,
				10000
			);
			
			new EventsEvent( EventsEvent.GET_HOSTS, this, r ).dispatch();
		}

		public function getPledges():void
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
					'what' : 'pledges.event_id',
					'val' : this.recordID,
					'op' : '='
				}};

			var recordsVO:RecordsVO = new RecordsVO( eSQL, where );
			
			new EventsEvent( EventsEvent.GET_PLEDGES, this, recordsVO ).dispatch();
		}
		
		public function getTempSourceCodes():void {
			new EventsEvent( EventsEvent.GET_TEMP_SOURCE_CODES, this ).dispatch();
		}


		/**
		 * Get and save a list of searched fundraisers for the host committee
		 */
		public var hostsList:ArrayCollection;
		public function hostsSearchStart( event:Event ):void
		{
			var s:SearchVO = new SearchVO ( 'tr_users_details', event.currentTarget.searchTerm, null, 0, 200 );
			
			new EventsEvent (
				EventsEvent.LOOKUP_SEARCH,
				this,
				s
			).dispatch();
		}
		
		public var hostCommitteeProcessing:Boolean = false;
		public var newHost:Object;
		
		/**
		 * Add a fundraiser as an event host, both as a Struktor call and to the hostCommittee array collection
		 */
		public function addEventHost( value:Object ):void
		{			
			// if there is no host selected or no host committee then do nothing
			if( ! value 
				|| value.user_id === undefined 
				|| ! value.user_id 
				|| ! hostCommittee ) 
				return;
			
			// if the host is already in the committee then do nothing
			for each ( var item:Object in hostCommittee)
				if( item.user_id.user_id == value.user_id) {
					showError("This user is already listed as a committee member.");
					return;
				}
			
			// set the parameters for the upsert
			var p:Object = { 
				'event_id' : recordID, 
				'user_id' : Number(value.user_id), 
				'fundraising_goal' : 0,
				'mod_e_read' : 1
			};
			var r:RecordVO = new RecordVO( 'events_host_committee', 0, p );

			// do the upsert
 			new EventsEvent (
				EventsEvent.UPSERT_HOST_RECORD,
				this,
				r
			).dispatch();
			
			// save the params to be inserted into the committee list on success
 			newHost = ObjectUtil.copy(p);
			newHost['user_id'] = value;
 		}
		
		
		/**
		 * Update an event host's details (fundraising goal)
		 */
		public function updateEventHost ( event:DataGridEvent ):void
		{
			var newGoal:int = Number(TextInput(event.currentTarget.itemEditorInstance).text);
			var oldGoal:int = event.currentTarget.dataProvider[event.rowIndex]['fundraising_goal'];
			
			if( newGoal == oldGoal ) return;
			
			event.currentTarget.dataProvider[event.rowIndex]['fundraising_goal'] = newGoal;
			var value:Object = event.currentTarget.dataProvider[event.rowIndex];
			
			var params:Object = { 
				'id' : Number(value.id),
				'event_id' : Number(value.event_id), 
				'user_id' : Number(value.user_id.user_id), 
				'fundraising_goal' : Number(value.fundraising_goal)
			};
			
			var r:RecordVO = new RecordVO( 'events_host_committee', 0, params );
			
			new EventsEvent (
				EventsEvent.UPSERT_HOST_RECORD,
				this,
				r
			).dispatch();			
		}
		
		
		/**
		 * Delete an existing event host record
		 */
		public var deleteHostID:int;
		public function deleteEventHost ( hostID:int ):void
		{
			deleteHostID = hostID;
			var r:RecordVO = new RecordVO( 'events_host_committee', hostID );
			
 			new EventsEvent (
				EventsEvent.DELETE_HOST_RECORD,
				this,
				r
			).dispatch();
 		}
 		
 		
 		private function showError( message : String ) : void
 		{
 			var emb : ErrorMsgBox = new ErrorMsgBox();
 			emb.initialize();
 			emb.params = new ErrorVO( message, "errorBox", true ); 
 			PopUpManager.addPopUp( emb, Application.application as DisplayObject, false ); 			
 			PopUpManager.centerPopUp( emb );
 		}
	}
}