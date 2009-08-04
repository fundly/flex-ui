package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	
	import org.osflash.thunderbolt.Logger;

	public class URLChangeCommand extends SequenceCommand  implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function URLChangeCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if (!_model.is_parsing_url) Application.application.callLater(updateURL);
		}

		private function updateURL():void
		{
			if(_model.debug) Logger.info('URL Change', _model.browserManager.fragment);
			
			_model.is_parsing_url = true;
			if(_model.browserManager.fragment == '' || _model.browserManager.fragment == 'login')
			{
				_model.screenState = ETModelLocator.LOGIN_SCREEN;
				_model.browserManager.setFragment('login');
			    _model.browserManager.setTitle(_model.appName + ' - Login');
			}
			else
			{
				if (_model.session == null)
				{
					if(_model.debug) Logger.info('URL Change, check session', _model.session == null);
					_model.is_parsing_url = false;
					return;
				}

				_model.screenState = ETModelLocator.MAIN_SCREEN;
				for( var i:int=0; i< _model.viewStateList.length; i++)
				{
					if(_model.viewStateList[i] == _model.browserManager.fragment)
					{						
						if(_model.debug)
							Logger.info('URL Change View state', i, _model.browserManager.fragment);
							
						if(_model.allowedModules)
						{
							if(_model.debug)
								Logger.info('Is module allowed?', _model.allowedModules.getItemIndex(_model.browserManager.fragment));
							
							// if the user is attempting to access a module that is not in their config
							// return them to the overview
							if(_model.allowedModules.getItemIndex(_model.browserManager.fragment) == -1)
							{
								_model.mainViewState = 0;
								_model.browserManager.setFragment(_model.viewStateList[0]);
								_model.browserManager.setTitle(_model.appName + ' - ' + _model.viewStateNames[0]);
								_model.is_parsing_url = false;
								return;
							}
						}

						_model.mainViewState = i;
						_model.browserManager.setFragment(_model.viewStateList[i]);
						_model.browserManager.setTitle(_model.appName + ' - ' + _model.viewStateNames[i]);	
					}
				}
			}
			_model.is_parsing_url = false;
		}
		
	}
}