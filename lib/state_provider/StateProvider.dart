import '../apiFiles/BusinessApi.dart';
import '../main.dart';
import '../repository/HapPostRepo.dart';
import '../apiFiles/MarketplaceApi.dart';
import '../repository/PostRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../apiFiles/BlogsApi.dart';

// API Service Provider
final apiServiceProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    baseUrl: "https://ecommerce.com.pk/wp-json/api/v1",
    postBox: ref.watch(hiveBoxProvider),
  );
});

// Post Repository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    baseUrl: "https://ecommerce.com.pk/wp-json/api/v1",
    postBox: ref.watch(hiveBoxProvider), // Use the Hive box provider
    //apiService: ref.watch(apiServiceProvider), // Use the API service provider
  );
});

// Marketplace Repository Provider
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository(
    MarketplaceUrl(baseUrl: "https://ecommerce.com.pk/wp-json/api/v1"),
  );
});

// Blog Repository Provider
final blogRepositoryProvider = Provider<BlogsRepository>((ref) {
  return BlogsRepository(
    Blogsapi(blogBaseUrl: "https://ecommerce.com.pk/wp-json/api/v1"),
  );
});

// Business Repository Provider
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(
    BusinessApi(BusinessApiUrl: "https://ecommerce.com.pk/wp-json/api/v1"),
  );
});

// Fetch Posts
final postProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(postRepositoryProvider).fetchPosts();
});

// Fetch Marketplace Posts
final marketplaceProviders = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(marketplaceRepositoryProvider).fetchMarketplacePosts();
});

// Fetch Blog Posts
final blogProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(blogRepositoryProvider).fetchBlogsPosts();
});

// Fetch Business Posts
final businessProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(businessRepositoryProvider).fetchBusinessPosts();
});
