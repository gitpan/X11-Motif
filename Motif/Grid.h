
#ifndef GRID_H
#define GRID_H

#ifdef __cplusplus
extern "C" {
#endif

/* Reference to the class record pointer */

extern WidgetClass gridWidgetClass;

/* Resource definitions */

#define XtNrows			"rows"
#define XtCRows			"Rows"
#define XtNelementHeight	"elementHeight"
#define XtCElementHeight	"ElementHeight"
#define XtNminElementHeight	"minElementHeight"
#define XtCMinElementHeight	"MinElementHeight"
#define XtNmaxElementHeight	"maxElementHeight"
#define XtCMaxElementHeight	"MaxElementHeight"
#define XtNcolorAltRows		"colorAltRows"
#define XtCColorAltRows		"ColorAltRows"
#define XtNfirstColoredRow	"firstColoredRow"
#define XtCFirstColoredRow	"FirstColoredRow"
#define XtNaltBackground	"altBackground"
#define XtCAltBackground	"AltBackground"

/* Custom type definitions */

typedef enum GridColumnAttributesEnum
{
    GridEnd = 0, GridBackground, GridForeground, GridWidth, GridSelection,
    GridData, GridCallExpose, GridCallSelect, GridCallEvent, GridDivideHorizontal,
    GridDivideVertical, GridHeight, GridRows, GridOrder, GridFont, GridDisplayed
} GridColumnAttributes;

typedef enum GridSelectionDisplayEnum { GridInverse, GridGrayed, GridBoxed } GridSelectionDisplay;

typedef void (*GridExposeCallback)(Widget, GC, XFontStruct *, XRectangle *,
				   void *column_data, int row);

typedef void (*GridSelectCallback)(Widget, GC, XFontStruct *, XRectangle *, XEvent *,
				   void *column_data, int row);

typedef void (*GridEventCallback)(Widget, GC, XFontStruct *, XRectangle *, XEvent *,
				  void *column_data, void *call_data, int row);

typedef struct GridColumnStruct
{
    Boolean displayed;				/* displaying this column? */
    XtPointer data;				/* store column data (possibly a C++ object) */
    Dimension horizontalLineHeight;		/* row divider line width (0 = no divider) */
    Dimension verticalLineWidth;		/* column divider line width  (0 = no divider) */
    Dimension elementWidth;			/* width (in pixels) of the column */
    GridSelectionDisplay selectionDisplay;	/* how to display any selection */
    Pixel foreground;				/* default foreground for column */
    Pixel background;				/* column background overlays row background */
    XFontStruct *font;				/* default font for column */
    GridExposeCallback doExpose;		/* user's column (cell) expose handler */
    GridSelectCallback doSelect;		/* user's column (multi-cell) selection handler */
    GridEventCallback doEvent;			/* user's column (cell) event handler */
    void *doEventCallData;			/* extra user data to pass to event handler */
    struct GridElementStruct *selection;	/* current selection on THIS column */
    int gridRows;				/* number of rows in this column */

    struct GridColumnStruct *next;		/* list of columns is tracked by grid widget */
}
GridColumn;

typedef struct GridElementStruct
{
    GridColumn *column;				/* column element belongs to */
    unsigned int row;				/* this row id */
    struct GridElementStruct *through;		/* selection is from this element through ... */
    struct GridElementStruct *next;		/* selection continues at next element */
}
GridElement;

/* Custom method declarations */

extern Boolean GridInsertColumn(Widget, int, void *, ...);
extern Boolean GridDisplayColumn(Widget, int, Boolean);
extern void GridChangeColumn(Widget w, int col, ...);

extern void GridShouldUpdate(Widget, Boolean);
extern GC GridGetGC(Widget);

extern int GridColNumber(Widget w, int xpos);
extern int GridColOffset(Widget w, int col, GridColumn **ret_column);
extern int GridGetCurrentRow(Widget w);
extern int GridGetElementHeight(Widget w);
extern int GridRowNumber(Widget w, int ypos);
extern int GridRowOffset(Widget w, int row);

extern void GridRedisplayElement(Widget w, int row, int col);
extern void GridVerticalScrollTo(Widget w, int row);
extern void GridScrollHandler(Widget w, XEvent *event);

extern GridElement *GridGetSelection();
extern Boolean GridSetSelection();

#ifdef __cplusplus
};
#endif

#endif
