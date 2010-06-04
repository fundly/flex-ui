package com.enilsson.elephantadmin.views.modules.events
{
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.common.AccessOptionsTab;
	import com.enilsson.elephantadmin.views.manage_record_base.ManageRecord;
	import com.enilsson.elephantadmin.views.modules.events.model.EventsModel;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;

	public class ManageEventRecord extends ManageRecord
	{		
		protected var accessOptionsTab : AccessOptionsTab;
		
		[Bindable] private var _model : EAModelLocator = EAModelLocator.getInstance();
		
		
		private function handleAccessChange( event : Event ) : void
		{
			var e_read 		: int = accessOptionsTab.visibilityType == 'all' ? 1 : 0;
			var group_id 	: int = accessOptionsTab.groupID;
			var g_read 		: int = 0;
			var g_write		: int = 0;
			
			if(group_id != 0) {
				g_read	= 1;
				g_write	= 1;
			}			  
			
			(presentationModel as EventsModel).eventAccessRights = {
				mod_e_read:		e_read,
				mod_g_read: 	g_read,
				mod_g_write:	g_write,
				mod_group_id:	group_id 
			};
		}
		
		override protected function createChildren():void
		{
			if( !recordPanel )
			{
				recordPanel = new EventRecordPanel();
				recordPanel.styleName = 'recordPanel';
				this.addChild( recordPanel );
			}
			
			super.createChildren();
			
			// move recordPanel to the top after all the other children have been created
			setChildIndex( recordPanel, numChildren - 1 );
			
			if(optionsBox)
			{
				accessOptionsTab = new AccessOptionsTab();
				accessOptionsTab.headerText = "Event visibility"
				accessOptionsTab.text = "You can either set the event item to be read by all users with the checkbox below. Or chose to restrict it to members of one of the state groups listed below";
				
				accessOptionsTab.addEventListener(Event.CHANGE, handleAccessChange, false, 0, true);
				optionsBox.addChild(accessOptionsTab);
				
				BindingUtils.bindProperty(accessOptionsTab, "dataProvider", this, ["presentationModel","selectedRecord"] );
				BindingUtils.bindProperty(accessOptionsTab, "setGroups", _model, "orgGroups");
			}
		}
	}
}