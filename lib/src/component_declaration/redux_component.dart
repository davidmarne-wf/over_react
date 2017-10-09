// Copyright 2016 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library over_react.component_declaration.redux_component;

import 'dart:async';

import 'package:built_redux/built_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';
import 'package:over_react/over_react.dart';

/// Builds on top of [UiProps], adding typed props for [Store] in order to integrate with `built_redux`.
///
/// Use with the over_react transformer via the `@Props()` ([annotations.Props]) annotation.
abstract class ReduxUiProps<V extends Built<V, B>, B extends Builder<V, B>,
    A extends ReduxActions> extends UiProps {
  String get _storePropKey => '${propKeyNamespace}store';

  /// The prop defined by [StoresT].
  ///
  /// This object should either be an instance of [Store].
  ///
  /// __Instead of storing state within this component via `setState`, it is recommended that data be
  /// pulled directly from these stores.__ This ensures that the data being used is always up to date
  /// and leaves the state management logic to the stores.
  Store<V, B, A> get store => props[_storePropKey];
  set store(Store<V, B, A> value) => props[_storePropKey] = value;

  A get actions => store.actions;
}

/// Builds on top of [UiComponent], adding `built_redux` integration.
///
/// * Redux components are responsible for rendering application views and turning
///   user interactions and events into [Action]s.
/// * Redux components can use data from one or many [Store] instances to define
///   the resulting component.
///
/// Use with the over_react transformer via the `@Component()` ([annotations.Component]) annotation.
///
/// > Related: [ReduxUiStatefulComponent]
abstract class ReduxUiComponent<
        V extends Built<V, B>,
        B extends Builder<V, B>,
        A extends ReduxActions,
        Substate> extends UiComponent<ReduxUiProps<V, B, A>>
    with _ReduxComponentMixin<V, B, A, Substate> {
  @mustCallSuper
  @override
  void componentWillMount() {
    super.componentWillMount();
    _setUpSubs();
  }

  @mustCallSuper
  @override
  void componentWillUnmount() {
    super.componentWillUnmount();
    _tearDownSubs();
  }
}

/// Builds on top of [UiStatefulComponent], adding `built_redux` integration.
///
/// * Redux components are responsible for rendering application views and turning
///   user interactions and events into [Action]s.
/// * Redux components can use data from one or many [Store] instances to define
///   the resulting component.
///
/// Use with the over_react transformer via the `@Component()` ([annotations.Component]) annotation.
///
/// > Related: [ReduxUiComponent]
abstract class ReduxUiStatefulComponent<
        V extends Built<V, B>,
        B extends Builder<V, B>,
        A extends ReduxActions,
        S extends UiState,
        Substate> extends UiStatefulComponent<ReduxUiProps<V, B, A>, S>
    with _ReduxComponentMixin<V, B, A, Substate> {
  @mustCallSuper
  @override
  void componentWillMount() {
    super.componentWillMount();
    _setUpSubs();
  }

  @mustCallSuper
  @override
  void componentWillUnmount() {
    super.componentWillUnmount();
    _tearDownSubs();
  }
}

abstract class _ReduxComponentMixin<
    V extends Built<V, B>,
    B extends Builder<V, B>,
    A extends ReduxActions,
    Substate> implements UiComponent<ReduxUiProps<V, B, A>> {
  Substate _reduxState;
  Substate get reduxState => _reduxState;

  // implemented by the concrete component to subscribe to changes
  // to the values from the redux store that this component cares about
  Substate connect(V state);

  StreamSubscription _storeSub;

  void _setUpSubs() {
    // when the values we care about change cache off the new value and
    // redraw
    _storeSub = props.store.nextSubstate(connect).listen((Substate s) {
      _reduxState = s;
      redraw();
    });
  }

  void _tearDownSubs() {
    _storeSub.cancel();
  }
}
