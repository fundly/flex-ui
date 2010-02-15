package com.enilsson.elephantadmin.views.modules.reporting.external.ocpf
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.elephantadmin.views.modules.reporting.external.common.ExternalReportModulePM;
	import com.enilsson.utils.EDateUtil;

	[Bindable]
	public class OCPFModulePM extends ExternalReportModulePM
	{
		public function OCPFModulePM() {
			super();
			filenamePrefix = "OCPF";
			filenameExtension = "txt";
		}
		
		
		public function get filteredBatchId() : Number { return _filteredBatchId; }
		public function set filteredBatchId( value : Number ) : void {
			_filteredBatchId = value;
		}		
		private var _filteredBatchId : Number;


		public function get restrictable() : Boolean { return _restrictable; }
		public function set restrictable( value : Boolean ) : void {
			_restrictable = value;
			filteredBatchId = NaN;
			
			if(! _restrictable ) restricted = false;
		}		
		private var _restrictable : Boolean;
		
		
		
		public function get restricted() : Boolean { return _restricted; }
		public function set restricted( value : Boolean ) : void {
			_restricted = value;
			filteredBatchId = NaN;			
		}
		private var _restricted : Boolean;
				
		override public function set filter(value:int):void {
			super.filter = value;
			restrictable = ( filter == FILTER_CHECK );  
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

			// don't send any dates if the export has been restricted by batch id
			if(!restricted) {
				EDateUtil.setEndOfDay(endDate);
				vo.startTime = EDateUtil.localDateToTimestamp(startDate);
				vo.endTime = EDateUtil.localDateToTimestamp(endDate);
			}
			
			vo.sortBy = sortBy;
			vo.filter = filter;
			vo.export = true;
			vo.exportTimeOffset = timezoneOffset;
			
			// only set the batch id on the VO if has been set in the UI
			if(! isNaN(filteredBatchId)) 
				vo.batchID = filteredBatchId;
			
			service['export_ocpf'].send.apply(null, [vo]);
		}
	}
}