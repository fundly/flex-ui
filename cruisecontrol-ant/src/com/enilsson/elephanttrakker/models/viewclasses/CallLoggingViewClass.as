package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	import com.enilsson.elephanttrakker.vo.PledgeVO;
	import com.enilsson.elephanttrakker.vo.TransactionVO;
	
	import mx.collections.ArrayCollection;

	/**
	 * A collection of data for the Pledge Workspace module
	 */	
	[Bindable]
	public class CallLoggingViewClass
	{
		public function CallLoggingViewClass()
		{
		}
		
		// variables for the viewstack action
		public var vindex:uint = 1;
		public var prevVIndex:Number = -1;
		public var tabBackward:Boolean = false;
		public var numTabs:int;
		
		// variable defining the form action
		public var formAction:String = 'add';
		public var runInit:Boolean = false;
		
		// object to define the workspace agreement
		public var agreement:Object;
		
		// strings to define the text show on completion of a pledge
		public var successTextCC:String;
		public var successTextCheck:String;
		
		// objects containing the initial entry of data for the forms
		public var initialPledgeData:Object;
		
		public var transactionData:Object;
		public var checkData:Object;
		public var ccData:Object;
		
		// object for containing the payment form variables
		public var creditCardForm:Object;
		public var checkForm:Object;
		
		// objects containing the saved data
		public var vo:PledgeVO = new PledgeVO();
				
		// variables containing the current selected transaction vstack index
		public var transVStack:int = 0;
		public var ccVStack:int = 0;
		
		// variable containing the pledge amount to pass to the cc or check forms
		public var pledgeAmount:String;

		// variables representing the valid status of each of the tabs
		public var contactDetailsValid:Boolean = false;
		public var pledgeInfoValid:Boolean = false;
		public var agreementValid:Boolean = false;
		
		// some variables for representing the form processing and the error popup
		public var formProcessing:Boolean = false;
		public var errorVO:ErrorVO;
		public var completedPledge:Boolean = false;

		// shows if the contact is shared or not
		public var userID:Number;
		public var tr_users_id:Number;
		
		// flag to initiate a reset on the agreement initials boxes
		public var resetInitials:Boolean = true;		
				
		public var contactID:uint = 0;
		public var pledgeID:uint = 0;
		public var transactionID:uint = 0;
		
		// for the save feature
		public var savedID:Number = 0;
		public var recordID:Number = 0;
		
		// variables for other modules to reference when data is to be loaded on init 
		public var load_pledge_id:int = 0;
		public var load_contact_id:int = 0;

		// variables for the lookup search input fields
		public var sourceCodeSearch:ArrayCollection;
		public var fidSearch:ArrayCollection;
		public var eventsLabel:String = '';
		public var eventsValue:uint = 0;
		public var tr_users:Object;
		public var tr_usersLabel:String = '';
		public var tr_usersValue:Number = 0;

		// variables for the duplicates listing
		public var showDupBox:Boolean = false;
		public var contactDups:ArrayCollection = new ArrayCollection();
		public var pledgeDups:Array;
		public var dupsVStack:int = 0;
		
		// track how many attempts the user has at one record
		public var transactionAttempts:int = 0;

		// list of the fields in the pledges form
		public var contactsFields:Array;
		public var pledgeFields:Array;
		public var ccFields:Array;
		public var checkFields:Array;
		
		// list of the error fields for each form
		public var contactsErrors:Array;
		public var pledgeErrors:Array;
		public var ccErrors:Array;
		public var checkErrors:Array;
		public var billingErrors:Array;
		
		public var showErrorList:Boolean = false;

		// dunno what these are for...
		public var layoutLoaded:Boolean = false;
		public var numLayouts:uint = 0;	
		public var action:String = "complete";		
		public var layout:Object = null;
		public var records:Array = new Array();
		
		
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
		 * Get and set the initial contact data, and push any billing details if necessary
		 */
		private var _initialContactData:Object;
		public function set initialContactData ( value:Object ):void
		{
			_initialContactData = value;	
			
			if( value.billing_address1 != '' && value.billing_city != '' && value.billing_state != '' )
				initialBillingDetails = value;
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
		 * Convenience function to add contact data
		 */
		public function set contactData( value:Object ):void
		{						
			// determine if there is contact data loaded and if the user owns that contact
			var cOwner:int = 0;
			if(initialContactData)
				if(initialContactData.hasOwnProperty('created_by_id'))
					cOwner = initialContactData.created_by_id;				
			
			// initialise the objects if they are not already
			vo.contact = formAction == 'add' && (cOwner == userID || cOwner == 0) ? new Object() : null;
			if(!vo.pledge) vo.pledge = new Object();
			
			// loop through the value and spread the data to the two objects
			for( var field:String in value )
			{
				// dont add the id field as it as ambiguous
				if( field == 'id') continue;
				
				// only add the contact data if the conditions are met
				if(vo.contact != null)
					if(contactsFields.indexOf(field) > -1)
						vo.contact[field] = value[field];
				
 				// add the occupation and employer if they are filled in		
				if(vo.contact != null && vo.pledge != null)
				{
					if(vo.pledge.hasOwnProperty('occupation'))
					{
						vo.contact['occupation'] = vo.pledge.occupation;
						vo.contact['employer'] = vo.pledge.employer;
					}
				}
				
				vo.pledge[field] = value[field];
				
				// set the check email field
				if(field == 'email')
				{
					if(vo.check)
					{
						vo.check['email'] = vo.check['email'] == '' ? value[field] : vo.check['email'];
						checkData = vo.check;
					}	
					else
						checkData = { 'email' : value[field] };
				}
			}
			
			// add the contact data if present
			if(contactID != 0) 
			{
				if(vo.contact != null)
					vo.contact['id'] = contactID;
				
				vo.pledge['contact_id'] = contactID;
			}
			
			// update the payment data
			switch(transVStack)
			{
				case 0 :
					addPayment = creditCardForm;
				break;
				case 1 :
					addPayment = checkForm;
				break;
			}
		}
		
		public function get contactData():Object
		{
			return vo.contact
		}
		

		/**
		 * Convenience function to add pledge data
		 */		
		public function set pledgeData( value:Object ):void
		{
			if(!vo.pledge) vo.pledge = new Object();
			
			for( var field:String in value)
			{
				// dont add the id field as it as ambiguous
				if( field == 'id' ) continue;

				// set the entered data, limiting it only to valid pledge fields
				if(pledgeFields)
					if(pledgeFields.indexOf(field) > -1)
						vo.pledge[field] = value[field];
				else
					vo.pledge[field] = value[field];
				
				// set the tr_users_id as a seperate variable
				if ( field == 'tr_users_id' ) vo.tr_users_id = value[field];
				
 				// set the occupation field if there is a contact object in place
				if(vo.contact != null && field == 'occupation')
					vo.contact['occupation'] = value[field];
				
				// set the employer field if there is a contact object in place	
				if(vo.contact != null && field == 'employer')
					vo.contact['employer'] = value[field];
			}
				
			// add the pledge id if present
			if(pledgeID != 0) 
				vo.pledge['id'] = pledgeID;
			
			// add the contact id if present
			if(contactID != 0) 
				vo.pledge['contact_id'] = contactID;
				
			// update the payment data
			switch(transVStack)
			{
				case 0 :
					addPayment = creditCardForm;
				break;
				case 1 :
					addPayment = checkForm;
				break;
			}
		}	
		
		public function get pledgeData():Object
		{
			return vo.pledge;
		}	


		/**
		 * When the billing details are updated add them to the appropriate places
		 */
		public function set addBillingAddress ( value:Object ):void
		{
			// wipe the id variable if present
			if ( value.hasOwnProperty('id') ) delete value.id;
			
			// check to see if there is data in any of the fields
			var flag:Boolean = true;
			for each ( var item:Object in value )
				if ( String(item) != '' ) flag = false;
			
			// if there is no data in the object wipe the billing VO	
			if(flag) 
			{
				vo.billing = null;
				return;
			}
			
			// save the billing data to the VO 
			vo.billing = value;
			
			// add the billing data back to the contact VO if it is present
			if ( vo.contact )
			{
				if ( value.hasOwnProperty('address') ) vo.contact['billing_address1'] = value.address
				if ( value.hasOwnProperty('address2') ) vo.contact['billing_address2'] = value.address2
				if ( value.hasOwnProperty('city') ) vo.contact['billing_city'] = value.city
				if ( value.hasOwnProperty('state') ) vo.contact['billing_state'] = value.state;
				if ( value.hasOwnProperty('zip') ) vo.contact['billing_zip'] = value.zip;
			}
			
			// add the billing details to the transaction VO
			vo.transaction.data = vo.billing;
		}
		
		/**
		 * Reset the billing address details if someone decides they are not needed
		 */
		public function clearBillingAddress():void
		{
			// set the billing vo to null
			vo.billing = null;
			// send the user back to the main credit card form
			ccVStack = 0;
			// wipe the values in the fields for the billing form			
			var bObj:Object = {
				'billing_address1' : '',
				'billing_address2' : '',
				'billing_city' : '',
				'billing_state' : '',
				'billing_zip' : ''				
			};
			initialBillingDetails = bObj;
			// remove the billing details from the contact VO
			delete vo.contact['billing_address1'];
			delete vo.contact['billing_address2'];
			delete vo.contact['billing_city'];
			delete vo.contact['billing_state'];
			delete vo.contact['billing_zip'];
			// save over the contact information in the transaction vo
			vo.transaction.data = vo.pledge;
		}



		/**
		 * Convenience function to add payment data
		 */				
		public function set addPayment ( value:Object ):void
		{
			if(value == null) return;			
			
			if( value.hasOwnProperty('email') && transVStack == 0 ) return;
			
			vo.check = null;
			vo.transaction = null;
			vo.transactionData = null;
			
			switch(transVStack)
			{
				// transaction (credit card) data
				case 0 :
					// add the raw transaction data
					vo.transactionData = value;			
					// build the correct transaction data for the service call
					vo.transaction = new TransactionVO;
					vo.transaction.data = value;
					// add the appropriate address data including billing data if needed
					if ( vo.billing == null )
						vo.transaction.data = vo.pledge;
					else
					{
						vo.transaction.data = vo.billing;
						vo.transaction.fname = vo.pledge.fname;
						vo.transaction.lname = vo.pledge.lname;
					}	
				break;
				
				// check data
				case 1 :
					vo.check = new Object();
					vo.check = value;
					delete vo.check['id'];
				break;
			}
		}
		
		/**
		 * Convenience function to reset this view class
		 */
		public function reset():void
		{
			vo = new PledgeVO();

			savedID = 0;
			contactID = 0;
			pledgeID = 0;
			transactionAttempts = 0;

			runInit = true;
			formAction = 'add';			
			transVStack = 0;
			ccVStack = 0;
			vindex = 0;
			resetInitials = true;
			pledgeAmount = '';			

 			initialContactData = new Object();
			initialPledgeData = new Object();
			initialBillingDetails = new Object();
			
			transactionData = new Object();
			checkData = new Object();
			ccData = new Object();
			
			contactDetailsValid = false;
			pledgeInfoValid = false;
			agreementValid = false;

			formProcessing = false;
			errorVO = null;
		}
	}
}