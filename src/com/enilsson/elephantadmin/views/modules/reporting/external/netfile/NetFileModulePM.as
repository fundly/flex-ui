package com.enilsson.elephantadmin.views.modules.reporting.external.netfile
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.elephantadmin.views.modules.reporting.external.common.ExternalReportModulePM;
	import com.enilsson.utils.EDateUtil;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class NetFileModulePM extends ExternalReportModulePM
	{
		public var netfileFilter:ArrayCollection = new ArrayCollection([
			{label:'Entity',data:'0'},
			{label:'Income',data:'1'}
		]);

		public var reportType:int;
		public var recordsHtmlText:String;

		public function NetFileModulePM() {
			init();
			super.typeFilter.addItem( {label:'PayPal',data:FILTER_PAYPAL} );
			super.typeFilter.addItem( {label:'In-Kind',data:FILTER_INKIND} );
			super.typeFilter.addItem( {label:'Cash',data:FILTER_CASH} );
		}
		
		
		override protected function configureExportService():void {
			super.configureExportService();
			super.service.source = 'plugins.common.reporting.net_file';
		}
		
		
		override protected function callExportService():void {
			configureExportService();
			
			dataLoading = true;
			
			EDateUtil.setEndOfDay(endDate);
			
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");

			vo.startTime = EDateUtil.localDateToTimestamp(startDate);
			vo.endTime = EDateUtil.localDateToTimestamp(endDate);
			vo.sortBy = sortBy;
			vo.filter = filter;
			vo.export = true;
			vo.exportTimeOffset = timezoneOffset;
			
			if(reportType == 0) {
				filenamePrefix = 'NetFile_Entity';
				service['export_contributors'].send.apply(null, [vo]);
			}
				
			else if(reportType ==1) {
				filenamePrefix = 'NetFile_Income';
				service['export_contributions'].send.apply(null, [vo]);
			}
		}
	}
}