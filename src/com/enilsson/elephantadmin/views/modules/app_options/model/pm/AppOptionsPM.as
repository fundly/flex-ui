package com.enilsson.elephantadmin.views.modules.app_options.model.pm
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.app_options.SiteOptionsEvent;
	import com.enilsson.elephantadmin.views.modules.app_options.model.SiteOption;
	import com.enilsson.elephantadmin.views.modules.batch.model.AbstractPM;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class AppOptionsPM extends AbstractPM
	{
		// collection of all site options
		public var siteOptions			: ArrayCollection;
		public var selectedSiteOption	: SiteOption;
		
		// trigger the event to load the site options and store them in the domain model
		public function loadSiteOptions() : void {
			new SiteOptionsEvent( SiteOptionsEvent.GET_SITE_OPTIONS ).dispatch();	
		}
		
		// nested presentationmodels
		[Bindable(event="optionsEditorPMChanged")]
		public function get optionsEditorPM() : OptionsEditorPM { return _optionsEditorPM; }
		private var _optionsEditorPM : OptionsEditorPM;
		
		
		override protected function createChildren():void {
			super.createChildren();
			
			_optionsEditorPM = new OptionsEditorPM( domainModel );			
			addChild( optionsEditorPM );
			
			BindingUtils.bindProperty( this, 'selectedSiteOption', _optionsEditorPM, 'siteOption' );
			dispatchEvent( new Event("optionsEditorPMChanged"));
		}
		
		override protected function setUpWatchers():void {
			super.setUpWatchers();
			addWatcher( BindingUtils.bindProperty( this, 'siteOptions', domainModel, ['appOptions','siteOptions']), 'siteOptions' );
		}
		
		public function AppOptionsPM(domainModel:IModelLocator) {
			super(domainModel);
		}
	}
}