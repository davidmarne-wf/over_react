part of over_react.component_declaration.redux_component_test;

@Factory()
UiFactory<TestRedrawOnProps> TestRedrawOn;

@Props()
class TestRedrawOnProps
    extends ReduxUiProps<BaseState, BaseStateBuilder, BaseActions> {}

@Component()
class TestRedrawOnComponent
    extends ReduxUiComponent<BaseState, BaseStateBuilder, BaseActions, int> {
  @override
  render() => Dom.div()(reduxState);

  @override
  connect(BaseState state) => state.count;

  @override
  void setState(_, [callback()]) {
    if (callback != null) callback();
  }
}
