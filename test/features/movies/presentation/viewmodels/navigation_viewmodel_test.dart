import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';

void main() {
  test('NavigationViewModel initial index should be 0', () {
    final viewModel = NavigationViewModel();
    expect(viewModel.currentIndex, 0);
  });

  test('setIndex should update currentIndex and notify listeners', () {
    final viewModel = NavigationViewModel();
    bool listenerCalled = false;
    viewModel.addListener(() => listenerCalled = true);

    viewModel.setIndex(2);
    expect(viewModel.currentIndex, 2);
    expect(listenerCalled, true);
  });

  test('setIndex with same index should not notify listeners', () {
    final viewModel = NavigationViewModel();
    bool listenerCalled = false;
    viewModel.addListener(() => listenerCalled = true);

    viewModel.setIndex(0);
    expect(viewModel.currentIndex, 0);
    expect(listenerCalled, false);
  });
}
