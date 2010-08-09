package com.enilsson.elephanttrakker.views.modules.pledge_workspace.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.models.Icons;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.events.PWEvent;
	import com.enilsson.elephanttrakker.vo.AppOptionsVO;
	import com.enilsson.elephanttrakker.vo.PledgeVO;
	import com.enilsson.elephanttrakker.vo.SessionVO;
	import com.enilsson.elephanttrakker.vo.StruktorLayoutVO;
	import com.enilsson.elephanttrakker.vo.TransactionVO;
	import com.enilsson.utils.eNilssonUtils;
	import com.enilsson.vo.ErrorVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	[Bindable]
	public class PledgeWorkspaceModel extends EventDispatcher
	{
		/**
		 * List of static variables defining the four types of form action available
		 */
		public static const ADD_NEW:String 			= 'pledgeworkspace_addnew';
		public static const ADD_EXISTING:String 	= 'pledgeworkspace_addexisting';
		public static const ADD_SHARED:String 		= 'pledgeworkspace_addshared';
		public static const EDIT:String 			= 'pledgeworkspace_edit';
		
		
		public static const CC_VIEW 			: int = 0;
		public static const CHECK_VIEW			: int = 1;
		public static const NO_CONTRIB_VIEW		: int = 2;
		public static const LIST_CONTRIBS_VIEW	: int = 3;
		
		public static const CONTACT_FORM_VIEW	: int = 0;
		public static const PLEDGE_FORM_VIEW	: int = 1;
		public static const AGREEMENT_FORM_VIEW	: int = 2;
		
		public static const CC_DETAILS_VIEW			: int = 0;
		public static const BILLING_DETAILS_VIEW	: int = 1;
		
		
		/**
		 * Variable to register when a saved record is being restored
		 */
		public static const RESTORE_SAVED:String	= 'pledgeworkspace_restoresaved';
		
		/**
		 * The model variables
		 */
		private var model:ETModelLocator;

		/**
		 * Constructor, deals with instanciating the parentModels
		 */
		public function PledgeWorkspaceModel( parentModel : ModelLocator = null )
		{
			// add the parent model as a variable to the class
			model = parentModel as ETModelLocator;
			
			
			if(model) {
				// listen for a changes to the parent model
				BindingUtils.bindSetter( workspaceChangeHandler, model, 'pledgeWorkspace' );
				BindingUtils.bindProperty(this, 'session', model, 'session' );
				BindingUtils.bindProperty(this, 'pledgeLayout', model, ['struktorLayout','pledges'] );
				BindingUtils.bindProperty(this, 'transactionLayout', model, ['struktorLayout', 'transactions'] );
				BindingUtils.bindProperty(this, 'checkLayout', model, ['struktorLayout', 'checks'] );
				BindingUtils.bindProperty(this, 'siteLayoutLoaded', model, 'siteLayoutLoaded' );
				BindingUtils.bindProperty(this, 'options', model, 'options' );
				BindingUtils.bindProperty(this, 'icons', model, 'icons' );
				BindingUtils.bindProperty(this, 'debug', model, 'debug' );
				BindingUtils.bindProperty(this, 'mainViewState', model, 'mainViewState' );
				BindingUtils.bindProperty(this, 'successTextCC', model, 'successTextCC' );
				BindingUtils.bindProperty(this, 'successTextCheck', model, 'successTextCheck');
				
			}
			
			if(debug) Logger.info ( 'Instantiate PledgeWorkspaceModel' );
		}

		public var session 				: SessionVO;
		public var pledgeLayout			: StruktorLayoutVO;
		public var transactionLayout	: StruktorLayoutVO;
		public var checkLayout			: StruktorLayoutVO;
		public var siteLayoutLoaded		: Boolean;
		public var options				: AppOptionsVO;
		public var icons				: Icons;
		public var debug				: Boolean;
		public var mainViewState		: int;
		public var successTextCC		: String;
		public var successTextCheck		: String;

		/**
		 * Some global variables for use during form completion
		 */
		 
		public var action:String = ADD_NEW; 		// determine the action of the form	 	
		public var pledgeID:int; 					// if this is an edit
		public var contactID:int; 					// if this is an existing contact
		public var numTabs:int = 2;					// list how many tabs are present on the form
		public var formProcessing:Boolean = false;	// show the process overlay
		public var errorVO:ErrorVO					// VO to handle showing the error message box
		public var showErrorList:Boolean = false;	// show the popup of the error listing
		public var pledgeDups:Array;				// list of found duplicate pledges
		public var showDupBox:Boolean = false;		// show the popup of the duplicates
		public var dupsVStack:int = 0;				// the state of the dups viewstack
		
		public function set transVStack( value : int ) : void { _transVStack = value; }
		public function get transVStack() : int { return _transVStack; }
		private var _transVStack : int = CC_VIEW;
		
		public var ccVStack:int = 0;				// the state of the credit card viewstack
		public var savedID:Number = 0;				// to record if this is a saved pledge
		public var transactionAttempts:int = 0;		// track how many attempts the user has at one record
		public var setSubmitFocus:Boolean = false;	// set the submit button focus
		public var clearPaymentForms:Boolean = false;// clear the CC or Check form when needed
		
		
		/**
		 * Variable holding the entered pledge amount
		 */
		public function set pledgeAmount ( value:String ):void { _pledgeAmount = value; }
		private var _pledgeAmount:String
		public function get pledgeAmount ( ):String { return _pledgeAmount; }

		/**
		 * Variable holding the entered contact email
		 */
		public function set contactEmail ( value:String ):void { _contactEmail = value; }
		private var _contactEmail:String
		public function get contactEmail ( ):String { return _contactEmail; }

		/**
		 * Show the completed pledge overlay
		 */
		public function set completedPledge ( value:Boolean ):void { _completedPledge = value; }
		private var _completedPledge:Boolean
		public function get completedPledge ( ):Boolean {  return _completedPledge; }
		
		
		/**
		 * Variables to handled the movement of the tabs
		 */
		public var vindex:int = CONTACT_FORM_VIEW;
		public var prevVIndex:Number = CONTACT_FORM_VIEW;
		public var tabBackward:Boolean = false;
				

		/**
		 * Handle the initialisation routine, incorporating the prepopulation of data
		 */
		public function init():void
		{
			if(debug) Logger.info ( 'PledgeWorkspaceModel Init', completedPledge );
			
			vindex = CONTACT_FORM_VIEW;
			completedPledge = false;
			
			if ( action == EDIT )
				transVStack = LIST_CONTRIBS_VIEW;
		}
		
		/**
		 * Change handler for the pledge workspace VO
		 */
		private function workspaceChangeHandler ( pwVO:PledgeWorkspaceVO ):void
		{
			// do nothing if empty
			if ( !pwVO ) return;

			if(debug) Logger.info( 'workspaceChangeHandler: Start', pwVO.action );

			// reset everything
			reset(pwVO.action);
			
			var ipd : Object = {};
			// do some specific tasks based on the action
			switch ( pwVO.action )
			{			
				case ADD_NEW :
					if ( pwVO.eventID )
						ipd['event_id'] = pwVO.eventID;
					if ( pwVO.fundraiserID )
						ipd['tr_users_id'] = pwVO.fundraiserID;
					
					initialPledgeData = ipd;
				break;				
				case ADD_EXISTING :
				case ADD_SHARED :
					contactID = pwVO.contactID;	
					
					if ( pwVO.contactData )	
					{		
						initialContactData = pwVO.contactData;
						ipd = pwVO.contactData;
					}
					else
						new PWEvent ( PWEvent.GET_CONTACT, this, { contactID : pwVO.contactID } ).dispatch();
						
					if ( pwVO.eventID )
						ipd['event_id'] = pwVO.eventID;
					if ( pwVO.fundraiserID )
						ipd['tr_users_id'] = pwVO.fundraiserID;
						
					initialPledgeData = ipd;
						
				break;
				case RESTORE_SAVED :
					savedID = pwVO.savedID;
					
					if ( pwVO.contactID > 0 ) 
						contactID = pwVO.contactID;
					
					if ( contactID > 0 )
					{
						if ( pwVO.contactData.created_by_id != session.user_id )
							action = ADD_SHARED;
						else
							action = ADD_EXISTING;						
					} 
					else
						action = ADD_NEW;

					initialContactData = pwVO.contactData;
					initialPledgeData = pwVO.pledgeData;
				break;
				case EDIT :
					pledgeID = pwVO.pledgeID;
					
					new PWEvent ( PWEvent.GET_PLEDGE, this, { pledgeID : pwVO.pledgeID } ).dispatch();
				break;
			}
			
			if(debug) Logger.info ( 'workspaceChangeHandler: Complete', action );
		}

		
		/**
		 * Get and set the initial contact data, and push any billing details if necessary
		 */
		private var _initialContactData:Object;
		[Bindable(event="initialContactDataChanged")]
		public function set initialContactData ( value:Object ):void
		{
			_initialContactData = value;	
			
			if( value.billing_address1 != '' && value.billing_city != '' && value.billing_state != '' )
				initialBillingDetails = value;
				
			dispatchEvent(new Event("initialContactDataChanged"));
		}
		public function get initialContactData ():Object
		{
			return _initialContactData;
		}
		
		/**
		 * Get and set the initial billing details, mapping the contact fields to the transaction names
		 */
		private var _initialBillingDetails:Object;
		public function set initialBillingDetails ( value:Object ):void
		{
			_initialBillingDetails = new Object();
			
			if ( value.hasOwnProperty( 'billing_address1' ) ) _initialBillingDetails['address'] = value.billing_address1;
			if ( value.hasOwnProperty( 'billing_address2' ) ) _initialBillingDetails['address2'] = value.billing_address2;
			if ( value.hasOwnProperty( 'billing_city' ) ) _initialBillingDetails['city'] = value.billing_city;
			if ( value.hasOwnProperty( 'billing_state' ) ) _initialBillingDetails['state'] = value.billing_state;
			if ( value.hasOwnProperty( 'billing_zip' ) ) _initialBillingDetails['zip'] = value.billing_zip;	
		}
		public function get initialBillingDetails ():Object
		{
			return _initialBillingDetails;
		}

		/**
		 * Get and set the initial pledge data
		 */
		private var _initialPledgeData:Object;
		[Bindable(event="initialPledgeDataChanged")]
		public function set initialPledgeData ( value:Object ):void
		{
			_initialPledgeData = value;	
			dispatchEvent(new Event("initialPledgeDataChanged"));
		}
		public function get initialPledgeData ():Object
		{
			return _initialPledgeData;
		}

		/**
		 * Variable to hold all the contributions to a pledge
		 */
		public function get contributions ( ):ArrayCollection { return _contributions; }
		private var _contributions:ArrayCollection;
		public function set contributions ( value:ArrayCollection ):void { _contributions = value; }
		
		/**
		 * Storage of the edited contact data
		 */
		private var _contactData:Object;
		public function set contactData ( value:Object ):void
		{
			_contactData = ObjectUtil.copy( value );
		}
		public function get contactData ():Object
		{
			return _contactData;
		}
		
		/**
		 * Storage of the edited pledge data
		 */
		private var _pledgeData:Object;
		public function set pledgeData ( value:Object ):void
		{
			_pledgeData = ObjectUtil.copy( value );
		}
		public function get pledgeData ():Object
		{
			return _pledgeData;
		}

		/**
		 * Storage of the edited credit card data
		 */
		private var _transactionData:Object;
		public function set transactionData ( value:Object ):void
		{
			_transactionData = ObjectUtil.copy( value );
		}
		public function get transactionData ():Object
		{
			return _transactionData;
		}

		/**
		 * Storage of the edited credit card billing data
		 */
		private var _billingData:Object;
		public function set billingData ( value:Object ):void
		{
			// remove the id as it is never needed
			delete value.id;

			// check to see if there is any data in any of the fields
			var flag:Boolean = true;
			for each ( var item:Object in value )
				if ( String(item) != ''  ) flag = false;
			
			// set the billing data to null if nothing is there
			if(flag) 
			{
				_billingData = null;
				return;
			}	
			
			// copy the object to the billingData variable
			_billingData = ObjectUtil.copy( value );
		}
		public function get billingData ():Object
		{
			return _billingData;
		}
		
		/**
		 * Convenience function to wipe the billing data
		 */
		public function clearBillingData ():void
		{
			ccVStack = PledgeWorkspaceModel.CC_DETAILS_VIEW;
			initialBillingDetails = {};
			billingData = {};
		}

		/**
		 * Storage of the edited check data
		 */
		private var _checkData:Object;
		public function set checkData ( value:Object ):void
		{
			if(value)
				delete value.id;
			_checkData = ObjectUtil.copy( value );
		}
		public function get checkData ():Object
		{
			return _checkData;
		}
		
		public var noContribData : Object;

		
		/**
		 * Variables for the lookup search input fields
		 */
		public var sourceCodeSearch:ArrayCollection;
		public var fidSearch:ArrayCollection;
		public var eventsLabel:String = '';
		public var eventsValue:uint = 0;
		public var tr_users:Object;
		public var tr_usersLabel:String = '';
		public var tr_usersValue:Number = 0;


		/**
		 * List of the fields actually displayed in each form
		 */
		public var contactsFields:Array;
		public var pledgeFields:Array;
		public var billingFields:Array;
		public var ccFields:Array;
		public var checkFields:Array;
		public var noContribFields:Array;


		/**
		 * Variables representing the valid status of each of the tabs
		 */
		public var contactDetailsValid:Boolean = false;
		public var pledgeInfoValid:Boolean = false;
		public var agreementValid:Boolean = false;

		/**
		 * Determine if the entire workspace is valid
		 */
		private var _workspaceValid:Boolean = false;
		public function set workspaceValid ( value:Boolean ):void
		{
			if ( numTabs == 2 )
				_workspaceValid = pledgeInfoValid && contactDetailsValid;
			else
				_workspaceValid = pledgeInfoValid && contactDetailsValid && agreementValid;
		}
		public function get workspaceValid ( ):Boolean
		{
			return _workspaceValid;
		}

		/**
		 * List of the error fields for each form
		 */
		public var contactsErrors	:Array = [];
		public var pledgeErrors		:Array = [];
		public var ccErrors			:Array = [];
		public var checkErrors		:Array = [];
		public var billingErrors	:Array = [];
		public var noContribErrors	:Array = [];

		/**
		 * Flag to initiate a reset on the agreement initials boxes
		 */
		public var resetInitials:Boolean = true;


		/**
		 * Save the current workspace data
		 */
		public function save ():void
		{
			// if you are editing an exist pledge you can't save it
			if ( action == EDIT ) 
				return;
			
			// create an object for the variables to send to the save table				
			var fv:Object = new Object();
			
			// check if it is editing a saved data
			if (savedID > 0) 
				fv['id'] = savedID;
			
			var savedPledgeData:Object = pledgeData;
			for ( var key:String in contactData )
				savedPledgeData[key] = contactData[key];
			
			// create a data object to save
			var dataObj:Object = new Object();
			dataObj['vo'] = { 
				pledge : savedPledgeData, 
				contact : contactData, 
				check : checkData,
				billing : billingData
			};			
			
			// add the contact owner to the information
			if(initialContactData)
			{
				if( initialContactData.hasOwnProperty('created_by_id') )
					dataObj['contactOwner'] = initialContactData.created_by_id;
				else
					dataObj['contactOwner'] = session.user_id;
			}
			else
				dataObj['contactOwner'] = session.user_id;

			// add which table and the serialized data
			fv['table'] = 'pledges';
			fv['data'] 	= eNilssonUtils.serialize(dataObj);
			
			if ( debug ) Logger.info('Save Workspace', ObjectUtil.toString( dataObj ) );
			
			// dispatch the event to save this data		
 			new PWEvent( PWEvent.SAVE, this, fv ).dispatch();
		}

		
		/**
		 * Process the workspace
		*/
		public var vo:PledgeVO;
		public function process():void
		{
			vo = new PledgeVO();
			
			// loop through the contact data and spread the data to the two objects
			for( var field:String in contactData )
			{
				// dont add the id field as it as ambiguous
				if( field == 'id') continue;
				
				// only add the contact data if the conditions are met
				if ( action == PledgeWorkspaceModel.ADD_NEW || action == PledgeWorkspaceModel.ADD_EXISTING )
					if(contactsFields.indexOf(field) > -1)
						vo.contact[field] = contactData[field];
				
				// add all the fields into the pledge object				
				vo.pledge[field] = contactData[field];
			}
			
			// add the occupation and employer if needed to the contact object		
			if ( action == ADD_NEW || action == ADD_EXISTING )
			{
				var employerProps : Array = ['occupation', 'employer', 'employer_address', 'employer_city', 'employer_state', 'employer_zip'];
				
				for each( var prop : String in employerProps ) {
					if(pledgeData.hasOwnProperty(prop)) 
						vo.contact[prop] = pledgeData[prop];
				}
			}

			// add the pledge data
			for( field in pledgeData )
			{
				// dont add the id field as it as ambiguous
				if( field == 'id' ) continue;

				// set the entered data, limiting it only to valid pledge fields
				if(pledgeFields)
					if(pledgeFields.indexOf(field) > -1)
						vo.pledge[field] = pledgeData[field];
				
				// set the tr_users_id as a seperate variable
				if ( field == 'tr_users_id' ) vo.tr_users_id = pledgeData[field];
			}	
			
			// add the details if needed to the contact object		
			if ( billingData && ( action == ADD_NEW || action == ADD_EXISTING ) )
			{
				if ( billingData.hasOwnProperty('address') ) vo.contact['billing_address1'] = billingData.address
				if ( billingData.hasOwnProperty('address2') ) vo.contact['billing_address2'] = billingData.address2
				if ( billingData.hasOwnProperty('city') ) vo.contact['billing_city'] = billingData.city
				if ( billingData.hasOwnProperty('state') ) vo.contact['billing_state'] = billingData.state;
				if ( billingData.hasOwnProperty('zip') ) vo.contact['billing_zip'] = billingData.zip;
			}
			
			// add any payments as necessary
			switch ( transVStack )
			{
				case CC_VIEW :
					vo.check = null;
					vo.transaction = new TransactionVO();
					vo.transaction.data = transactionData;
					
					// add the appropriate address data including billing data if needed
					if ( billingData == null )
						vo.transaction.data = vo.pledge;
					else
					{
						vo.transaction.data 	= billingData;
						vo.transaction.fname 	= vo.pledge.fname;
						vo.transaction.lname 	= vo.pledge.lname;
					}
					
					vo.paymentType = 'credit card';	
				break;
				case CHECK_VIEW :
					vo.transaction = null;
					vo.check = {};
					vo.check = checkData;
					delete vo.check['id'];
					
					vo.paymentType = 'check';
				break;
				case NO_CONTRIB_VIEW :
					vo.transaction = null;
					vo.check = null;
					vo.paymentType = 'none';
				break;		
			}
			
			// make some action dependant changes to the VO
			switch ( action )
			{
				case ADD_NEW :
					delete vo.contact['id'];
					delete vo.pledge['contact_id'];
					delete vo.pledge['id'];
				break;
				case ADD_EXISTING :
					vo.contact['id'] = contactID;
					vo.pledge['contact_id'] = contactID;
					delete vo.pledge['id'];
				break;
				case ADD_SHARED :
					vo.contact = null;
					vo.pledge['contact_id'] = contactID;
					delete vo.pledge['id'];
				break;	
				case EDIT :
					vo.contact = null;
					vo.pledge['contact_id'] = contactID;
					vo.pledge['id'] = pledgeID;
				break;			
			}	
			
			if ( debug ) Logger.info('Pledge VO', ObjectUtil.toString( vo ) );
			
			new PWEvent ( PWEvent.DO_TRANSACTION, this, { vo: vo } ).dispatch();	
		}

		
		/**
		 * Reset the model
		 */
		public function reset( action:String = ADD_NEW ):void
		{
			this.action = action;	
			
			pledgeID = undefined;
			contactID = undefined;
			formProcessing = false;
			showErrorList = false;
			showDupBox = false;
			
			vindex = CONTACT_FORM_VIEW;
			transVStack = CC_VIEW;
			ccVStack = CC_DETAILS_VIEW;
			
			pledgeAmount = '';
			
			transactionAttempts = 0;
			
			resetInitials = true;	
			
			eventsLabel = '';
			eventsValue = 0;
			tr_usersLabel = '';
			tr_usersValue = 0;
			
			initialContactData = {};
			initialBillingDetails = {};
			initialPledgeData = {};	
			clearPaymentForms = true;
			clearPaymentForms = false;
			
			checkData = {};	
			billingData = {};
		}
	}
}