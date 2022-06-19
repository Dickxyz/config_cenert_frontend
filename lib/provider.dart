import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_dashboard_ui/api/requests.dart';
import 'package:tuple/tuple.dart';

final myApplyListProvider = FutureProvider<List<Apply>>((ref) async {
  return getMyApply();
});

final otherApplyListProvider = FutureProvider<List<Apply>>((ref) async {
  return getOtherApply();
});

final myTenantProvider = FutureProvider<List<Tenant>>((ref) async {
  return getTenant(null);
});

class SearchResultNotifier extends StateNotifier<List<Tenant>>  {
  SearchResultNotifier() : super([]);

  Future<void> search(String text) async {
    state = await getTenant(text);
  }
}

final searchResultProvider = StateNotifierProvider<SearchResultNotifier, List<Tenant>>((ref) {
  return SearchResultNotifier();
});

final chooseStateProvider = StateProvider<String>((ref) => "__default__");
final loginStateProvider = StateProvider<bool>((ref) => false);

final configResultProvider = FutureProvider.family<List<Config>, Tuple2<String, String>> ((ref, args) {
  return getConfigs(args.item1, args.item2);
});

final tabStateProvider = StateProvider<int>((ref) => 0);

void main() {

}