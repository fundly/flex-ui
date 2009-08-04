package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.events.main.SidEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.SidVO;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SidCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function SidCommand()
		{
		}
		
		override public function execute(event:CairngormEvent):void
		{
			var e:SidEvent = event as SidEvent;
			
			_model.dataLoading = true;
			
			if ( _model.debug ) Logger.info('Check for SID', e.sid);
			
			var delegate:RecordDelegate = new RecordDelegate(this);
			delegate.getSidRecord( e.sid );			
		}
		
		public function result(event:Object):void
		{
			if(_model.debug) Logger.info('Success SID test', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			
			// if the attempted SID is wrong then proceed to the first module
			if(event.result == 'Invalid hash')
				_model.mainViewState = 0;
				
			// if the attempted SID is valid then created the sid variable
			else
			{
				// create the SidVO and apply it to the model
				var sid:SidVO = new SidVO ( event.result );
				_model.sid = sid;
				// if there is no record data then go to the first module
				if(sid.empty)
					_model.mainViewState = 0;
				// if there is a record then go to the appropriate module
				else
					_model.mainViewState = _model.tableModuleMapping[sid.table_name];
			}			
		}
		
		public function fault(event:Object):void
		{
			if(_model.debug) Logger.info('Fault Sid Event', ObjectUtil.toString(event));

			_model.dataLoading = false;

			// if things go belly up send the user back to the first module
			_model.mainViewState = 0;
		}

	}
}