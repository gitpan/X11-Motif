
#ifndef _STACK_H
#define _STACK_H

#include <X11/Constraint.h>

#if defined(__cplusplus)
extern "C" {
#endif

/* Reference to the class record pointer */

extern WidgetClass stackWidgetClass;

/* Resource definitions */

extern int StackChildWidgetOrder(Widget child);
extern int StackNumChildren(Widget stack);
extern void StackNextWidget(Widget stack);
extern void StackPreviousWidget(Widget stack);
extern void StackGotoWidget(Widget stack, int child);
extern void StackSetActiveChild(Widget w, int i);
extern int StackGetActiveChild(Widget w);

#define XtNoutsideMargin	"outsideMargin"
#define XtCOutsideMargin	"OutsideMargin"
#define XtNlayerName		"layerName"
#define XtCLayerName		"LayerName"
#define XtNlayerActive		"layerActive"
#define XtCLayerActive		"LayerActive"

#define XtNnowDisplayedCallback	"nowDisplayedCallback"
#define XtNnowHiddenCallback	"nowHiddenCallback"

#if defined(__cplusplus)
};
#endif

#endif /* _STACK_H */
