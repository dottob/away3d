﻿package away3d.core.base
			if (_geometryDirty || !hasEventListener(GeometryEvent.GEOMETRY_UPDATED))
			addEventListener(GeometryEvent.GEOMETRY_UPDATED, listener, false, 0, true);