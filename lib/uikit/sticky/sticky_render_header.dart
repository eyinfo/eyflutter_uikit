// Copyright 2018 Simon Lightfoot. All rights reserved.
// Use of this source code is governed by a the MIT license that can be
// found in the LICENSE file.

import 'dart:math' show min, max;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Called every layout to provide the amount of stickyness a header is in.
/// This lets the widgets animate their content and provide feedback.
///
typedef void StickyRenderHeaderCallback(double stuckAmount);

/// RenderObject for StickyHeader widget.
///
/// Monitors given [Scrollable] and adjusts its layout based on its offset to
/// the scrollable's [RenderObject]. The header will be placed above content
/// unless overlapHeaders is set to true. The supplied callback will be used
/// to report the
///
class StickyRenderHeader extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  StickyRenderHeaderCallback? _callback;
  ScrollableState? _scrollable;
  bool _overlapHeaders;

  StickyRenderHeader({
    required ScrollableState scrollable,
    StickyRenderHeaderCallback? callback,
    bool overlapHeaders: false,
    RenderBox? header,
    RenderBox? content,
  })  : _scrollable = scrollable,
        _callback = callback,
        _overlapHeaders = overlapHeaders {
    if (content != null) add(content);
    if (header != null) add(header);
  }

  set scrollable(ScrollableState? newValue) {
    assert(newValue != null);
    if (_scrollable == newValue) {
      return;
    }
    final ScrollableState? oldValue = _scrollable;
    _scrollable = newValue;
    markNeedsLayout();
    if (attached) {
      oldValue?.position.removeListener(markNeedsLayout);
      newValue?.position.addListener(markNeedsLayout);
    }
  }

  set callback(StickyRenderHeaderCallback? newValue) {
    if (_callback == newValue) {
      return;
    }
    _callback = newValue;
    markNeedsLayout();
  }

  set overlapHeaders(bool newValue) {
    if (_overlapHeaders == newValue) {
      return;
    }
    _overlapHeaders = newValue;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable?.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable?.position.removeListener(markNeedsLayout);
    super.detach();
  }

  // short-hand to access the child RenderObjects
  RenderBox? get _headerBox => lastChild;

  RenderBox? get _contentBox => firstChild;

  @override
  void performLayout() {
    // ensure we have header and content boxes
    assert(childCount == 2);
    // layout both header and content widget
    final childConstraints = constraints.loosen();
    _headerBox?.layout(childConstraints, parentUsesSize: true);
    _contentBox?.layout(childConstraints, parentUsesSize: true);
    final headerHeight = _headerBox?.size.height ?? 0;
    final contentHeight = _contentBox?.size.height ?? 0;
    // determine size of ourselves based on content widget
    final width = max(constraints.minWidth, _contentBox?.size.width ?? 0);
    final height = max(constraints.minHeight, _overlapHeaders ? contentHeight : headerHeight + contentHeight);
    size = new Size(width, height);
    assert(size.width == constraints.constrainWidth(width));
    assert(size.height == constraints.constrainHeight(height));
    assert(size.isFinite);
    // place content underneath header
    final contentParentData = _contentBox?.parentData as MultiChildLayoutParentData;
    contentParentData.offset = new Offset(0.0, _overlapHeaders ? 0.0 : headerHeight);
    // determine by how much the header should be stuck to the top
    final double stuckOffset = determineStuckOffset();
    // place header over content relative to scroll offset
    final double maxOffset = height - headerHeight;
    final headerParentData = _headerBox?.parentData as MultiChildLayoutParentData;
    headerParentData.offset = new Offset(0.0, max(0.0, min(-stuckOffset, maxOffset)));
    // report to widget how much the header is stuck.
    if (_callback != null) {
      final stuckAmount = max(min(headerHeight, stuckOffset), -headerHeight) / headerHeight;
      _callback!(stuckAmount);
    }
  }

  double determineStuckOffset() {
    final scrollBox = _scrollable?.context.findRenderObject();
    if (scrollBox?.attached ?? false) {
      try {
        return localToGlobal(Offset.zero, ancestor: scrollBox).dy;
      } catch (e) {
        // ignore and fall-through and return 0.0
      }
    }
    return 0.0;
  }

  @override
  void setupParentData(RenderObject child) {
    super.setupParentData(child);
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = new MultiChildLayoutParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _contentBox?.getMinIntrinsicWidth(height) ?? 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _contentBox?.getMaxIntrinsicWidth(height) ?? 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _overlapHeaders
        ? (_contentBox?.getMinIntrinsicHeight(width) ?? 0)
        : ((_headerBox?.getMinIntrinsicHeight(width) ?? 0) + (_contentBox?.getMinIntrinsicHeight(width) ?? 0));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _overlapHeaders
        ? (_contentBox?.getMaxIntrinsicHeight(width) ?? 0)
        : ((_headerBox?.getMaxIntrinsicHeight(width) ?? 0) + (_contentBox?.getMaxIntrinsicHeight(width) ?? 0));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline) ?? 0;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
