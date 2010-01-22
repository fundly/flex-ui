package com.enilsson.elephantadmin.views.modules.app_options.view.option_views
{
	import flash.events.Event;
	
	import mx.containers.VBox;
	
	public class Options_ProgressReportsBase extends VBox
	{
		import com.enilsson.elephantadmin.views.modules.app_options.model.pm.OptionsEditorPM;
		
		[Bindable] public var pm : OptionsEditorPM;		
		
		[Bindable]
		protected function get topFundraisersEnabled() : Boolean { return _topFundraisersEnabled; }
		protected function set topFundraisersEnabled( val : Boolean ) : void {
			_topFundraisersEnabled = val;
			changeOption();
		} 
		private var _topFundraisersEnabled : Boolean;
		
		[Bindable]
		protected function get groupPerformanceEnabled() : Boolean { return _groupPerformanceEnabled; }
		protected function set groupPerformanceEnabled( val : Boolean ) : void {
			_groupPerformanceEnabled = val;
			changeOption();
		} 
		[Bindable] private var _groupPerformanceEnabled : Boolean;
		
		
		protected function handleTopFundraisersChange( event : Event ) : void {
			topFundraisersEnabled = event.currentTarget.selected;	
		}
			
		protected function handleGroupPerformanceChange( event : Event ) : void {
			groupPerformanceEnabled = event.currentTarget.selected;
		}
			
		protected function set optionValue( val : String ) : void {
			try {
				optionXml = new XML( pm.editingSiteOption.value );
				topFundraisersEnabled 		= optionXml.topfundraisers.enabled == 'true';
				groupPerformanceEnabled		= optionXml.groupperformance.enabled == 'true';
			}
			catch( e : Error ) { 
				optionXml 				= null;
				topFundraisersEnabled	= false;
				groupPerformanceEnabled = false; 
			}
		}			
		[Bindable] protected var optionXml : XML;
			
			
		private function changeOption() : void {
			optionXml.topfundraisers.enabled	= topFundraisersEnabled ? 'true' : 'false';
			optionXml.groupperformance.enabled	= groupPerformanceEnabled ? 'true' : 'false';
			pm.changeOption( "value", optionXml.toXMLString() );
		}
	}
}
