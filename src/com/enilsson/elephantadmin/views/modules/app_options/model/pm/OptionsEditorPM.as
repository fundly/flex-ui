package com.enilsson.elephantadmin.views.modules.app_options.model.pm
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.app_options.SaveSiteOptionEvent;
	import com.enilsson.elephantadmin.views.modules.app_options.model.SiteOption;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.utils.ObjectUtil;
	

	[Bindable]
	public class OptionsEditorPM extends AbstractPM
	{
		public static const SITE_OPTION_CHANGE	: String = "siteOptionChange";
				
		[Bindable(event="siteOptionChange")]
		public function get siteOption() : SiteOption { return _siteOption; }
		public function set siteOption( value : SiteOption ) : void
		{
			if(value != _siteOption)
			{
				var isSavedOption : Boolean = value && _siteOption && value.id == _siteOption.id;
				if(!_changed || isSavedOption) {
					_siteOption = value;
					resetEditingOption();
					dispatchEvent(new Event(SITE_OPTION_CHANGE));
				}
				else {
					_requestedSiteOption = value;
					cancel();					
				}
			}
		}
		private var _siteOption : SiteOption;
		
		private var _requestedSiteOption : SiteOption;
		
		
		[Bindable(event="editingSiteOptionChange")]
		public function get editingSiteOption() : SiteOption { return _editingSiteOption; }
		private var _editingSiteOption : SiteOption;
		
		
		[Bindable(event="siteOptionChange")]
		public function get editorTitle() : String {
			return _siteOption ? _siteOption.title : "No option selected";
		}

		
		[Bindable(event="changedChanged")]
		public function get changed() : Boolean { return _changed; }		
		private function setChanged( value : Boolean ) : void {
			_changed = value;
			dispatchEvent(new Event("changedChanged"));
		}
		private var _changed : Boolean;
		

		[Bindable(event="siteOptionChange")]
		public function get displayOption() : Boolean { 
			return _siteOption && _siteOption.display; 
		}
		
		
		public function changeOption( prop : String, value : * ) : void
		{
			if(_editingSiteOption.hasOwnProperty(prop) && _editingSiteOption[prop] != value ) {
				setChanged(true);
				_editingSiteOption[prop] = value;
			}
		}
		
		public function save() : void {
			new SaveSiteOptionEvent( SaveSiteOptionEvent.SAVE_SITE_OPTION, _editingSiteOption, saveCallback ).dispatch();
		}
		
		private function saveCallback() : void
		{
			setChanged(false);
			siteOption = _editingSiteOption;
		}
		
		public function cancel() : void {
			if(_changed) {
				Alert.show("This option has been modified. Are you sure you want to continue without saving your changes?", 
				"Option modified", Alert.NO|Alert.YES, null, handleCancelAlertClose);
			}
			
		}
		private function handleCancelAlertClose( event : CloseEvent ) : void 
		{
			if(event.detail == Alert.YES) {
				_cancel();
			}	
			else {
				// force to trigger the binding for siteOption so that everyone who listens
				// to it gets the right one
				_requestedSiteOption = null;
				dispatchEvent(new Event(SITE_OPTION_CHANGE));
			}
		}
		
		private function _cancel() : void
		{			
			if(_requestedSiteOption)
				setRequestedSiteOption();
			else
				resetEditingOption();		
		}
		
		private function setRequestedSiteOption() : void
		{
			setChanged(false);
			siteOption = _requestedSiteOption;
			_requestedSiteOption = null;
		}
		
		private function resetEditingOption() : void
		{
			setChanged(false);
			_editingSiteOption = ObjectUtil.copy( _siteOption ) as SiteOption;
			dispatchEvent(new Event("editingSiteOptionChange"));
		}
				
		public function OptionsEditorPM(domainModel:IModelLocator)
		{
			super( domainModel );
		}
	}
}