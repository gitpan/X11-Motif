
#include <stdarg.h>
#include <stdlib.h>

#include <X11/IntrinsicP.h>
#include <X11/StringDefs.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>

#include <Xm/Xm.h>
#include <Xm/XmP.h>
#include <Xm/PrimitiveP.h>
#include <Xm/ScrollBar.h>
#include <Xm/ScrolledW.h>

#include "GridP.h"

#define Offset(field)	XtOffsetOf(GridRec, grid.field)

static XtResource resources[] =
{
    { XtNspace, XtCSpace, XtRDimension, sizeof(Dimension),
      Offset(space), XtRImmediate, (XtPointer)2 },

    { XtNrows, XtCRows, XtRInt, sizeof(int),
      Offset(rows), XtRImmediate, (XtPointer)500 },

    { XtNelementHeight, XtCElementHeight, XtRDimension, sizeof(Dimension),
      Offset(elementHeight), XtRImmediate, (XtPointer)20 },

    { XtNborderWidth, XtCBorderWidth, XtRDimension, sizeof(Dimension),
      XtOffsetOf(GridRec, core.border_width), XtRImmediate, (XtPointer)0 },

    { XtNforeground, XtCForeground, XtRPixel, sizeof(Pixel),
      Offset(foreground), XtRString, "XtDefaultForeground" },

    { XtNfont, XtCFont, XtRFontStruct, sizeof(XFontStruct *),
      Offset(font), XtRString, "XtDefaultFont" },

    { XtNcolorAltRows, XtCColorAltRows, XtRInt, sizeof(int),
      Offset(colorAltRows), XtRImmediate, (XtPointer)0 },

    { XtNfirstColoredRow, XtCFirstColoredRow, XtRInt, sizeof(int),
      Offset(firstColoredRow), XtRImmediate, (XtPointer)0 },

    { XtNaltBackground, XtCAltBackground, XtRPixel, sizeof(Pixel),
      Offset(altBackground), XtRString, "XtDefaultBackground" }
};

#undef Offset

extern WidgetClass gridWidgetClass;

static void actionActivate(Widget w, XEvent *event, String *params, Cardinal *num_params)
{
    GridWidget self = (GridWidget)w;
    GridColumn *column = self->grid.column;
    XRectangle area;
    int eventX, eventY;
    int row;

    switch (event->type)
    {
	case KeyPress:
	case KeyRelease:
	    eventX = event->xkey.x;
	    eventY = event->xkey.y;
	    break;

	case ButtonPress:
	case ButtonRelease:
	    eventX = event->xbutton.x;
	    eventY = event->xbutton.y;
	    break;

	case MotionNotify:
	    eventX = event->xmotion.x;
	    eventY = event->xmotion.y;
	    break;

	default:
	    eventX = eventY = 0;
	    break;
    }

    row = self->grid.topRow + eventY / self->grid.elementHeight;
    eventX += self->grid.leftMargin;

    for (area.x = 0; column != 0; column = column->next)
    {
	if (column->displayed)
	{
	    if (area.x + column->elementWidth < eventX)
	    {
		area.x += column->elementWidth;
	    }
	    else
	    {
		break;
	    }
	}
    }

    if ((column != 0) && (column->doEvent != 0))
    {
	XSetBackground(XtDisplay(self), self->grid.defaultGC, column->background);
	XSetForeground(XtDisplay(self), self->grid.defaultGC, column->foreground);
	XSetFont(XtDisplay(self), self->grid.defaultGC, column->font->fid);

	area.x -= self->grid.leftMargin;
	area.y = (row - self->grid.topRow) * self->grid.elementHeight;
	area.width = column->elementWidth;
	area.height = self->grid.elementHeight;

	column->doEvent((Widget)self, self->grid.defaultGC, column->font, &area, event,
			column->data, column->doEventCallData, row);
    }
}

static XtActionsRec actionList[] =
{
    { "activate", actionActivate }
};

/*
** Simply call activate() on any event that the user *might* be
** interested in -- it's up to the user to figure out which events
** she really wants to handle (usually via a switch statement).
*/

static char defaultTranslations[] =
"<BtnDown>: activate()	\n\
<BtnUp>: activate()	\n\
<BtnMotion>: activate()	\n\
<KeyDown>: activate()	\n\
<KeyUp>: activate()";

static void setGridSize(GridWidget self)
{
    if (self->grid.rows < 1) self->grid.rows = 1;
    if (self->grid.elementHeight < 1) self->grid.elementHeight = 1;

    if (self->core.width == 0) self->core.width = 100; /* default: 100 pixels */
    self->grid.desiredWidth = self->core.width;

    if (self->core.height == 0) self->core.height = self->grid.elementHeight * 5; /* default: 5 rows */
}

static void getWidthAndHeight(GridColumn *column, int *width, int *height)
{
    int w = 0, h = 0;

    while (column != 0)
    {
	if (column->displayed)
	{
	    w += column->elementWidth;
	    if (column->gridRows > h) h = column->gridRows;
	}

	column = column->next;
    }

    *width = w;
    *height = h;
}

static void Redisplay(GridWidget self, XEvent *event, Region region)
{
    Display *display = XtDisplay(self);
    GridColumn *column = self->grid.column;
    GridColumn *previous = 0;
    XRectangle area;
    int row, startRow, stopRow;
    Dimension startX, stopX, startY, stopY;
    int eventX, eventY, eventWidth, eventHeight;

    if (event == 0)	/* convention for redisplaying everything */
    {
	eventX = 0;
	eventY = 0;
	eventWidth = self->core.width;
	eventHeight = self->core.height;
    }
    else
    {
	eventX = event->xexpose.x;
	eventY = event->xexpose.y;
	eventWidth = event->xexpose.width;
	eventHeight = event->xexpose.height;
    }

    startRow = self->grid.topRow + eventY / self->grid.elementHeight;
    startY = (startRow - self->grid.topRow) * self->grid.elementHeight;

    stopRow = self->grid.topRow + (eventY + eventHeight) / self->grid.elementHeight + 1;
    stopY = (stopRow - self->grid.topRow) * self->grid.elementHeight;

    startX = eventX + self->grid.leftMargin;

    for (area.x = 0; column != 0; column = column->next)
    {
	if (column->displayed)
	{
	    if (area.x + column->elementWidth < startX)
	    {
		area.x += column->elementWidth;
	    }
	    else
	    {
		break;
	    }
	}
    }

    if (column != 0)
    {
	/*
	** X Windows caches display attributes for us, so not tracking the
	** GC between redisplays doesn't hurt us.  Simply set up the GC to
	** be what we need.  Later on, we check if the values change from
	** column to column to avoid the function call overhead (and our
	** version of checking GC values is much more efficient than the more
	** general Xlib version.)
	*/

	XSetBackground(display, self->grid.defaultGC, column->background);
	XSetForeground(display, self->grid.defaultGC, column->foreground);
	XSetFont(display, self->grid.defaultGC, column->font->fid);

	stopX = eventX + eventWidth;

	area.x -= self->grid.leftMargin;
	area.y = startY;
	area.width = column->elementWidth;
	area.height = self->grid.elementHeight;

	if (self->grid.colorAltRows > 0)
	{
	    XSetForeground(display, self->grid.shadingGC, self->grid.altBackground);

	    for (row = startRow; row < stopRow; ++row)
	    {
		if ((row >= self->grid.firstColoredRow) &&
		    ((row - self->grid.firstColoredRow) / self->grid.colorAltRows % 2 == 0))
		{
		    XFillRectangle(XtDisplay(self), XtWindow(self), self->grid.shadingGC,
				   eventX, area.y, eventWidth, self->grid.elementHeight);
		}

		area.y += area.height;
	    }
	}

	for (;;)
	{
	    XGCValues gcValues;

	    area.y = startY;
	    area.width = column->elementWidth;

	    if (column->background != self->core.background_pixel)
	    {
		XSetForeground(display, self->grid.shadingGC, column->background);
		XFillRectangle(XtDisplay(self), XtWindow(self), self->grid.shadingGC,
			       area.x, area.y, column->elementWidth, stopY - startY);
	    }

	    if (column->doExpose != 0)
	    {
		for (row = startRow; row < stopRow; ++row)
		{
		    column->doExpose((Widget)self, self->grid.defaultGC, column->font, &area,
				     column->data, row);

		    area.y += area.height;
		}
	    }

	    if (column->horizontalLineHeight)
	    {
		int y = startY;

		gcValues.line_width = column->horizontalLineHeight - 1;
		XChangeGC(XtDisplay(self), self->grid.defaultGC, GCLineWidth, &gcValues);

		for (row = startRow; row < stopRow; ++row)
		{
		    XDrawLine(XtDisplay(self), XtWindow(self), self->grid.defaultGC,
			      area.x, y, area.x + area.width - 1, y);

		    y += area.height;
		}
	    }

	    if (column->verticalLineWidth)
	    {
		gcValues.line_width = column->verticalLineWidth - 1;
		XChangeGC(XtDisplay(self), self->grid.defaultGC, GCLineWidth, &gcValues);

		XDrawLine(XtDisplay(self), XtWindow(self), self->grid.defaultGC,
			  area.x + area.width - 1, startY,
			  area.x + area.width - 1, stopY);
	    }

	    if ((area.x += area.width) > stopX) break;

	    previous = column;
	    do { column = column->next; } while (column && !column->displayed);

	    if (column == 0) break;

	    if (column->background != previous->background)
	    {
		XSetBackground(display, self->grid.defaultGC, column->background);
	    }

	    if (column->foreground != previous->foreground)
	    {
		XSetForeground(display, self->grid.defaultGC, column->foreground);
	    }

	    if (column->font->fid != previous->font->fid)
	    {
		XSetFont(display, self->grid.defaultGC, column->font->fid);
	    }
	}
    }
}

static void updateGenericScrollSize(GridWidget self, Widget scrollbar, int *top_pos,
				    int slider_size, int maximum)
{
    int old_maximum;
    int current_pos;

    /* Get the current state of the scrollbar.  This will be used
       in the event that the window size has changed and the scrollbar
       relationship needs to be recomputed. */

    XtVaGetValues(scrollbar,
		  XmNvalue, &current_pos,
		  XmNmaximum, &old_maximum,
		  0);

    /* If the user didn't give a maximum, just use the
       old value.  This simplifies other parts of the code. */

    if (maximum <= 0) maximum = old_maximum;

    /* If the slider size is less than 1, then Motif will complain.
       It is legitimate to have a slider size of 0, because that's
       the case when the scrolled window is zero height.  But we
       have to live Motif... (basically, Motif scrollbars are not
       functional when the window size drops to a fraction of a row.) */

    if (slider_size <= 0) slider_size = 1;

    /* If the new slider size would make some rows past the
       maximum visible, the current position has to be pushed back
       a bit.  If not, the scrollbar will display a warning. */

    if (slider_size + current_pos > maximum)
    {
	/* If the current position has become negative, then the
	   slider size is too large (i.e. the window has grown
	   or columns have been shrunk).  Set the slider to be as
	   large as the entire data set because it all fits into
	   the window.  There may still be rows visible that are
	   past the maximum, but at least the scrollbar won't
	   complain about them. */

	if ((current_pos = maximum - slider_size) < 0)
	{
	    current_pos = 0;
	    slider_size = maximum;
	    *top_pos = 0;

	    /* If this routine was called in response to a resize,
	       then safeToUpdate is false -- the resize will take
	       care of the redisplay. */

	    if (XtIsRealized(self) && self->grid.safeToUpdate)
	    {
		XClearWindow(XtDisplay(self), XtWindow(self));
		Redisplay(self, 0, 0);
	    }
	}
    }

    /* Finally, update the scrollbar with the new values. */

    XtVaSetValues(scrollbar,
		  XmNvalue, current_pos,
		  XmNsliderSize, slider_size,
		  XmNpageIncrement, (slider_size - 1 > 0) ? slider_size - 1 : 1,
		  XmNmaximum, maximum,
		  0);
}

static void updateVScrollSize(GridWidget self, int slider_size, int maximum)
{
    updateGenericScrollSize(self, self->grid.vScroll, &(self->grid.topRow),
			    slider_size, maximum);
}

static void updateHScrollSize(GridWidget self, int slider_size, int maximum)
{
    updateGenericScrollSize(self, self->grid.hScroll, &(self->grid.leftMargin),
			    slider_size, maximum);
}

static void Realize(Widget w, XtValueMask *value_mask, XSetWindowAttributes *attributes)
{
    GridWidget self = (GridWidget)w;
    int width, maxRows;

    gridWidgetClass->core_class.superclass->core_class.realize(w, value_mask, attributes);

    self->grid.defaultGC = XCreateGC(XtDisplay(w), XtWindow(w), 0, 0);
    self->grid.shadingGC = XCreateGC(XtDisplay(w), XtWindow(w), 0, 0);

    getWidthAndHeight(self->grid.column, &width, &maxRows);

    if (self->grid.hScroll != 0)
    {
	updateHScrollSize(self, self->core.width, width);
    }

    if (self->grid.vScroll != 0)
    {
	updateVScrollSize(self, self->core.height / self->grid.elementHeight, maxRows);
    }
}

static Boolean SetValues(Widget old_widget, Widget req_widget, Widget new_widget,
			 ArgList args, Cardinal *num_args)
{
    GridWidget new_grid = (GridWidget)new_widget;
    int width, maxRows;

    setGridSize(new_grid);

    if ((old_widget->core.width != new_grid->core.width) &&
	(new_grid->grid.hScroll != 0))
    {
	getWidthAndHeight(new_grid->grid.column, &width, &maxRows);
	updateHScrollSize(new_grid, new_grid->core.width, width);
    }
    else
    {
	width = 0;
    }

    if ((old_widget->core.height != new_grid->core.height) &&
	(new_grid->grid.vScroll != 0))
    {
	if (width != 0) getWidthAndHeight(new_grid->grid.column, &width, &maxRows);
	updateVScrollSize(new_grid, new_grid->core.height / new_grid->grid.elementHeight, maxRows);
    }

    return(True);
}

static void Destroy(Widget w)
{
    GridWidget self = (GridWidget)w;

    if (self->grid.defaultGC) XFreeGC(XtDisplay(self), self->grid.defaultGC);
    if (self->grid.shadingGC) XFreeGC(XtDisplay(self), self->grid.shadingGC);
}

static void Resize(Widget w)
{
    GridWidget self = (GridWidget)w;

    if (XtIsRealized(self))
    {
	int save_safeToUpdate = self->grid.safeToUpdate;

	self->grid.safeToUpdate = 0;

	if (self->grid.hScroll != 0)
	{
	    updateHScrollSize(self, self->core.width, 0);
	}

	if (self->grid.vScroll != 0)
	{
	    updateVScrollSize(self, self->core.height / self->grid.elementHeight, 0);
	}

	self->grid.safeToUpdate = save_safeToUpdate;

	XClearWindow(XtDisplay(self), XtWindow(self));
	Redisplay(self, 0, 0);
    }
}

static void Highlight(Widget w)
{
}

static void UnHighlight(Widget w)
{
}

static void resetColumnHeight(GridWidget self)
{
    GridColumn *column = self->grid.column;

    self->grid.rows = 0;

    while (column)
    {
	if (column->gridRows > self->grid.rows) self->grid.rows = column->gridRows;
	column = column->next;
    }
}

static void fillInColumnData(GridColumn *column, GridWidget self, va_list argv)
{
    GridColumnAttributes option;
    Boolean done = False;

    do
    {
	option = va_arg(argv, GridColumnAttributes);

	switch (option)
	{
	    case GridEnd:
		done = True;
		break;

	    case GridBackground:
		column->background = va_arg(argv, Pixel);
		break;

	    case GridForeground:
		column->foreground = va_arg(argv, Pixel);
		break;

	    case GridFont:
		column->font = va_arg(argv, XFontStruct *);
		break;

	    case GridWidth:
		column->elementWidth = (Dimension)va_arg(argv, int);
		break;

	    case GridSelection:
		column->selectionDisplay = va_arg(argv, GridSelectionDisplay);
		break;

	    case GridData:
		column->data = va_arg(argv, void *);
		break;

	    case GridCallExpose:
		column->doExpose = va_arg(argv, GridExposeCallback);
		break;

	    case GridCallSelect:
		column->doSelect = va_arg(argv, GridSelectCallback);
		break;

	    case GridCallEvent:
		column->doEvent = va_arg(argv, GridEventCallback);
		column->doEventCallData = va_arg(argv, void *);
		break;

	    case GridDisplayed:
		column->displayed = va_arg(argv, int);
		break;

	    case GridDivideHorizontal:
		column->horizontalLineHeight = va_arg(argv, int);
		break;

	    case GridDivideVertical:
		column->verticalLineWidth = va_arg(argv, int);
		break;

	    case GridHeight:
		break;

	    case GridRows:
		column->gridRows = va_arg(argv, int);
		if (column->gridRows < 0)
		{
		    column->gridRows = 0;
		}
		resetColumnHeight(self);
		break;

	    case GridOrder:
		break;
	}
    }
    while (!done);
}

static void resetPresentation(GridWidget self)
{
    int width, maxRows, heightInRows;

    getWidthAndHeight(self->grid.column, &width, &maxRows);

    if (width > 0)
    {
	self->grid.desiredWidth = width;

	/*
	** while adding columns before realization, automatically update
	** the widgets core width.  after realization, only the user can
	** change the core width - this will just update the scrollbars.
	*/

	if (self->grid.hScroll != 0)
	{
	    updateHScrollSize(self, self->core.width, width);
	}

	if (self->grid.vScroll != 0)
	{
	    updateVScrollSize(self, self->core.height / self->grid.elementHeight, maxRows);
	}

	if (!XtIsRealized(self))
	{
	    XtVaSetValues((Widget)self, XtNwidth, width, 0);
	}
    }

    heightInRows = self->core.height / self->grid.elementHeight - 1;

    if (self->grid.topRow > self->grid.rows - heightInRows)
    {
	self->grid.topRow = self->grid.rows - heightInRows;

	if (self->grid.topRow < 0)
	{
	    self->grid.topRow = 0;
	}

	if (XtIsRealized(self) && self->grid.safeToUpdate)
	{
	    XClearWindow(XtDisplay(self), XtWindow(self));
	    Redisplay(self, 0, 0);
	}
    }
}

static void RedisplayArea(GridWidget grid, Position x, Position y, Dimension w, Dimension h)
{
    XEvent event;

    event.xexpose.x = x;
    event.xexpose.y = y;
    event.xexpose.width = w;
    event.xexpose.height = h;

    XClearArea(XtDisplay(grid), XtWindow(grid), x, y, w, h, False);
    Redisplay(grid, &event, 0);
}

static void doHorzScrolling(Widget w, XtPointer clientData, XtPointer callData)
{
    GridWidget grid = (GridWidget)clientData;
    XmScrollBarCallbackStruct *status = (XmScrollBarCallbackStruct *)callData;
    XEvent event;

    XSync(XtDisplay(grid), False);
    while (XCheckWindowEvent(XtDisplay(grid), XtWindow(grid), ExposureMask, &event))
    {
	XtDispatchEvent(&event);
    }

    if (status->value != grid->grid.leftMargin)
    {
	int left_margin = grid->grid.leftMargin;
	int right_margin = left_margin + grid->core.width;

	int new_left_margin = status->value;
	int new_right_margin = new_left_margin + grid->core.width;

	grid->grid.leftMargin = new_left_margin;

	if (left_margin < new_left_margin && new_left_margin < right_margin)
	{
	    int redraw_width = new_left_margin - left_margin;
	    int copy_width = right_margin - new_left_margin;

	    XCopyArea(XtDisplay(grid), XtWindow(grid), XtWindow(grid), grid->grid.defaultGC,
		      redraw_width, 0,
		      copy_width, grid->core.height,
		      0, 0);

	    RedisplayArea(grid, copy_width, 0, redraw_width, grid->core.height);
	}
	else if (left_margin < new_right_margin && new_right_margin < right_margin)
	{
	    int redraw_width = left_margin - new_left_margin;
	    int copy_width = new_right_margin - left_margin;

	    XCopyArea(XtDisplay(grid), XtWindow(grid), XtWindow(grid), grid->grid.defaultGC,
		      0, 0,
		      copy_width, grid->core.height,
		      redraw_width, 0);

	    RedisplayArea(grid, 0, 0, redraw_width, grid->core.height);
	}
	else
	{
	    XClearWindow(XtDisplay(grid), XtWindow(grid));
	    Redisplay(grid, 0, 0);
	}
    }
}

static void doVertScrolling(Widget w, XtPointer clientData, XtPointer callData)
{
    GridWidget grid = (GridWidget)clientData;
    XmScrollBarCallbackStruct *status = (XmScrollBarCallbackStruct *)callData;
    XEvent event;

    XSync(XtDisplay(grid), False);
    while (XCheckWindowEvent(XtDisplay(grid), XtWindow(grid), ExposureMask, &event))
    {
	XtDispatchEvent(&event);
    }

    if (status->value != grid->grid.topRow)
    {
	unsigned int rows_displayed = grid->core.height / grid->grid.elementHeight;

	unsigned int top_row = grid->grid.topRow;
	unsigned int last_row = top_row + rows_displayed;

	unsigned int new_top_row = status->value;
	unsigned int new_last_row = new_top_row + rows_displayed;

	grid->grid.topRow = new_top_row;

	if (top_row < new_top_row && new_top_row < last_row)
	{
	    int source_y = (new_top_row - top_row) * grid->grid.elementHeight;
	    int copy_height = (last_row - new_top_row) * grid->grid.elementHeight;

	    XCopyArea(XtDisplay(grid), XtWindow(grid), XtWindow(grid), grid->grid.defaultGC,
		      0, source_y,
		      grid->core.width, copy_height,
		      0, 0);

	    RedisplayArea(grid, 0, copy_height, grid->core.width, grid->core.height - copy_height);
	}
	else if (top_row < new_last_row && new_last_row < last_row)
	{
	    int dest_y = (top_row - new_top_row) * grid->grid.elementHeight;

	    XCopyArea(XtDisplay(grid), XtWindow(grid), XtWindow(grid), grid->grid.defaultGC,
		      0, 0,
		      grid->core.width, grid->core.height - dest_y,
		      0, dest_y);

	    RedisplayArea(grid, 0, 0, grid->core.width, dest_y - 1);
	}
	else
	{
	    XClearWindow(XtDisplay(grid), XtWindow(grid));
	    Redisplay(grid, 0, 0);
	}
    }
}

static void handleGraphicsExpose(Widget w, XtPointer client_data, XEvent *event, Boolean *continue_dispatch)
{
    if (event->type == GraphicsExpose)
    {
	Redisplay((GridWidget)w, event, 0);
    }
}

static void Initialize(Widget req_widget, Widget new_widget, ArgList args, Cardinal *num_args)
{
    GridWidget self = (GridWidget)new_widget;
    Widget parent = XtParent(self);

    setGridSize(self);

    self->grid.safeToUpdate = True;
    self->grid.topRow = 0;
    self->grid.leftMargin = 0;
    self->grid.column = 0;
    self->grid.defaultGC = 0;
    self->grid.hScroll = 0;
    self->grid.vScroll = 0;

    XtAddEventHandler((Widget)self, NoEventMask, True, handleGraphicsExpose, 0);

    if (parent && XtClass(parent) == xmScrolledWindowWidgetClass)
    {
	self->grid.hScroll = XtVaCreateManagedWidget("hScroll", xmScrollBarWidgetClass, parent,
						     XmNorientation, XmHORIZONTAL,
						     XmNminimum, 0,
						     XmNmaximum, self->core.width,
						     0);

	self->grid.vScroll = XtVaCreateManagedWidget("vScroll", xmScrollBarWidgetClass, parent,
						     XmNorientation, XmVERTICAL,
						     XmNminimum, 0,
						     XmNmaximum, self->grid.rows,
						     0);

	XtAddCallback(self->grid.hScroll, XmNvalueChangedCallback, doHorzScrolling, self);
	XtAddCallback(self->grid.hScroll, XmNdragCallback, doHorzScrolling, self);

	XtAddCallback(self->grid.vScroll, XmNvalueChangedCallback, doVertScrolling, self);
	XtAddCallback(self->grid.vScroll, XmNdragCallback, doVertScrolling, self);

	XmScrolledWindowSetAreas(parent, self->grid.hScroll, self->grid.vScroll, (Widget)self);

	self->primitive.highlight_thickness = 2;
    }
}

/* Class record declaration */

GridClassRec gridClassRec =
{
    /* Core class part */

    {
	/* superclass               */ (WidgetClass)&xmPrimitiveClassRec,
	/* class_name               */ "Grid",
	/* widget_size              */ sizeof(GridRec),
	/* class_initialize         */ 0,
	/* class_part_initialize    */ 0,
	/* class_inited             */ False,
	/* initialize               */ Initialize,
	/* initialize_hook          */ 0,
	/* realize                  */ Realize,
	/* actions                  */ actionList,
	/* num_actions              */ XtNumber(actionList),
	/* resources                */ resources,
	/* num_resources            */ XtNumber(resources),
	/* xrm_class                */ NULLQUARK,
	/* compress_motion          */ True,
	/* compress_exposure        */ XtExposeCompressMultiple,
	/* compress_enterleave      */ True,
	/* visible_interest         */ False,
	/* destroy                  */ Destroy,
	/* resize                   */ Resize,
	/* expose                   */ (XtExposeProc)Redisplay,
	/* set_values               */ SetValues,
	/* set_values_hook          */ 0,
	/* set_values_almost        */ XtInheritSetValuesAlmost,
	/* get_values_hook          */ 0,
	/* accept_focus             */ XtInheritAcceptFocus,
	/* version                  */ XtVersion,
	/* callback offsets         */ 0,
	/* tm_table                 */ defaultTranslations,
	/* query_geometry           */ XtInheritQueryGeometry,
	/* display_accelerator      */ 0,
	/* extension                */ 0
    },

    /* Primitive class part */

    {
	/* border_highlight          */ Highlight,
	/* border_unhighlight        */ UnHighlight,
	/* translations              */ XtInheritTranslations,
	/* arm_and_activate          */ 0,
	/* get_resources       	     */ 0,
	/* num get_resources         */ 0,
	/* extension                 */ 0,
    },

    /* Grid class part */

    {
	/* example so I remember...  */ 0
    }
};

/* Class record pointer */

WidgetClass gridWidgetClass = (WidgetClass)&gridClassRec;

Boolean GridDisplayColumn(Widget w, int order, Boolean displayed)
{
    GridWidget self = (GridWidget)w;
    GridColumn *column = self->grid.column;
    int width, maxRows;

    while ((order > 0) && (column != 0))
    {
	column = column->next;
	--order;
    }

    if (column != 0)
    {
	column->displayed = displayed;
	if (XtIsRealized(w) && self->grid.safeToUpdate)
	{
	    XClearArea(XtDisplay(w), XtWindow(w), 0, 0, 0, 0, True);
	}

	getWidthAndHeight(self->grid.column, &width, &maxRows);

	if (width > 0)
	{
	    self->grid.desiredWidth = width;

	    /*
	    ** while adding columns before realization, automatically update
	    ** the widgets core width.  after realization, only the user can
	    ** change the core width - this will just update the scrollbars.
	    */

	    if (self->grid.hScroll != 0)
	    {
		updateHScrollSize(self, self->core.width, width);
	    }

	    if (self->grid.vScroll != 0)
	    {
		updateVScrollSize(self, self->core.height / self->grid.elementHeight, maxRows);
	    }

	    if (!XtIsRealized(w))
	    {
		XtVaSetValues(w, XtNwidth, width, 0);
	    }
	}
	return(True);
    }

    return(False);
}

Boolean GridInsertColumn(Widget w, int order, void *data, ...)
{
    va_list argv;
    GridWidget self = (GridWidget)w;
    GridColumn *previous = 0;
    GridColumn *column = self->grid.column;

    if (order < 0)
    {
	while (column != 0)
	{
	    previous = column;
	    column = column->next;
	}
    }

    while ((order > 0) && (column != 0))
    {
	previous = column;
	column = column->next;
	--order;
    }

    if (previous == 0)
    {
	column = (GridColumn *)XtMalloc(sizeof(GridColumn));
	column->next = self->grid.column;
	self->grid.column = column;
    }
    else
    {
	previous->next = (GridColumn *)XtMalloc(sizeof(GridColumn));
	previous->next->next = column;
	column = previous->next;
    }

    column->displayed = True;
    column->data = data;
    column->selection = 0;
    column->foreground = self->grid.foreground;
    column->background = self->core.background_pixel;
    column->font = self->grid.font;
    column->elementWidth = 50;
    column->horizontalLineHeight = 0;
    column->verticalLineWidth = 1;
    column->selectionDisplay = GridInverse;
    column->doExpose = 0;
    column->doSelect = 0;
    column->doEvent = 0;
    column->doEventCallData = 0;
    column->gridRows = 0;

    va_start(argv, data);
    fillInColumnData(column, self, argv);
    va_end(argv);

    resetPresentation(self);

    return(True);
}

void GridShouldUpdate(Widget w, Boolean update)
{
    GridWidget grid = (GridWidget)w;

    if (update && !grid->grid.safeToUpdate && XtIsRealized(w))
    {
	XClearArea(XtDisplay(w), XtWindow(w), 0, 0, 0, 0, True);
    }

    grid->grid.safeToUpdate = update;
}

GC GridGetGC(Widget w)
{
    GridWidget grid = (GridWidget)w;

    return(grid->grid.defaultGC);
}

int GridColNumber(Widget w, int xpos)
{
    GridWidget grid = (GridWidget)w;
    GridColumn *column;
    int startX = xpos + grid->grid.leftMargin;
    int left = 0;
    int col = 0;

    for (column = grid->grid.column; column != 0; column = column->next)
    {
	if (column->displayed)
	{
	    if ((left += column->elementWidth) <= startX)
	    {
		col++;
	    }
	    else
	    {
		break;
	    }
	}
    }

    return(col);
}

int GridRowNumber(Widget w, int ypos)
{
    GridWidget grid = (GridWidget)w;
    int row = grid->grid.topRow + (ypos / grid->grid.elementHeight);

    if (row >= grid->grid.rows) row = grid->grid.rows - 1;
    if (row < 0) row = 0;

    return(row);
}

int GridRowOffset(Widget w, int row)
{
    GridWidget grid = (GridWidget)w;

    return(grid->grid.elementHeight * (row - grid->grid.topRow));
}

int GridColOffset(Widget w, int col, GridColumn **ret_column)
{
    GridWidget grid = (GridWidget)w;
    GridColumn *column;
    int left = 0;

    for (column = grid->grid.column; column != 0; column = column->next)
    {
	if (column->displayed)
	{
	    if (col > 0)
	    {
		left += column->elementWidth;
		col--;
	    }
	    else
	    {
		break;
	    }
	}
    }

    if (ret_column) *ret_column = column;

    return(left - grid->grid.leftMargin);
}

void GridRedisplayElement(Widget w, int row, int col)
{
    GridWidget grid = (GridWidget)w;
    GridColumn *column;
    int startX = GridColOffset(w, col, &column);
    int startY = GridRowOffset(w, row);

    if (column && startX < grid->core.width && startY < grid->core.height)
    {
	int stopX = startX + column->elementWidth;
	int stopY = startY + grid->grid.elementHeight;

	if (stopX > 0 && stopY > 0)
	{
	    int sizeX, sizeY;

	    if (startX < 0) startX = 0;
	    if (startY < 0) startY = 0;

	    if (stopX > grid->core.width) stopX = grid->core.width;
	    if (stopY > grid->core.height) stopY = grid->core.height;

	    sizeX = stopX - startX;
	    sizeY = stopY - startY;

	    if (sizeX > 0 && sizeY > 0)
	    {
		RedisplayArea(grid, startX, startY, sizeX, sizeY);
	    }
	}
    }
}

int GridGetElementHeight(Widget w)
{
    GridWidget grid = (GridWidget)w;

    return(grid->grid.elementHeight);
}

int GridGetCurrentRow(Widget w)
{
    GridWidget grid = (GridWidget)w;

    return(grid->grid.topRow);
}

void GridChangeColumn(Widget w, int order, ...)
{
    va_list argv;
    GridWidget grid = (GridWidget)w;
    GridColumn *column;

    GridColOffset(w, order, &column);

    va_start(argv, order);
    fillInColumnData(column, grid, argv);
    va_end(argv);

    resetPresentation(grid);
}

void GridVerticalScrollTo(Widget w, int row)
{
    XmScrollBarCallbackStruct vscrollto;
    GridWidget grid = (GridWidget)w;
    int rows_displayed = grid->core.height / grid->grid.elementHeight;

    if (row + rows_displayed > grid->grid.rows) row = grid->grid.rows - rows_displayed;
    if (row < 0) row = 0;

    vscrollto.value = row;
    vscrollto.reason = 0;
    vscrollto.event = 0;
    vscrollto.pixel = 0;

    doVertScrolling(0, (XtPointer)w, (XtPointer)&vscrollto);

    if (grid->grid.vScroll)
    {
	XtVaSetValues(grid->grid.vScroll, XmNvalue, row, 0);
    }
}

void GridScrollHandler(Widget w, XEvent *event)
{
    GridWidget grid = (GridWidget)w;

    if (event->type == KeyRelease)
    {
	int top = grid->grid.topRow;
	unsigned int rows_displayed = grid->core.height / grid->grid.elementHeight;
	unsigned int k = XKeycodeToKeysym(XtDisplay(grid), event->xkey.keycode, 0);

	switch (k)
	{
	    case XK_Up:
		top = top - 1;
		break;

	    case XK_Page_Up:
		top = top - rows_displayed + 1;
		break;

	    case XK_Down:
		top = top + 1;
		break;

	    case XK_Page_Down:
		top = top + rows_displayed - 1;
		break;
	}

	GridVerticalScrollTo((Widget)grid, top);
    }
}
