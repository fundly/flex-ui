package com.enilsson.elephantadmin.views.modules.reporting.fundraisers.model
{
	import com.enilsson.elephantadmin.events.main.SidEvent;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.Application;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	[Bindable]
	public class FundraisersModel extends ReportModuleModel
	{
		public var regionFilter:ArrayCollection = new ArrayCollection([
			{'label':'All','data':'0'}
		]);

		public var sortArray:Array = ['downline_pledge DESC'];
		public var exportHeaders:Array = [];
		public var exportFields:Array = [];
		public var exportTitle:String = "";

		public var recordsHtmlText:String;
		
		public function FundraisersModel():void
		{
		}

		override public function init():void
		{
			super.init();
			for each(var item:Object in userGroups)
			{
				regionFilter.addItem(item);
			}
			generate();
		}

		public function regionChangeHandler(event:ListEvent):void
		{
			gridCurrentPage = 0;
			group = event.currentTarget.selectedItem.value;
		}

		override public function generate():void
		{
			super.generate();
			
			// if no vo was passed through, get parameters from the UI
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");

			vo.sortBy = sortBy;
			vo.page = gridCurrentPage;
			vo.recordPerPage = itemsPerPage;
			vo.groupID = group;

			if(exporting)
			{
				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				exportTitle = 'Fundraisers - ' + regionFilter.getItemAt(group).label;
				vo.exportTitle = exportTitle;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
			}

			Logger.info('SEND',ObjectUtil.toString(vo));

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.fundraisers';
			amfService['get_fundraisers'].send.apply(null, [vo]);	
			amfService.addEventListener(ResultEvent.RESULT, generateResult);
			amfService.addEventListener(FaultEvent.FAULT, generateFault); 
		}

		private function generateResult(event:ResultEvent):void
		{
			dataLoading = false;	

			Logger.info('RETURN',ObjectUtil.toString(event.result));

			if(event.result is ReportResultVO)
			{
				var vo:ReportResultVO = event.result as ReportResultVO;

				if(exporting)
				{
					exporting = false;
					Alert.show("There is nothing to export", "Error", 0, Application.application.root);
					return;
				}
				gridRecords = vo.list;
				gridTotalRecords = vo.total_records;
				updateText();
			}
			else
			{
				var filename:String = exportTitle.replace(/\s/g,"_");
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM-DD-YYYY";
				navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+filename+"_"+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
				exporting = false;
			}
		}

		private function generateFault(event:FaultEvent):void
		{
			dataLoading = false;	
			Logger.info('RETURN',ObjectUtil.toString(event.fault))
			Alert.show("Internet connection error please try again soon (" + event.fault + ")", "Error", 0, Application.application.root, function():void {	return;	});
		}
					
		override public function newPage(event:Event):void
		{
			super.newPage(event);

			generate();
		}

		override public function sortRecords(event:DataGridEvent):void
		{
		 	// get the fieldname
		 	var fieldName:String;

			// sort by last name
	 		fieldName = event.dataField;

			if(fieldName == 'mod_group_name')
				fieldName = 'mod_group_id';

			if(fieldName == '_fid')
				fieldName = 'right(_fid,length(_fid)-length(\'FUND\'))';

			// If same field was selected, reverse the direction
		 	if(fieldName == sortArray[0].split(" ")[0])
		 	{
		 		if(sortArray[0].split(" ")[1] == 'DESC')
			 		sortArray[0] = fieldName +  ' ASC';
			 	else
			 		sortArray[0] = fieldName + ' DESC';
		 	}
		 	else
		 	// if not, order by the new field in ascending direction
		 	{
		 		sortArray[1] = sortArray[0];
			 	sortArray[0] = fieldName + ' ASC';
			}

		 	// loop through and highlight the sorted column
		 	for ( var i:int=0; i<event.target.columns.length; i++)
		 	{
		 		if(event.columnIndex == i)
		 			event.target.columns[i].setStyle('backgroundColor','#ededed');
		 		else
		 			event.target.columns[i].setStyle('backgroundColor','none');
		 	}
		 	
		 	generate();
		}

		public function inspectHandler(sid:String):void
		{
		//	var sid:String = gridRecords.getItemAt(event.rowIndex).sid;
			new SidEvent(sid).dispatch();
		}

 		private function updateText():void
		{
			var plural:String = gridTotalRecords > 1 ? 's' : '';				
			
			if(gridTotalRecords < itemsPerPage)
			{
				recordsHtmlText = '<b>' + gridTotalRecords + '</b> record' + plural;
			}
			else
			{
				var startIndex:String = (gridCurrentPage * itemsPerPage + 1).toString();
				var toIndex:int =  gridCurrentPage * itemsPerPage + itemsPerPage;
				var toIndexString:String = toIndex < gridTotalRecords ? toIndex.toString() : gridTotalRecords.toString();
				
				recordsHtmlText = '<b>' + startIndex + '</b>';
				recordsHtmlText += '-<b>' + toIndexString + '</b>';
				recordsHtmlText += ' of <b>' + gridTotalRecords + '</b> record' + plural;				
			}
		}
		
		override public function exportGrid(columns:Array):void
		{
			super.exportGrid(columns);
			exportHeaders = [];
			exportFields = [];

			for each(var column:DataGridColumn in columns){
				if(column.dataField != null)
				{
					exportHeaders.push(column.headerText);
					exportFields.push(column.dataField);
				}
			}
			generate();
		}
	}
}