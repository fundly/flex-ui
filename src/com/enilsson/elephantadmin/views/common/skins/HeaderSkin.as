package com.enilsson.elephantadmin.views.common.skins
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;
	import mx.utils.GraphicsUtil;

	public class HeaderSkin extends ProgrammaticSkin
	{
		override protected function updateDisplayList(w:Number, h:Number) : void
		{
			var g : Graphics = graphics;
			var colors : Array 	= getStyle("colors");
			var cornerRadius : Number = getStyle("cornerRadius");
			var matrix : Matrix = new Matrix();
			
			matrix.createGradientBox(w, h, Math.PI/2 )
			colors			= colors ? colors : [0, 0];
			cornerRadius	= !isNaN(cornerRadius) ? cornerRadius : 0;
			
			g.clear();
			g.lineStyle(0, 0, 0);
			
			g.beginGradientFill ( GradientType.LINEAR, colors, [1, 1], [0, 255], matrix );			
			
			GraphicsUtil.drawRoundRectComplex( g, 0, 0, w, h, cornerRadius, cornerRadius, 0, 0 );
			
			g.endFill();
		}
	}
}