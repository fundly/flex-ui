package com.enilsson.elephantadmin.commands.modules.customreporting
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.LayoutDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.modules.ReportingDelegate;
	import com.enilsson.elephantadmin.events.modules.customreporting.CustomReportingEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class CustomReportingCommand extends SequenceCommand implements ICommand
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function CustomReportingCommand()
		{
			super();
		}
		
		override public function execute(event:CairngormEvent):void
		{
			super.execute(event);

			switch(event.type)
			{
				case CustomReportingEvent.GET_REPORTS :
					getReports(event as CustomReportingEvent);
				break;
				case CustomReportingEvent.GET_RELATIONS :
					getRelations(event as CustomReportingEvent);
				break;
				case CustomReportingEvent.GET_SCHEMA :
					getSchema(event as CustomReportingEvent);
				break;
				case CustomReportingEvent.LOAD_REPORT :
					loadReport(event as CustomReportingEvent);
				break;
			}
		}

		/**
		 * Get all the shared users for the contact in question
		 */
		private function getReports(event:CustomReportingEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getReports, onFault_getReports);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			var vo:RecordsVO = new RecordsVO('custom_reporting<name:description>', null, 'custom_reporting.id DESC', 0, 10000);

			_model.dataLoading = true;
			_model.customReporting.reportListLoading = false;

			delegate.getRecords( vo );
		}
		
		private function onResults_getReports(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Shared Contacts Success', ObjectUtil.toString(data.result));

			// assign some variables
			var reports:ArrayCollection = new ArrayCollection()
			for each(var item:Object in data.result.custom_reporting)
			{
				reports.addItem(item);
			}

			_model.customReporting.reportList = reports;
			_model.customReporting.reportListLoading = false;

			// hide the data loading graphic
			_model.dataLoading = false;
		}
			
		private function onFault_getReports(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('getReports Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;	

			_model.errorVO = new ErrorVO( 
				'There was a problem loading custom reports:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Get all the shared users for the contact in question
		 */
		private function getRelations(event:CustomReportingEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getRelations, onFault_getRelations);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);

			_model.dataLoading = true;

			delegate.getRelations(null);
		}
		
		private function onResults_getRelations(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Relations Success', ObjectUtil.toString(event.result));
			
			_model.customReporting.relationships = event.result;

			// hide the data loading graphic
			_model.dataLoading = false;
			
			nextEvent = new CustomReportingEvent(CustomReportingEvent.GET_SCHEMA);
			executeNextCommand();
		}
			
		private function onFault_getRelations(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('getRelations Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;	

			_model.errorVO = new ErrorVO( 
				'There was a problem loading custom reports:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Get all the shared users for the contact in question
		 */
		private function getSchema(event:CustomReportingEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getSchema, onFault_getSchema);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);

			_model.dataLoading = true;

			delegate.getLayoutSchema(null);
		}
		
		private function onResults_getSchema(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Schema Success', ObjectUtil.toString(event.result));

			_model.customReporting.layout = event.result;

			var layout_structure:Object = event.result;
			var layout_tables:Object = new Object();

			for(var index:String in event.result) 
			{
				layout_tables[layout_structure[index].table] = layout_structure[index];
				layout_structure[index].fields_name = new Array();
				for (var index1:String in layout_structure[index].fields) {
					layout_structure[index].fields_name[layout_structure[index].fields[index1].fieldname] = layout_structure[index].fields[index1];
				}
			}

			_model.customReporting.layout_structure = layout_structure;
			_model.customReporting.layout_tables = layout_tables;

			// hide the data loading graphic
			_model.dataLoading = false;
		}
			
		private function onFault_getSchema(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('getSchema Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;	

			_model.errorVO = new ErrorVO( 
				'There was a problem loading layout schema:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


		/**
		 * Get all the shared users for the contact in question
		 */
		private function loadReport(event:CustomReportingEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_loadReport, onFault_loadReport);
			var delegate:ReportingDelegate = new ReportingDelegate(handlers);

			_model.dataLoading = true;

			delegate.loadReport(event.reportID);
		}
		
		private function onResults_loadReport(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Report Success', ObjectUtil.toString(event.result));

			_model.customReporting.loadedData = event.result.obj_data;
			_model.customReporting.reportData['reportID'] = event.result.obj_data.id;
			buildFieldsObj(event.result.obj_data);

			// hide the data loading graphic
			_model.dataLoading = false;
		}

		private function buildFieldsObj(_rData:Object):void
		{
			var _fieldsObj:Array = new Array();
			for( var i:String in _rData.fields){
				if(!_rData.fields[i]){ continue; }
				var fArray:Array = i.split('.');
				for(var j:String in _model.customReporting.layout){
					var tbl:Object = _model.customReporting.layout[j];
					if(fArray[0] == tbl.table){
						for(var k:String in tbl.fields){
							if(fArray[1] == tbl.fields[k].fieldname){
								_fieldsObj.push({ 
									value: i, 
									table: tbl.title,
									field: i,
									title: tbl.fields[k].label,
									label: tbl.title + ' - ' + tbl.fields[k].label +  ' (' + tbl.fields[k].fieldname + ')', 
									type: tbl.fields[k].type
								});
							}
						}
					}
				}
			}
		_model.customReporting.fieldsObj = _fieldsObj;
		}

		private function onFault_loadReport(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('loadReport Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);	

			// hide the data loading graphic
			_model.dataLoading = false;	

			_model.errorVO = new ErrorVO( 
				'There was a problem loading layout schema:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


	}
}