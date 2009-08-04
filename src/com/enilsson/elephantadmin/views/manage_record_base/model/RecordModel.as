package com.enilsson.elephantadmin.views.manage_record_base.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephantadmin.events.modules.RecordModuleEvent;
	import com.enilsson.elephantadmin.interfaces.IRecordModel;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	import com.enilsson.elephantadmin.vo.SearchVO;
	import com.enilsson.elephantadmin.vo.SessionVO;
	import com.enilsson.elephantadmin.vo.SidVO;
	import com.enilsson.elephantadmin.vo.StruktorLayoutVO;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	[Bindable]
	public class RecordModel implements IRecordModel
	{
		protected var mainModel:ModelLocator;
		
		public function RecordModel( parentModel : ModelLocator = null )
		{
			mainModel = parentModel;
		}

		/**
		 * Some model variables
		 */
		public var table:String;
		public var eSQL:String;
		public var layout:StruktorLayoutVO;
		public var formProcessing:Boolean;
		public var addingNewRecord:Boolean;
		public var refreshingRecords:Boolean;

		/**
		 * Read-only variables that can be only set in classes extending this class
		 */
		public function get allowAddNewRecord():Boolean
		{
			return _allowAddNewRecord;
		}
		protected var _allowAddNewRecord:Boolean = false; // Show "Add Record" button

		public function get addNewRecordLabel():String
		{
			return _addNewRecordLabel;
		}
		protected var _addNewRecordLabel:String = "ADD RECORD"; // Tge Label for "Add Record" Button

		public function get excludedFields():Array
		{
			return _excludedFields;
		}
		protected var _excludedFields:Array = [];
		protected var whereFilterObject:Object;

		/**
		 * Set the configuration for the Record Module
		 */	
		public var config:RecordModuleConfiguration;
		public function configure ( value:RecordModuleConfiguration ):void
		{
			// set some variables
			config 	= value;
			table 	= value.table;
			eSQL 	= value.eSQL == null ? value.table : value.eSQL;
			layout 	= EAModelLocator(mainModel).struktorLayout[table];
			fields 	= layout.fields as Object;
			
			var sid:SidVO = EAModelLocator(mainModel).sid

			if(sid)
			{
				if(sid.table_name == table)
				{
					selectedRecord 		= sid.data;
					viewState 			= 'showOptions';
					searchListLastIndex = -1;
					EAModelLocator(mainModel).sid = null;
				}
			}
			
			BindingUtils.bindSetter(sidChangeWatcher, EAModelLocator(mainModel), 'sidChange');

			// clear the search list
			clearSearch();
		}

		public function checkSID():void
		{
			var sid:SidVO = EAModelLocator(mainModel).sid
			
			if ( debug ) Logger.info('Check Sid', sid.table_name );

			if(sid)
			{
				if(sid.table_name == table)
				{
					selectedRecord 		= sid.data;
					viewState 			= 'showOptions';
					searchListLastIndex = -1;
					EAModelLocator(mainModel).sid = null;
					
					getRecordDetails();
				}
			}
		}

		/**
		 * Change watcher for the Sid, so SidEvents within the same module can happen
		 */
		private function sidChangeWatcher ( value:Boolean ):void
		{
			if ( !value ) return;

			var sid:SidVO = EAModelLocator(mainModel).sid; 	
			
			if ( debug ) Logger.info('SidChangeWatcher', ObjectUtil.toString(sid.data) );		

			if ( !sid ) return;
			if ( EAModelLocator(mainModel).mainViewState != EAModelLocator(mainModel).tableModuleMapping[sid.table_name] ) 
			{
				checkSID();
				return;
			}

			if( debug ) Logger.info('SidChangeWatcher - assign record' );
			
			selectedRecord = sid.data;
			searchListLastIndex = -1;
			EAModelLocator(mainModel).sid = null;
			
			getRecordDetails();
		}
		
		/**
		 * Build an associative array of layout fields, with the fieldname as the key
		 */
		private var _fields:Object;
		public function set fields ( value:Object ):void
		{
			_fields = {};
			
			for each ( var item:Object in value )
				_fields[item.fieldname] = item;
		}
		public function get fields ():Object
		{
			return _fields;
		}

		/**
		 * Manage the currentState of the ManageRecord component
		 */
		public function get viewState ( ):String
		{
			return _viewState;
		}
		private var _viewState:String = 'showSearch';
		public function set viewState ( value:String ):void
		{
			_viewState = value;
			
			if(_viewState == 'showOptions' && !addingNewRecord)
				getRecordDetails();
		}


		/**
		 * List the form variables from the panel struktor form
		 */
		public function get formVariables ():Object
		{
			return _formVariables;
		}
		public function set formVariables ( value:Object ):void
		{
			_formVariables = value;
		}
		private var _formVariables:Object;


		/**
		 * Set and get the record listing for the module
		 */
		public function get records ():ArrayCollection
		{
			return _records;
		}
		private var _records:ArrayCollection = new ArrayCollection();
		public function set records ( value:ArrayCollection ):void
		{
			_records = value;
			
			recordsText = 'true';
		}


		/**
		 * Set and get the selected record for the module
		 */
		[Bindable(event="selectedRecordChange")]
		public function get selectedRecord ():Object
		{
			return _selectedRecord;
		}
		private var _selectedRecord:Object = {};
		public function set selectedRecord ( value:Object ):void
		{
			_selectedRecord = value;
			recordID = value[layout.primary_key];
			showRecordDetails = false;
			setDeleteBtn( value );
			
			if ( debug ) Logger.info( 'Set Selected Record', recordID );

			dispatchEvent( new Event('selectedRecordChange') );
		}


		/**
		 * Set and get the selected record for the module
		 */
		public function get recordID ():int
		{
			return _recordID;
		}		
		private var _recordID:int;
		public function set recordID ( value:int ):void
		{
			_recordID = value;
		}
		
		/**
		 * Variable flag for showing/enabling the deleteBtn and a function stub for overriding if necessary.
		 * Default is to hide the deleteBtn
		 */
		public var showDeleteBtn:Boolean = false;
		public var enableDeleteBtn:Boolean = false;
		protected function setDeleteBtn ( value:Object ):void {  }		
		

		/**
		 * Set and get the audit trail for the selected record
		 */
		public function get auditTrail ():ArrayCollection
		{
			return this._auditTrail;
		}
		private var _auditTrail:ArrayCollection;
		public function set auditTrail ( value:ArrayCollection ):void
		{
			this._auditTrail = value;
			
			// create an reference to match the create action
			var obj:Object = {
				'action' : 'CREATE',
				'fname' : selectedRecord.created_by,
				'lname' : '',
				'timestamp' : selectedRecord.created_on
				}
			
			this._auditTrail.addItem( obj );
		}
		public var auditTrailTabLoading:Boolean;

		
		/**
		 * Set and get the selected record for the module
		 */
		public function get deletedRecord ():Object
		{
			return _deletedRecord;
		}
		private var _deletedRecord:Object;
		public function set deletedRecord ( value:Object ):void
		{
			_deletedRecord = value;
		}	
		
		public function getDeletedRecord ( deletedID:int ):void
		{
			new RecordModuleEvent(
				RecordModuleEvent.GET_DELETED_RECORD,
				this,
				{ 'table' : table, 'deletedID' : deletedID }
			).dispatch();
		}	

		/**
		 * Pass through for some Global variables from the main model
		 */
		public function get serverVariables ():Object
		{
			return EAModelLocator(mainModel).serverVariables;
		}

		public function get baseURL ():Object
		{
			return EAModelLocator(mainModel).baseURL;
		}

		public function get appName ():Object
		{
			return EAModelLocator(mainModel).appName;
		}

		public function get session ():SessionVO
		{
			return EAModelLocator(mainModel).session;
		}

		public function get itemsPerPage() : Number 
		{
			return EAModelLocator(mainModel).itemsPerPage;
		}
		public function set itemsPerPage( value:Number ):void 
		{
			EAModelLocator(mainModel).itemsPerPage = value;
		}

		public function get debug():Boolean 
		{
			return EAModelLocator(mainModel).debug;	
		}		
		
		public function get dataLoading():Boolean 
		{
			return EAModelLocator(mainModel).dataLoading;	
		}				

		
		/**
		 * Get and set the text at the top of the module listing
		 */
		public function get recordsText():String
		{
			return _recordsText;
		}
		private var _recordsText:String;
		public function set recordsText ( value:String ):void
		{
			var plural:String = searchListItemsTotal > 1 ? 's' : '';
			
			if(searchListItemsTotal < itemsPerPage)
				_recordsText = '<b>' + searchListItemsTotal + '</b> record' + plural;
			else
			{
				var startIndex:String = (searchListCurrPage + 1).toString();
				var toIndex:int =  searchListCurrPage + itemsPerPage;
				var toIndexString:String = toIndex < searchListItemsTotal ? toIndex.toString() : searchListItemsTotal.toString();			
				
				_recordsText = '<b>' + startIndex + '</b>';
				_recordsText += '-<b>' + toIndexString + '</b>';
				_recordsText += ' of <b>' + searchListItemsTotal + '</b> record' + plural;
			}
		}


		/**
		 * Set the group name of the record
		 */
		public function get groupName():String
		{
			var groups:Array = EAModelLocator(mainModel).allGroupsList;
			
			for each ( var group:Object in groups )
				if( Number(group.value) == Number(selectedRecord.mod_group_id) ) 
					return group.label;
				
			return '';
		}

		/**
		 * Method stub for passing module specific actions to the form complete event
		 */
		public function formBuildComplete( event:Event ):void {  }
		

		/**
		 * Method stub for passing module specific actions to the form valid event
		 */
		public function validChanged( event:Event ):void 
		{ 
			formValid = event.currentTarget.isValid;	
		}		
		
		
		/**
		 * Get and set a valid boolean flag for the form
		 */
		private var _formValid:Boolean;
		public function set formValid ( value:Boolean ):void
		{
			_formValid = value;
		}
		public function get formValid ():Boolean
		{
			return _formValid;
		}

		/**
		 * Some variables for the record panel
		 */
		public var showRecordDetails:Boolean = false;
		
		
		/**
		 * Some variables for the search list
		 */
		public var searchListSelectedIndex:int;
		public var searchListLastIndex:int = -1;
		public var searchListCurrPage:int;
		public var searchListItemsTotal:int;
		public var showClearSearchBtn:Boolean = false;
		public var lastQuery:RecordModuleEvent;

		/**
		 * Defines what happens when the module list is clicked
		 */
		public function searchListSelectedIndexChange ( event:Event ):void
		{
			this.searchListSelectedIndex = event.currentTarget.selectedIndex;
			this.selectedRecord = event.currentTarget.selectedItem;
		}

		/**
		 *	Method runs when selected record is changed
		 *	Retrieves details of the selected record from the server
		 */
		protected function getRecordDetails(): void
		{
			getAuditTrail();
		}
		
		/**
		 * Method runs when a record is updated outside of an upsert
		 */
		public function onRecordUpdate():void {  };

		public function addNewRecord(): void
		{
			addingNewRecord = true;
			viewState = 'showOptions';
			selectedRecord = new Object();
			auditTrail = new ArrayCollection();
		}

		/**
		 * Action to clear any search elements and return to the default search
		 */
		private var whereObj:Object = {};
		public function clearSearch():void
		{
			showClearSearchBtn = false;
			searchListCurrPage = 0;

			whereObj =  {};

			if(whereFilterObject)
			{
				whereObj['statement'] = '(1)';
				whereObj[1] = whereFilterObject;
			}

			var r:RecordModuleEvent = new RecordModuleEvent( 
				RecordModuleEvent.GET_RECORDS, 
				this,
				new RecordsVO( 
					eSQL, 
					whereObj, 
					table + '.' + config.browseField + ' ASC', 
					searchListCurrPage, 
					itemsPerPage, 
					'P' 
				) 
			);
			
			lastQuery = r;
			r.dispatch();
		}
		
		
		/**
		 * Action to define a search via one of the index letters
		 */
		public function indexSearch( searchLetter:String ):void
		{
			showClearSearchBtn = true;

			whereObj =  {};
			if(whereFilterObject)
			{
				whereObj['statement'] = '(1) AND (2)';
				whereObj[1] = whereFilterObject;
				whereObj[2] = { 
					'what' : table + '.' + config.browseField,
					'val' : searchLetter + "%",
					'op' : 'LIKE'
				};
			}
			else
			{
				whereObj['statement'] = '(1)';
				whereObj[1] = { 
					'what' : table + '.' + config.browseField,
					'val' : searchLetter + "%",
					'op' : 'LIKE'
				};
			}

			var r:RecordModuleEvent = new RecordModuleEvent(
				RecordModuleEvent.GET_RECORDS,
				this,
				new RecordsVO( 
					eSQL, 
					whereObj, 
					table + '.' + config.browseField + " ASC", 
					0, 
					itemsPerPage, 
					'P' 
				)
			)
			lastQuery = r;
			r.dispatch();
		}
		
		
		/**
		 * Action to define sorting records in the grid listing
		 */
		public function sortRecords( sortOrder:String ):void
		{						
			var r:RecordModuleEvent = new RecordModuleEvent(
				RecordModuleEvent.GET_RECORDS,
				this,
				new RecordsVO( 
					eSQL, 
					whereObj, 
					sortOrder, 
					searchListCurrPage, 
					itemsPerPage, 
					'P' 
				)
			)
			lastQuery = r;
			r.dispatch();
		}
		
		/**
		 * Action to define a search from the search box, uses Sphinx
		 */
		public function searchRecords( searchTerm:String, searchOption:Object ):void
		{
			showClearSearchBtn = true;
			var s:RecordModuleEvent;
			
			if( searchOption.data == 0 )
			{				
				s = new RecordModuleEvent(
						RecordModuleEvent.SEARCH_RECORDS,
						this,
						new SearchVO( table, searchTerm + "*", null, 0, itemsPerPage )
					);
				lastQuery = s;
				s.dispatch();
			}
			else
			{
				var searchField:String = searchOption.data;

				whereObj =  {};
				if(whereFilterObject)
				{
					whereObj['statement'] = '(1) AND (2)';
					whereObj[1] = whereFilterObject;
					whereObj[2] = { 
						'what' : searchField,
						'val' : searchTerm + "%",
						'op' : 'LIKE'
					};
				}
				else
				{
					whereObj['statement'] = '(1)';
					whereObj[1] = {
						'what' : searchField,
						'val' : searchTerm + "%",
						'op' : 'LIKE'
					};
				}
				s = new RecordModuleEvent (
					RecordModuleEvent.GET_RECORDS,
					this,
					new RecordsVO ( 
						eSQL, 
						whereObj, 
						table + '.' + config.browseField + ' ASC', 
						searchListCurrPage, 
						itemsPerPage, 
						'P' 
					)
				);
				lastQuery = s;
				s.dispatch();
			}
		}


		/**
		 * Action to show a new page of the module listing
		 */
		public function newPage( selectedPage:int ):void
		{
			searchListCurrPage = selectedPage * itemsPerPage;
			
			switch(lastQuery.type)
			{
				case RecordModuleEvent.GET_RECORDS:
					RecordsVO(lastQuery.recordsVO).iFrom = searchListCurrPage;
					lastQuery.dispatch();
 				break;
				
				case RecordModuleEvent.SEARCH_RECORDS:
					SearchVO(lastQuery.searchVO).iFrom = searchListCurrPage;
					lastQuery.dispatch();
				break;
			}
		}


		/**
		 * Upsert the record data to Struktor
		 */
		public function upsertRecord( formVariables:Object ):void
		{			
			this.formVariables = ObjectUtil.copy( formVariables );

			// Upsert if formVariables was changed
			if(this.formVariables != selectedRecord)
			{
				new RecordModuleEvent( 
					RecordModuleEvent.UPSERT,
					this,
					new RecordVO ( table, 0, this.formVariables )
				).dispatch();
			}
		}


		/**
		 * Delete a record
		 */
		public function deleteRecord( ):void
		{			
			new RecordModuleEvent( 
				RecordModuleEvent.DELETE,
				this,
				new RecordVO ( table, selectedRecord[layout.primary_key], null )
			).dispatch();
		}


		/**
		 * Retrieve the audit trail for the selected record
		 */
		private function getAuditTrail ():void
		{
			auditTrailTabLoading = true;
			auditTrail = new ArrayCollection();

			new RecordModuleEvent ( 
				RecordModuleEvent.GET_AUDIT_TRAIL, 
				this,
				{ 'table' : this.table, 'recordID' : this.recordID } 
			).dispatch();
		}
	}
}