package com.enilsson.elephantadmin.views.modules.reporting.external.ocpf
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.elephantadmin.views.modules.reporting.external.common.ExternalReportModulePM;

	[Bindable]
	public class OCPFModulePM extends ExternalReportModulePM
	{
		public function OCPFModulePM() {
			filenamePrefix = "OCPF";
			filenameExtension = "txt";
		}
		
		public var filteredBatchId : int;
		public var restrictable : Boolean;
				
		override public function set filter(value:int):void {
			super.filter = value;
			restrictable = ( filter == FILTER_ALL || filter == FILTER_CHECK );  
		}
		
		override protected function configureExportService():void {
			super.configureExportService();
			super.service.source = 'plugins.' + instanceID + '.reporting.ocpf';
		}
		
		override protected function callExportService():void {
			configureExportService();
			
			dataLoading = true;
			
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");

			vo.startTime = startDate;
			vo.endTime = endDate + ONE_DAY;
			vo.sortBy = sortBy;
			vo.filter = filter;
			vo.export = true;
			vo.exportTimeOffset = timezoneOffset;
			
			if(!isNaN(filteredBatchId)) 
				vo.batchID = filteredBatchId;
			
			service['export_ocpf'].send.apply(null, [vo]);
		}
	}
}