// Deepnight implementation
class Bresenham
{
	static inline function getLine(x0:Int, y0:Int, x1:Int, y1:Int): Array<{x:Int, y:Int}>
	{
		var pts = [];
		var swapXY = fastAbs(y1 - y0) > fastAbs(x1 - x0);
		var tmp:Int;

		if(swapXY)
		{
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		if (x0 > x1)
		{
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}

		var deltax = x1 - x0;
		var deltay = fastFloor(fastAbs(y1 - y0));
		var error = fastFloor(deltax / 2);
		var y = y0;
		var ystep = if (y0 < y1) 1 else -1;

		if(swapXY)
			for(x in x0...x1+1)
			{
				pts.push({x:y, y:x});
				error -= deltay;
				if(error < 0)
				{
					y = y + ystep;
					error = error + deltax;
				}
			}
		else
			for(x in x0...x1+1)
			{
				pts.push({x:x, y:y});
				error -= deltay;
				if(error < 0)
				{
					y = y + ystep;
					error = error + deltax;
				}
			}

		return pts;
	}

	static inline function fastAbs(v:Int):Int
	{
		return (v ^ (v >> 31)) - (v >> 31);
	}

	static inline function fastFloor(v:Float):Int
	{
		return Std.int(v); // actually it’s more "truncate" than "round to 0"
	}
}