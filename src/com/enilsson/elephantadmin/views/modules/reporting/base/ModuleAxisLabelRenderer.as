package com.enilsson.elephantadmin.views.modules.reporting.base
{
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	import mx.charts.AxisLabel;
	import mx.controls.Label;
	import mx.core.IDataRenderer;
	
	public class ModuleAxisLabelRenderer extends Label implements IDataRenderer
	{
		private var _data:AxisLabel;

		override protected function childrenCreated():void
		{
			super.childrenCreated();
		}
		
		override public function get data():Object
		{
			return _data;
		}
		
		override public function set data(value:Object):void
		{
			if(value != null)
			{
				this._data = value as AxisLabel;
				this.text = String(value.text);
			}
		}
	
	}
}
