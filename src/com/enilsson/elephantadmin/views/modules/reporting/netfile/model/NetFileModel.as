package com.enilsson.elephantadmin.views.modules.reporting.netfile.model
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.utils.EDateUtil;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.ListEvent;
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	[Bindable]
	public class NetFileModel extends ReportModuleModel
	{
		private const ONE_DAY:int = 24 * 60 * 60;
		public var netfileFilter:ArrayCollection = new ArrayCollection([
			{label:'Entity',data:'0'},
			{label:'Income',data:'1'}
		]);

		public var typeFilter:ArrayCollection = new ArrayCollection([
			{label:'All',data:'0'}
			,{label:'Credit Card',data:'1'}
			,{label:'Check',data:'2'}
			,{label:'PayPal',data:'3'}
		]);

		// default start date is yesterday
		public var startDate:int = EDateUtil.todayToTimestamp();
		// default end date is end of today
		public var endDate:int = EDateUtil.todayToTimestamp();
		public var sortArray:Array = ['created_on DESC'];

		private var reportType:int;
		public var recordsHtmlText:String;
		
		public function NetFileModel():void
		{
		}

		override public function init():void
		{
			super.init();
		}

		public function reportChangeHandler(event:ListEvent):void
		{
			reportType = event.currentTarget.selectedItem.data;
		}

		public function typeChangeHandler(event:ListEvent):void
		{
			filter = event.currentTarget.selectedItem.data;
		}

		public function startSelect():void
		{
			dataLoading = true;	
			
			// if no vo was passed through, get parameters from the UI
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");

			vo.startTime = startDate;
			vo.endTime = endDate + ONE_DAY;
			vo.sortBy = sortBy;
			vo.filter = filter;
			vo.export = true;
			vo.exportTimeOffset = timezoneOffset;

			Logger.info('SEND',ObjectUtil.toString(vo));

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.net_file';
			amfService.addEventListener(ResultEvent.RESULT, selectResult);
			amfService.addEventListener(FaultEvent.FAULT, selectFault);
			
			if(reportType == 0)
				amfService['export_contributors'].send.apply(null, [vo]);
			else if(reportType ==1)
				amfService['export_contributions'].send.apply(null, [vo]);
		}

		private function selectResult(event:ResultEvent):void
		{
			Logger.info('RETURN',ObjectUtil.toString(event.result));
			if(event.result is ReportResultVO)
			{
				dataLoading = false;
				exporting = false;
				Alert.show("There is nothing to export", "Error", 0, Application.application.root);
				return;
			}
			var filename:String;
			if(reportType == 0)
				filename = 'NetFile_Entity';
			else if(reportType == 1)
				filename = 'NetFile_Income';
			var df:DateFormatter = new DateFormatter();
			df.formatString = "MM-DD-YYYY";
			navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+filename+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
			dataLoading = false;
			exporting = false;
		}

		private function selectFault(event:FaultEvent):void
		{
			Logger.info('RETURN',ObjectUtil.toString(event.fault))
			Alert.show("Internet connection error please try again soon (" + event.fault + ")", "Error", 0, Application.application.root, function():void {	return;	});
			dataLoading = false;	
		}
		
		override public function export():void
		{
			exporting = true;
			startSelect();
		}
	}
}