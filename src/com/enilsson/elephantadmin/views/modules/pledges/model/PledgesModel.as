package com.enilsson.elephantadmin.views.modules.pledges.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.common.utils.SharedCreditUtil;
	import com.enilsson.controls.LookupInput;
	import com.enilsson.elephantadmin.events.main.SidForIdEvent;
	import com.enilsson.elephantadmin.events.modules.PledgeEvent;
	import com.enilsson.elephantadmin.events.modules.RecordModuleEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.PWPopupContainer;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.model.PledgeWorkspaceModel;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.model.PledgeWorkspaceVO;
	import com.enilsson.elephantadmin.views.modules.pledges.popups.Pledges_AddRefund;
	import com.enilsson.elephantadmin.views.modules.pledges.renderers.FID_Item;
	import com.enilsson.elephantadmin.views.modules.pledges.renderers.SourceCode_Item;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.SearchVO;
	import com.enilsson.elephantadmin.vo.SharedCreditVO;
	
	import flash.display.DisplayObject;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.controls.listClasses.ListBase;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import org.osflash.thunderbolt.Logger;

	[Bindable]
	public class PledgesModel extends RecordModel
	{
		public var contributions:ArrayCollection;
		public var contributionsTabLoading:Boolean;
		public var noSplitContributions:Boolean = true;
		
		public var sharedCreditFundraisers : ArrayCollection;
		public var sharedCreditTabLoading : Boolean;		
		public var sharedCreditUsersList : ArrayCollection;
		public var sharedCreditError : ErrorVO;
		
		public var fundTypeInput : ComboBox;
		public var contribTypeInput : ComboBox;
		

		public function PledgesModel(parentModel:ModelLocator=null)
		{
			super(parentModel);
			_allowAddNewRecord = true;
			_addNewRecordLabel = 'ADD PLEDGE';
		}
		
		/**
		 * Override the add record behaviour
		 */
		override public function addNewRecord():void
		{
			var popup:PWPopupContainer = new PWPopupContainer();
			// set popup variables
			popup.defaultType = "credit";
			popup.defaultTab = "contact";
			popup.popupTitle = "Add a new Pledge";

			// set workspace variables
			var vo:PledgeWorkspaceVO = new PledgeWorkspaceVO();
			vo.action = PledgeWorkspaceModel.ADD_NEW;
			EAModelLocator.getInstance().pledgeWorkspace = vo;
			
			PopUpManager.addPopUp(popup, DisplayObject(Application.application), true);
			popup.addEventListener(Event.CLOSE, function (event:Event):void
			{
				PopUpManager.removePopUp(PWPopupContainer(event.currentTarget));
				newPage(searchListCurrPage / itemsPerPage);
			});
			PopUpManager.centerPopUp(popup);
		}

		/**
		 * Capture the get record event and add the Pledge specific elements to it
		 */
		override protected function getRecordDetails():void
		{
			getContributions();
			getSharedCreditFundraisers();
			getAuditTrail();
		}
		
		/**
		 * Capture the set delete btn action and use some pledge specific logic to set the button
		 */
		override protected function setDeleteBtn( value:Object ):void
		{
			showDeleteBtn = true;
			enableDeleteBtn = value.c == 0;
		}
		
		/**
		 * Override of the pledge selection behaviour
		 */
		override public function set selectedRecord ( value:Object ):void
		{
			// Handle selection of SharedCredit pledges so that only the master record can be edited.
			// The cloned record shouldn't be touched.
			if( SharedCreditUtil.isSharedCreditPledge(value) ) {
				new SidForIdEvent( 'pledges', value.pledges_refid ).dispatch();
			}
			else {
				super.selectedRecord = value;
			}
		}

		/**
		 * Get the contribution data for the listed pledge
		 */
		public function getContributions():void
		{
			new PledgeEvent(PledgeEvent.GET_CONTRIBUTIONS, this).dispatch();
		}
		

		/**
		 * Variables for the lookup search input fields
		 */
		public var sourceCodeSearch:ArrayCollection;
		public var fidSearch:ArrayCollection;
		public var eventsLabel:String = '';
		public var eventsValue:Number = 0;
		public var tr_users:Object;
		public var tr_usersLabel:String = '';
		public var tr_usersValue:Number = 0;
		
		/**
		 * Capture the formBuildComplete event and add the pledge specific elements to it
		 */
		override public function formBuildComplete(event:Event):void
		{
			// grab the fid ac input and apply its parameters
			var fid:LookupInput = event.currentTarget.getField('tr_users_id') as LookupInput;
			fid.debugMode = debug;
			fid.itemRenderer = new ClassFactory(FID_Item);
			// add the search lookup action and attach it to a data binding
			fid.addEventListener('searchStart', searchStartHandler);
			BindingUtils.bindProperty(fid, 'searchDataProvider', this, 'fidSearch');
			// add the label search function and appropriate databindings
			fid.addEventListener('labelSearch', labelSearchHandler);
			tr_usersLabel = fid.label;
			BindingUtils.bindProperty(fid, 'label', this, 'tr_usersLabel');
			tr_usersValue = fid.dataValue;
			BindingUtils.bindProperty(fid, 'dataValue', this, 'tr_usersValue');

			// grab the source code ac input and apply its parameters
			var formField:LookupInput = event.currentTarget.getField('event_id') as LookupInput;
			formField.debugMode = debug;
			formField.itemRenderer = new ClassFactory(SourceCode_Item);
			// add the search lookup action and attach it to a data binding
			formField.addEventListener('searchStart', searchStartHandler);	
			BindingUtils.bindProperty(formField, 'searchDataProvider', this, 'sourceCodeSearch');
			// add the label search function and appropriate databindings
			formField.addEventListener('labelSearch', labelSearchHandler);	
			eventsLabel = formField.label;
			BindingUtils.bindProperty(formField, 'label', this, 'eventsLabel');
			eventsValue = formField.dataValue;
			BindingUtils.bindProperty(formField, 'dataValue', this, 'eventsValue');
			
			fundTypeInput = event.currentTarget.getField('fund_type') as ComboBox;
			if(fundTypeInput)
				BindingUtils.bindProperty( fundTypeInput, 'enabled', this, 'noSplitContributions' );
			
			contribTypeInput = event.currentTarget.getField('contribution_type') as ComboBox;
			if(contribTypeInput)
				BindingUtils.bindProperty( contribTypeInput, 'enabled', this, 'noSplitContributions' );
		}
		
		override public function searchListSelectedIndexChange( event:ListEvent ):void 
		{
			selectedRecord =  (event.currentTarget as ListBase).selectedItem;	
			getContributions();
		} 
		
		/**
		 * Handle the searches for the LookupInput fields
		 */
		public function searchStartHandler(event:Event):void
		{
			if(debug) Logger.info ('search start', event.currentTarget.dataValue, event.currentTarget.label);
			
			var tbl:String;
			
			switch( event.currentTarget.id ) {
				case 'tr_users_id' : 
					tbl = 'tr_users_details'; 
				break;
				default: 
					tbl = 'events'; 
				break;
			}
			 
			new PledgeEvent ( 
				PledgeEvent.LOOKUPINPUT_SEARCH,
				this,
				new SearchVO ( tbl, event.currentTarget.searchTerm, null, 0, 200 )
			).dispatch();
		}
		
		/**
		 * Handle any label searches that are needed for the LookupInputs
		 */
		private function labelSearchHandler(event:Event):void
		{
			if(debug) Logger.info ('perform label search', event.currentTarget.dataValue, event.currentTarget.label);
			
			var tbl:String = event.currentTarget.id == 'tr_users_id' ? 'tr_users_details' : 'events';
			
			new PledgeEvent (
				PledgeEvent.GET_LABEL,
				this,
				new RecordVO ( tbl, event.currentTarget.dataValue ) 
			).dispatch();
		}		
		
		public function showRefundForm():void
		{
			var refund:Pledges_AddRefund = new Pledges_AddRefund();
			refund.presentationModel = this;
			refund.width = 400;
			refund.height = 425;
			PopUpManager.addPopUp(refund, EAModelLocator(mainModel).mainScreen, true);
			PopUpManager.centerPopUp(refund);
		}
		
		
		public var refundError:ErrorVO;
		
		public function get checkLayout():Object
		{
			return EAModelLocator(mainModel).struktorLayout['checks'];
		}
		
		/**
		 * Create a refund as a check contribution
		 */
		public function addCheckRefund( formVariables:Object, fundType : String = null ):void
		{
			// check to see the user hasnt tried to refund too much
			if( Number(formVariables.amount) > Number(selectedRecord.contrib_total) )
			{
				refundError = new ErrorVO('You can not refund more than the contributed amount!', 'errorBox', true);
				return;
			}			
			
			// set the amount to negative so this is a refund
			// take the negative of the absolute value of the inputted amount
			// This ensures that the amount is always negative
			formVariables.amount = -1 * Math.abs(formVariables.amount);
			
			// add the parent pledge id to the variables
			formVariables['pledge_id'] = selectedRecord.id;
			
			// dispatch the event to upsert the data
			new PledgeEvent ( 
				PledgeEvent.ADD_CHECKREFUND, 
				this, 
				{ formVariables:formVariables, fundType:fundType } )
			.dispatch();
				 
		}
		
		/**
		 * Fire an event to update the pledge when a contribution is added
		 */
		public function updatePledge ():void
		{
			new RecordModuleEvent (
				RecordModuleEvent.GET_FULL_RECORD,
				this,
				{ sid : selectedRecord.sid }
			).dispatch();
		}
		
		public function userSearchStart( event : Object ) : void {
			
		}
		
		public function getSharedCreditFundraisers() : void {
			
			var pid : int = this.recordID;			
			new PledgeEvent(PledgeEvent.GET_SHARED_CREDIT_USERS, this, { pledgeID : pid } ).dispatch();
		}
		
		public function addSharedCredit( user : Object ) : void {
			
			if(!user || !selectedRecord ) return;
			
			var vo : SharedCreditVO = new SharedCreditVO( selectedRecord.id, user.user_id );
			new PledgeEvent( PledgeEvent.ADD_SHARED_CREDIT, this, vo ).dispatch();
		}
		
		public function removeSharedCredit( sharedCredit : Object ) : void {
			
			if(!sharedCredit) return;
			
			var vo : SharedCreditVO = new SharedCreditVO( sharedCredit.shared_pledge_id, sharedCredit.sw_user_id );
			new PledgeEvent( PledgeEvent.REMOVE_SHARED_CREDIT, this, vo ).dispatch();
		}
		
		/**
		 * Handler for when the pledge update is complete
		 */
		override public function onRecordUpdate():void
		{
			getContributions();
		}
	}
}