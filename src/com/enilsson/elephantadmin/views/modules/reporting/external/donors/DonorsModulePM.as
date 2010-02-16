package com.enilsson.elephantadmin.views.modules.reporting.external.donors
{
	import com.enilsson.elephantadmin.views.modules.reporting.external.common.ExternalReportModulePM;

	[Bindable]
	public class DonorsModulePM extends ExternalReportModulePM
	{
		public var selectedGroupId : Number = 0;
		
		public function DonorsModulePM() {
			init();
			filenamePrefix = "Donors_";
		}
		
		override protected function configureExportService():void {
			super.configureExportService();
			super.service.source = 'plugins.' + instanceID + '.reporting.donors';
		}
		
		
		override protected function callExportService():void {
			configureExportService();
			
			dataLoading = true;
			service['export_donors'].send.apply(null, [timezoneOffset, selectedGroupId]);
		}
	}
}