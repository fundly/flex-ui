package com.enilsson.elephantadmin.views.modules.reporting.external.common
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.utils.EDateUtil;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	[Bindable]
	public class ExternalReportModulePM extends ReportModuleModel
	{
		public static const ONE_DAY	: int = 24 * 60 * 60;
		
		// default start date
		public var startDate:int;
		// default end date is end of today
		public var endDate:int;
		// by default sort results descending
		public var sortArray:Array;
		// the filename prefix that will be used for the exported file
		public var filenamePrefix : String;
		// the filename extension that should be used for the exported file
		public var filenameExtension : String;
		// the service object used for the export call
		protected var service : RemoteObject;
		// dataprovider for the type filter list
		public var typeFilter:ArrayCollection;
		
		
		/**
		 * Constructor
		 **/
		public function ExternalReportModulePM() {
			super();	
			startDate 			= EDateUtil.todayToTimestamp() - ONE_DAY;
			endDate				= EDateUtil.todayToTimestamp();
			sortArray			= ['created_on DESC'];
			filenamePrefix		= "Export";
			filenameExtension	= "csv";
			
			typeFilter 		= new ArrayCollection([
				{label:'All',data:FILTER_ALL},
				{label:'Credit Card',data:FILTER_CC},
				{label:'Check',data:FILTER_CHECK}
			]);
			
			init();
		}
		
		
		/**
		 * Configures the export service.
		 * 
		 * This method should be overridden in subclasses to set additional properties like the service source. 
		 **/
		protected function configureExportService() : void {
 			service	= new RemoteObject('amfphp');
 			service.endpoint = gatewayURL;
			service.addEventListener(ResultEvent.RESULT, getExportDataResult);
			service.addEventListener(FaultEvent.FAULT, getExportDataFault);
		}
		
		
		/**
		 * Sets the exporting and dataLoading flags and triggers the export service call.
		 */
		override public function export():void {
			exporting = true;
			dataLoading = true;
			callExportService();
		}		
		
		
		/**
		 *	Calls an export method on the service.
		 * 
		 * 	To be overridden in subclasses.
		 **/
		protected function callExportService() : void {
			// after configuration, add a method call on the service.
		}
		
		
		/**
		 * Parses the service result.
		 **/
		protected function getExportDataResult( event : ResultEvent ) : void 
		{
			dataLoading = false;
			exporting = false;
					
			if( event.result is ReportResultVO )
			{
				dataLoading = false;
				exporting = false;
				Alert.show( "There is nothing to export", "Error", 0 );
				return;
			}
			
			var df:DateFormatter = new DateFormatter();
			df.formatString = "MM-DD-YYYY";
			
			// call the export script
			var request : URLRequest = new URLRequest(gatewayBaseURL + 
				'export.php?id='+event.result+
				'&file_name='+filenamePrefix+df.format(new Date())+
				'&ext=' + filenameExtension +
				'&refresh='+new Date().getTime() )
			
			navigateToURL( request, '_parent');
			
		}
		
		
		/**
		 * Parses a service fault and shows an error Alert window.
		 **/
		protected function getExportDataFault( event : FaultEvent ) : void {
			Alert.show( "An error occured while exporting the pledges, please decrease the selected date range and try again." "Error", 0 );
			dataLoading = false;
			exporting = false;
		}
	}
}