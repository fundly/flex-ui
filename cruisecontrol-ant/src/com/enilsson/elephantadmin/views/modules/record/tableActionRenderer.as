package com.enilsson.elephantadmin.views.modules.record
{
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.models.Icons;
	
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.Image;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.IFactory;
	import mx.events.FlexEvent;

	public class tableActionRenderer extends HBox implements IDropInListItemRenderer, IFactory
	{
		private var _init:Boolean = true;
		private var _model:EAModelLocator = EAModelLocator.getInstance();		
		
		[Bindable("dataChange")]
		private var _listData : BaseListData;
        		
		public function tableActionRenderer()
		{
			super();
			
			setStyle('horizontalAlign', 'center');
			setStyle('paddingLeft',0);
			setStyle('paddingRight',0);
			
			this.addEventListener(FlexEvent.DATA_CHANGE, dataHandler);
		}
		
		public function newInstance():*
		{
			return new tableActionRenderer();
		}
		
		public function get listData():BaseListData
		{
			return _listData;
		}
		
		public function set listData(value:BaseListData):void
		{
			_listData = value;
		}

		private function dataHandler(e:FlexEvent):void
		{
			var obj:DataGridListData = DataGridListData(listData);
			
			var dataObj:Object = data[obj.dataField];
			
			if(dataObj && _init){
				_init = false;
				var img:Image = new Image();
				img.source = Icons.SEARCH_ACTION;
				img.buttonMode = true;
				img.useHandCursor = true;
				img.toolTip = 'View detailed information on this record';
				img.addEventListener(MouseEvent.CLICK,function():void {
					 parentDocument.parentApplication.loadSingleRecord({'sid':data.sid});
				});
				addChild(img);					
			}				

		}	

	}
}